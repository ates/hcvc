-module(hcvc).

-export([req/2]).
-export([req/3]).

-include_lib("kernel/include/logger.hrl").

req(Method, Path) ->
    req(Method, Path, #{}).

req(Method, Path, Data) ->
    Headers = [
        {<<"X-Vault-Token">>, token()}
    ],
    Options = [
        {with_body, true},
        {ssl_options, application:get_env(?MODULE, ssl_options, [])}
    ],
    case hackney:request(Method, url(Path), Headers, jsx:encode(Data), Options) of
        {ok, Code, _Headers, Response} when Code =:= 200; Code =:= 204 ->
            format_response(Response);
        {ok, _Code, _Headers, Response} ->
            {error, from_json(Response)}
    end.

token() ->
    credentials_obfuscation:decrypt(persistent_term:get({hcvc, token})).

url(Path) when is_list(Path) ->
    {ok, Vault} = application:get_env(?MODULE, vault),
    NewPath = filename:join(Path),
    uri_string:recompose(maps:put(path, NewPath, uri_string:parse(Vault))).

format_response(<<>>) -> ok;
format_response(Data) ->
    {ok, from_json(Data)}.

from_json(<<>>) -> #{};
from_json(Data) ->
    try
        jsx:decode(Data)
    catch
        _:Error:Stack ->
            ?LOG_ERROR("hcvc: can't decode response, error: ~p, stack: ~p, data: ~p", [
                Error, Stack, Data
            ]),
            {error, Error}
    end.
