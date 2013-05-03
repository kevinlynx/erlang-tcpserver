## kl_tserver

A simple erlang TCP server based on `supervisor` and `gen_server` OTP behaviours. You can use this library to create a TCP server without consideration about connection management.

### Usage

* compile 
  
  In the library root directory:

        erl -make

  This will compile all source in `src` directory and output all `beam` file into `ebin` directory.

* start `erl` and load the library

        erl -pa ebin

* create a simple test server, i.e:
    
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


