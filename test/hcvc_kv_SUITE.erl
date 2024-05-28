-module(hcvc_kv_SUITE).

-export([all/0]).
-export([init_per_suite/1]).
-export([end_per_suite/1]).

-export([put/1]).
-export([get/1]).

-include_lib("common_test/include/ct.hrl").

-define(DOCKER_IMAGE, "hashicorp/vault:1.16").

all() ->
    [
        put,
        get
    ].

init_per_suite(Config) ->
    {ok, _} = application:ensure_all_started(hcvc),
    hcvc_ct_util:sh(["docker", "pull", ?DOCKER_IMAGE], [0], timer:seconds(300)),
    Cmd = [
        "docker", "run", "--rm", "-d",
        "--cap-add", "IPC_LOCK",
        "--name", "dev-vault",
        "-p", "8200:8200",
        "-e", "VAULT_DEV_ROOT_TOKEN_ID=root",
        ?DOCKER_IMAGE
    ],
    hcvc_ct_util:sh(Cmd),
    timer:sleep(2000),
    Config.

end_per_suite(Config) ->
    application:stop(hcvc),
    hcvc_ct_util:sh(["docker", "container", "kill", "dev-vault"]),
    Config.

put(_Config) ->
    hcvc_secrets:enable("test"),
    ok = hcvc_kv:put(["test", "key"], #{value => 1}).

get(_Config) ->
    #{<<"value">> := 1} = hcvc_kv:get(["test", "key"]).
