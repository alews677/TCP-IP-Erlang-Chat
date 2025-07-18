%%%-------------------------------------------------------------------
%%% @author Ale <poli.ale.ws@gmail.com>
%%% @copyright (C) 2025, Ale
%%% @doc
%%%
%%% @end
%%% Created : 11 Jul 2025 by Ale <poli.ale.ws@gmail.com>
%%%-------------------------------------------------------------------
-module(app).

-export([start/0, init/0, loop/0]).

start() ->
    io:format("App is starting ... \n"),
    Pid = spawn(?MODULE, init, []),
    register(app, Pid).

init() ->
    Server = spawn(server, start, []),
    register(server, Server),
    loop().

loop() ->
    receive
        hi ->
            io:format("Hi~n~n"),
            loop();
        {error, 100} ->
            io:format("100 connections tcp active")
    end.
 