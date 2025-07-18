%%%-------------------------------------------------------------------
%%% @author Ale <poli.ale.ws@gmail.com>
%%% @copyright (C) 2025, Ale
%%% @doc
%%%
%%% @end
%%% Created : 05 Jul 2025 by Ale <poli.ale.ws@gmail.com>
%%%-------------------------------------------------------------------
-module(connection).
-export([init/1]).

init(Port) ->
    connect(Port).

connect(Port) ->
    Opts0 = [{active, true}, {reuseaddr, true}, {reuseport, true}, {packet, 0}],
    {ok, ListenSocket} = gen_tcp:listen(Port, Opts0),
    _Socket = accept(ListenSocket),
    %app ! hi,
    loop().

accept(ListenSocket) ->
    {ok, Socket} = gen_tcp:accept(ListenSocket),
    gen_tcp:close(ListenSocket),
    server ! spawned,
    Socket.

loop() ->
    receive
        {tcp, _Socket, Data} ->
            io:format("Received data: ~p~n", [Data]),
            loop();
        {tcp_closed, Socket} ->
            io:format("Client disconnected.~n"),
            gen_tcp:close(Socket),
            server ! {tcp_closed, self()};
        {tcp_error, Socket, Reason} ->
            io:format("Socket error: ~p~n", [Reason]),
            gen_tcp:close(Socket),
            server ! {tcp_closed, self()}
    end.
