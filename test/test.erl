-module(test).
-compile(export_all).
-export([handle_data/3, handle_accept/2, handle_close/2]).
-behaviour(kl_tserver).

start() ->
    kl_tserver:start_link(?MODULE, 10000, []).

handle_data(Sock, Data, State) ->
    io:format("recv data~n"),
    gen_tcp:send(Sock, Data),
    {ok, State}.

handle_accept(Sock, State) ->
    io:format("accept new client~n"),
    gen_tcp:send(Sock, "hello"),
    {ok, State}.

handle_close(_Sock, _State) ->
    io:format("sock close~n").

