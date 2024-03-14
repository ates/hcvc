-module(hcvc).

-export([req/2]).
-export([req/3]).

req(Method, Path) ->
    req(Method, Path, #{}).

req(Method, Path, Data) ->
    Headers = [
        {<<"X-Vault-Token">>, token()}
    ],
    case hackney:request(Method, url(Path), Headers, jsx:encode(Data), [{with_body, true}]) of
        {ok, Code, _Headers, Response} when Code =:= 200; Code =:= 204 ->
            format_response(Response);
        {ok, _Code, _Headers, Response} ->
            {error, from_json(Response)}
    end.

token() ->
    credentials_obfuscation:decrypt(persistent_term:get({hcvc, token})).

url(Path) ->
    {ok, Vault} = application:get_env(?MODULE, vault),
    uri_string:recompose(maps:put(path, Path, uri_string:parse(Vault))).

format_response(<<>>) -> ok;
format_response(Data) ->
    {ok, from_json(Data)}.

from_json(<<>>) -> #{};
from_json(Data) ->
    jsx:decode(Data).
