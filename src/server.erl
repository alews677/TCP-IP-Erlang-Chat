%%%-------------------------------------------------------------------
%%% @author Ale <poli.ale.ws@gmail.com>
%%% @copyright (C) 2025, Ale
%%% @doc
%%%
%%% @end
%%% Created : 05 Jul 2025 by Ale <poli.ale.ws@gmail.com>
%%%-------------------------------------------------------------------
-module(server).

-export([start/0]).

start() ->
    io:format("Server is starting...."),
    spawn(connection, init, [1234]),
    loop(0).

loop(Connections) ->
    receive
        spawned when Connections < 100 ->
            spawn(connection, init, [1234]),
            loop(Connections + 1);
        spawned when Connections > 10 ->
            app ! {error, 100},
            loop(Connections);
        {tcp_closed, Pid} ->
            exit(Pid, kill),
            loop(Connections-1);
        {error, Reason} ->
            error("An error occurred becouse ~p~n", [Reason])
    end.


