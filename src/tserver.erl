%%
%% tserver.erl
%% Kevin Lynx
%% 05.03.2013
%%
-module(tserver).
-behaviour(gen_server).
-export([init/1, handle_info/2, handle_cast/2, handle_call/3, code_change/3, terminate/2]).
-export([start_link/3]).
-compile(export_all).
-record(state, {lsock, mod, arg, parent}).

start_link(M, LSock, Arg) ->
    gen_server:start_link(?MODULE, [LSock, M, Arg, self()], []).

init([LSock, M, Arg, Parent]) ->
    {ok, #state{lsock = LSock, mod = M, arg = Arg, parent = Parent}, 0}.

handle_info({tcp, Socket, RawData}, #state{mod = M, arg = Arg} = State) ->
    case M:handle_data(Socket, RawData, Arg) of 
        {close, NewArg} ->
            gen_tcp:close(Socket),
            {noreply, State#state{arg = NewArg}};
        {ok, NewArg} -> 
            inet:setopts(Socket, [{active,once}]),
            {noreply, State#state{arg = NewArg}}
    end;

handle_info({tcp_closed, Socket}, #state{mod = M, arg = Arg} = State) ->
    M:handle_close(Socket, Arg),
    {stop, normal, State};

handle_info(timeout, #state{lsock = LSock, mod = M, arg = Arg, parent = Parent} = State) ->
    {ok, Sock} = gen_tcp:accept(LSock),
    case M:handle_accept(Sock, Arg) of 
        {close, NewArg} -> 
            gen_tcp:close(Sock),
            {noreply, State#state{arg = NewArg}};
        {ok, NewArg} ->
            tserver_sup:start_child(Parent),
            inet:setopts(Sock, [{active,once}]),
            {noreply, State#state{lsock = Sock, arg = NewArg}}
    end.

handle_call(Msg, _From, State) ->
    {reply, {ok, Msg}, State}.

handle_cast(stop, State) ->
    {stop, normal, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

