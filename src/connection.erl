%%%-------------------------------------------------------------------
%%% @author Ale <poli.ale.ws@gmail.com>
%%% @copyright (C) 2025, Ale
%%% @doc
%%%
%%% @end
%%% Created : 05 Jul 2025 by Ale <poli.ale.ws@gmail.com>
%%%-------------------------------------------------------------------
-module(connection).
-export([loop/1, response/2]).

%%
%% 
%% 
loop(Socket) ->
    receive
        {tcp, RecSocket, Data} when RecSocket == Socket ->
            FormatData = string:trim(unicode:characters_to_list(Data)),
            Lines = string:split(FormatData, " ", all),
            handle(RecSocket, Lines),
            loop(Socket);
        {tcp, _, _} ->
            app ! {server, "Wrong socket"};
        {tcp_closed, _} ->
            io:format("Client ~p disconnected.~n", [Socket]),
            app ! {tcp_closed, self()};
        {tcp_error, _, Reason} ->
            io:format("Socket error: ~p~n", [Reason]),
            servapper ! {tcp_error, self()}
    end.

%%
%% 
%% 
response(Socket, Packet) ->
    gen_tcp:send(Socket, Packet ++ "\r\n").

%%
%% 
%% 
help(Socket) ->
    response(Socket, "Commands:~n help - show this help~n exit - close connection~n say <something> ~n").


%%
%% Command
%% 
handle(Socket, [Line | _]) when Line == "exit" ->
    gen_tcp:close(Socket),
    server ! {tcp_closed, self()};
handle(Socket, [Line | _]) when Line == "help" ->
    help(Socket);
handle(Socket, [Line | Msg]) when Line == "say" ->
    response(Socket, "User said: " ++ Msg);
handle(Socket, _) ->
    response(Socket, "Unknown command. Type 'help'.").
