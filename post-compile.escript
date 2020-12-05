#!/usr/bin/env escript

%% This script collects all the configs in source directories
%% to build directory
%% This script is invoked as a rebar hook which ensures
%% environment variable REBAR_BUILD_DIR set.

-mode(compile).
-include_lib("kernel/include/file.hrl").

main(_) ->
    BuildDir = os:getenv("REBAR_BUILD_DIR"),
    case should_copy(BuildDir) of
        true -> copy_configs(BuildDir);
        false -> ok
    end.

should_copy(false) -> false;
should_copy("") -> false;
should_copy(BuildDir) ->
    %% skip it when profiles includes test
    case re:run(BuildDir, "test") of
        nomatch -> true;
        _ -> false
    end.

copy_configs(Dir0) ->
    Dir = filename:join([Dir0, conf]),
    ok = ensure_dir_deleted(Dir),
    ok = copy_emqx_confs(Dir),
    ok = copy_plugin_confs(Dir),
    ok = copy_schema_files(Dir).

copy_emqx_confs(Dir) ->
    lists:foreach(
      fun(Name) ->
              Src = etc_conf_file(Name),
              Dst = filename:join([Dir, conf(Name)]),
              ok = copy_file(Src, Dst)
      end, [emqx, acl, ssl_dist]).

copy_plugin_confs(Dir0) ->
    Dir = filename:join([Dir0, plugins]),
    PluginConfs = filelib:wildcard("emqx/apps/*/etc/*.conf"),
    lists:foreach(
      fun(Src) ->
              Name = filename:basename(Src),
              Dst = filename:join([Dir, Name]),
              ok = copy_file(Src, Dst)
      end, PluginConfs).

% mkdir -p conf/schema
% cp emqx/priv/emqx.schema conf/schema/
copy_schema_files(Dir0) ->
    Dir = filename:join([Dir0, schema]),
    Src = filename:join([emqx, priv, "emqx.schema"]),
    Dst = filename:join([Dir, "emqx.schema"]),
    copy_file(Src, Dst).
etc_conf_file(Name) ->
    filename:join(["emqx", "etc", conf(Name)]).

conf(Name) when is_atom(Name) -> conf(atom_to_list(Name));
conf(Name) -> Name ++ ".conf".

ensure_dir_deleted(Dir) ->
    case del_dir_r(Dir) of
        ok -> ok;
        {error, enoent} -> ok
    end.

%% TODO call file:del_dir_r/1 when OTP 23
del_dir_r(File) -> % rm -rf File
    case file:read_link_info(File) of
        {ok, #file_info{type = directory}} ->
            case file:list_dir_all(File) of
                {ok, Names} ->
                    lists:foreach(fun(Name) ->
                                          del_dir_r(filename:join(File, Name))
                                  end, Names);
                {error, _Reason} -> ok
            end,
            file:del_dir(File);
        {ok, _FileInfo} -> file:delete(File);
        {error, _Reason} = Error -> Error
    end.

copy_file(Src, Dst) ->
    ok = filelib:ensure_dir(Dst),
    case file:copy(Src, Dst) of
        {ok, _Bytes} -> ok;
        {error, Reason} -> error({Reason, Src, Dst})
    end.


