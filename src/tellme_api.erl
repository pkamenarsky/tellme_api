-module(tellme_api).
-author("Philip Kamenarsky <pk@harmonious.at>").
-export([start/0, stop/0]).

ensure_started(App) ->
    case application:start(App) of
        ok ->
            ok;
        {error, {already_started, App}} ->
            ok
    end.


%% @spec start() -> ok
%% @doc Start the comet server.
start() ->
    comet_deps:ensure(),
    ensure_started(crypto),
    application:start(tellme_api).


%% @spec stop() -> ok
%% @doc Stop the comet server.
stop() ->
    application:stop(tellme_api).
