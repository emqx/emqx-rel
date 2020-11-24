#!/usr/bin/env escript

%% This script injects implicit relup dependencies for emqx applications.
%%
%% By 'implicit', it means that it is not feasible to define application
%% dependencies in .app.src files.
%%
%% For instance, during upgrade/downgrade, emqx_dashboard usually requires
%% a restart after (but not before) all plugins are upgraded (and maybe
%% restarted), however, the dependencies are not resolvable at build time
%% when relup is generated.
%%
%% This script is to be executed after compile, with the profile given as the
%% first argument. For each dependency overlay, it modifies the .app file to
%% have the 'relup_deps' list extended.

-mode(compile).

usage() ->
  "Usage: " ++ escript:script_name() ++ " emqx|edge".

-type app() :: atom().
-type deps_overlay() :: {re, string()} | app().

%% deps/0 returns the dependency overlays.
%% {re, Pattern} to match application names using regexp pattern
-spec deps(string()) -> [{app(), [deps_overlay()]}].
deps(_Profile) ->
  [ {emqx_dashboard, [{re, "emqx_.*"}]}
  , {emqx_management, [{re, "emqx_.*"}]}
  , {{re, "emqx_.*"}, [emqx]}
  , {{re, "emqx_auth_.*"}, [emqx_passwd]}
  ].

main([Profile | _]) ->
  ok = inject(Profile);
main(_Args) ->
  io:format(standard_error, "~s", [usage()]),
  erlang:halt(1).

expand({Name, Deps}, AppNames) ->
  Names = match_pattern(Name, AppNames),
  NewDeps = expand_deps(Deps, AppNames, []),
  [{N, NewDeps} || N <- Names].

expand_deps([], _AppNames, Acc) -> Acc;
expand_deps([Dep | Deps], AppNames, Acc) ->
  NewAcc = add_to_list(Acc, match_pattern(Dep, AppNames)),
  expand_deps(Deps, AppNames, NewAcc).

inject(Profile) ->
  LibDir = lib_dir(Profile),
  AppNames = list_apps(LibDir),
  Deps0 = lists:flatmap(fun(Dep) -> expand(Dep, AppNames) end, deps(Profile)),
  lists:foreach(fun({App, Deps}) -> inject(App, Deps, LibDir) end, Deps0).

%% list the profile/lib dir to get all apps
list_apps(LibDir) ->
  Apps = filelib:wildcard("*", LibDir),
  lists:foldl(fun(App, Acc) -> [App || is_app(LibDir, App)] ++ Acc end, [], Apps).

is_app(_LibDir, "." ++ _) -> false; %% ignore hidden dir
is_app(LibDir, AppName) ->
  filelib:is_regular(filename:join([ebin_dir(LibDir, AppName), AppName ++ ".app"])) orelse
  error({unknown_app, AppName}). %% wtf

lib_dir(Profile) ->
  filename:join(["_build", Profile, lib]).

ebin_dir(LibDir, AppName) -> filename:join([LibDir, AppName, "ebin"]).

inject(App0, DepsToAdd, LibDir) ->
  App = str(App0),
  AppEbinDir = ebin_dir(LibDir, App),
  [AppFile0] = filelib:wildcard("*.app", AppEbinDir),
  AppFile = filename:join(AppEbinDir, AppFile0),
  {ok, [{application, AppName, Props}]} = file:consult(AppFile),
  Deps0 = case lists:keyfind(relup_deps, 1, Props) of
              {_, X} -> X;
              false -> []
          end,
  %% merge extra deps, but do not self-include
  Deps = add_to_list(Deps0, DepsToAdd) -- [App0],
  NewProps = lists:keystore(relup_deps, 1, Props, {relup_deps, Deps}),
  AppSpec = {application, AppName, NewProps},
  AppSpecIoData = io_lib:format("~p.", [AppSpec]),
  io:format(user, "updated_dependency_applications for ~p~n", [App]),
  file:write_file(AppFile, AppSpecIoData).

str(A) when is_atom(A) -> atom_to_list(A).

match_pattern({re, Re}, AppNames) ->
  Match = fun(AppName) -> re:run(AppName, Re) =/= nomatch end,
  AppNamesToAdd = lists:filter(Match, AppNames),
  AppsToAdd = lists:map(fun(N) -> list_to_atom(N) end, AppNamesToAdd),
  case AppsToAdd =:= [] of
    true  -> error({nomatch, Re});
    false -> AppsToAdd
  end;
match_pattern(NameAtom, AppNames) ->
  case lists:member(str(NameAtom), AppNames) of
    true  -> [NameAtom];
    false -> error({notfound, NameAtom})
  end.

%% Append elements to list without duplication. No reordering.
add_to_list(List, []) -> List;
add_to_list(List, [H | T]) ->
  case lists:member(H, List) of
    true -> add_to_list(List, T);
    false -> add_to_list(List ++ [H], T)
  end.
