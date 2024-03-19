-module(hcvc_kv).

-export([put/2]).
-export([get/1]).

put(Key, Value) when is_map(Value) ->
    hcvc:req(post, ["/v1"] ++ Key, Value).

get(Key) ->
    {ok, #{<<"data">> := Data}} = hcvc:req(get, ["/v1"] ++ Key]),
    Data.
