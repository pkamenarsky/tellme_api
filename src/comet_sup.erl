%% @author Mochi Media <dev@mochimedia.com>
%% @copyright 2010 Mochi Media <dev@mochimedia.com>

%% @doc Supervisor for the comet application.

-module(comet_sup).
-author("Mochi Media <dev@mochimedia.com>").

-behaviour(supervisor).

%% External exports
-export([start_link/0, upgrade/0]).

%% supervisor callbacks
-export([init/1]).

%% @spec start_link() -> ServerRet
%% @doc API for starting the supervisor.
start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% @spec upgrade() -> ok
%% @doc Add processes if necessary.
upgrade() ->
    {ok, {_, Specs}} = init([]),

    Old = sets:from_list(
            [Name || {Name, _, _, _} <- supervisor:which_children(?MODULE)]),
    New = sets:from_list([Name || {Name, _, _, _, _, _} <- Specs]),
    Kill = sets:subtract(Old, New),

    sets:fold(fun (Id, ok) ->
                      supervisor:terminate_child(?MODULE, Id),
                      supervisor:delete_child(?MODULE, Id),
                      ok
              end, ok, Kill),

    [supervisor:start_child(?MODULE, Spec) || Spec <- Specs],
    ok.

%% @spec init([]) -> SupervisorTree
%% @doc supervisor callback.
init([]) ->
    Web = web_specs(),
	CometSid = comet_sid_specs(),
	CometAuth = comet_auth_specs(),

    Processes = [Web, CometSid, CometAuth],
    Strategy = {one_for_one, 10, 10},

    {ok,
     {Strategy, lists:flatten(Processes)}}.

web_specs() ->
    WebConfig = [{ip, {0,0,0,0}},
                 {port, 8080},
                 {docroot, comet_deps:local_path(["priv", "www"])}],
    {comet_web,
     {comet_web, start, [WebConfig]},
     permanent, 5000, worker, dynamic}.

comet_sid_specs() ->
	{comet_sid,
		{comet_sid, start, []},
		permanent, brutal_kill, worker, [comet_sid]}.

comet_auth_specs() ->
	{comet_auth,
		{comet_auth, start, []},
		permanent, 5000, worker, [comet_auth]}.

