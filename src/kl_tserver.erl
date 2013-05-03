%%
%% kl_tserver.erl
%% Kevin Lynx
%% 05.03.2013
%%
-module(kl_tserver).
-export([behaviour_info/1]).
-export([start_link/3, start_link/4, stop/1]).

behaviour_info(callbacks) ->
    [{handle_data, 3},
        {handle_accept, 2},
        {handle_close, 2}];
behaviour_info(_Other) ->
    undefined.

start_link(Callback, Port, UserArgs) ->
    start_link(Callback, undefined, Port, UserArgs).

start_link(Callback, IP, Port, UserArgs) ->
    tserver_sup:start_link(Callback, IP, Port, UserArgs).

stop(Pid) ->
    exit(Pid, normal).

