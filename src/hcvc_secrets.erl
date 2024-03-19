-module(hcvc_secrets).

-export([enable/1]).
-export([enable/2]).
-export([list/0]).

enable(Name) ->
    enable(Name, <<>>).

enable(Name, Description) ->
    Data = #{
        <<"type">> => <<"kv">>,
        <<"description">> => Description
    },
    hcvc:req(post, ["/v1/sys/mounts", Name], Data).

list() ->
    {ok, #{<<"data">> := Data}} = hcvc:req(get, ["/v1/sys/mounts"]),
    Fields = [
        <<"type">>,
        <<"accessor">>,
        <<"description">>
    ],
    maps:fold(
        fun(Name, Params, Acc) ->
            Acc#{Name => maps:with(Fields, Params)}
        end,
        #{},
        Data
    ).
