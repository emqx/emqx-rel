#!/usr/bin/env escript
%% -*- mode: erlang;erlang-indent-level: 4;indent-tabs-mode: nil -*-
%% ex: ft=erlang ts=4 sw=4 et
%% -------------------------------------------------------------------
%%
%% nodetool: Helper Script for interacting with live nodes
%%
%% -------------------------------------------------------------------

main(Args) ->
    case Args of
        ["ref"] -> io:format(getRef());
        ["tag"] -> io:format(latestTag())
    end.

comparingFun([C1|R1], [C2|R2]) when is_list(C1), is_list(C2);
                                    is_integer(C1), is_integer(C2) -> C1 < C2 orelse comparingFun(R1, R2);
comparingFun([C1|R1], [C2|R2]) when is_integer(C1), is_list(C2)    -> comparingFun(R1, R2);
comparingFun([C1|_R1], [C2|_R2]) when is_list(C1), is_integer(C2)    -> true;
comparingFun(_, _) -> false.

sortFun(T1, T2) ->
    C = fun(T) ->
          [case catch list_to_integer(E) of
              I when is_integer(I) -> I;
              _ -> E
            end || E <- re:split(string:sub_string(T, 2), "[.-]", [{return, list}])]
        end,
    comparingFun(C(T1), C(T2)).

latestTag() ->
    Tag = os:cmd("git describe --abbrev=0 --tags") -- "\n",
    LatestTagCommitId = os:cmd(io_lib:format("git rev-parse ~s", [Tag])) -- "\n",
    Tags = string:tokens(os:cmd(io_lib:format("git tag -l \"v*\" --points-at ~s", [LatestTagCommitId])), "\n"),
    lists:last(lists:sort(fun(T1, T2) -> sortFun(T1, T2) end, Tags)).

branch() ->
    case os:getenv("GITHUB_RUN_ID") of
           false -> os:cmd("git branch | grep -e '^*' | cut -d' ' -f 2") -- "\n";
           _ -> re:replace(os:getenv("GITHUB_REF"), "^refs/heads/|^refs/tags/", "", [global, {return ,list}])
    end.

getRef() ->
    case re:run(branch(), "master|^dev/|^hotfix/", [{capture, none}]) of
        match -> branch();
        _ -> latestTag()
    end.

