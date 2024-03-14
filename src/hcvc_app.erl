-module(hcvc_app).

-export([start/2, stop/1]).

start(_Type, _Args) ->
    case hcvc_sup:start_link() of
        {ok, _Pid} = Sup ->
            credentials_obfuscation:set_secret(crypto:strong_rand_bytes(16)),
            {ok, Token} = application:get_env(hcvc, token),
            persistent_term:put({hcvc, token}, credentials_obfuscation:encrypt(Token)),
            Sup;
        Error -> Error
    end.

stop(_State) -> ok.
