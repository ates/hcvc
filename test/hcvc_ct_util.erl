-module(hcvc_ct_util).

-export([sh/1, sh/3]).

sh(CmdList) ->
    sh(CmdList, [0], 5000).

sh(CmdList, AllowedStatuses, Timeout) ->
    Cmd = string:join(CmdList, " "),
    Port = erlang:open_port({spawn, Cmd}, [{line, 256}, exit_status, stderr_to_stdout]),
    {Status, Output} = sh_data(Port, Timeout, []),
    sh_result(Status, Output, AllowedStatuses).

sh_data(Port, Timeout, Acc) ->
    receive
        {Port, {exit_status, Status}} ->
            {Status, erlang:iolist_to_binary(lists:reverse(Acc))};
        {Port, {data, {eol, Line}}} ->
            sh_data(Port, Timeout, ["\n", Line | Acc])
    after Timeout ->
            exit(Port, kill),
            erlang:error({timeout, erlang:iolist_to_binary(lists:reverse(Acc))})
    end.

sh_result(Status, Output, Allowed) ->
    case lists:member(Status, Allowed) of
        true ->
            {Status, Output};
        false ->
            erlang:error({sh, Status, Output})
    end.
