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
    Port = 1234,
    Opts = [{active, true}, {reuseaddr, true}, {reuseport, true}, {packet, 0}],
    {ok, ListenSocket} = gen_tcp:listen(Port, Opts),
    io:format("Server listening on port ~p~n", [Port]),
    accept_loop(ListenSocket).

accept_loop(ListenSocket) ->
    {ok, Socket} = gen_tcp:accept(ListenSocket),
    Pid = spawn(connection, init, [Socket]),
    gen_tcp:controlling_process(Socket, Pid),
    app ! {server, "client connected, pid: " ++ pid_to_list(Pid)},
    accept_loop(ListenSocket).