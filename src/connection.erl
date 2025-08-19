%%%-------------------------------------------------------------------
%%% @author Ale <poli.ale.ws@gmail.com>
%%% @copyright (C) 2025, Ale
%%% @doc
%%%         This module menage a single connection to a socket
%%% @end
%%% Created : 05 Jul 2025 by Ale <poli.ale.ws@gmail.com>
%%%-------------------------------------------------------------------
-module(connection).

-export([init/1]).

-record(state, {socket, room, username}).

init(Socket) ->
    State = #state{socket = Socket},
    loop(State).

loop(State) ->
    receive
        {tcp, Socket, Data} when Socket == State#state.socket ->
            %%io:format("Username ~p, Room ~p~n", [State#state.username, State#state.room]),
            NewState = format(State, Data),
            loop(NewState);
        {tcp, _, _} ->
            app ! {server, "Wrong socket"};
        {tcp_closed, _} ->
            app ! {tcp_closed, self()};
        {tcp_error, _, _Reason} ->
            app ! {tcp_error, self()};
        {room_message, Text} ->
            NewState = response(State, Text),
            loop(NewState)
    end.

format(State, Data) ->
    io:format("Data :~p~n", [Data]),
    FormatData = unicode:characters_to_list(Data),
    TrimmedData = string:trim(FormatData),
    io:format("TrimmedData :~p~n", [TrimmedData]),
    case TrimmedData of
        [] ->
            State;
        _ ->
            case string:prefix(TrimmedData, "$") of
                nomatch when State#state.room =/= undefined ->
                    room_manager ! {message, State#state.room, self(), TrimmedData},
                    State;
                nomatch ->
                    handle(State, {message, TrimmedData});
                _ ->
                    Lines = string:split(TrimmedData, " ", all),
                    handle(State, {command, Lines})
            end
    end.

handle(State, {command, Lines}) ->
    case Lines of
        ["$help" | _] ->
            New = help(State);
        ["$join" | Room] when Room =/= [] ->
            New = join(State, Room);
        ["$exit" | _] ->
            exit,
            New = State;
        ["$username" | Username] when Username =/= [] ->
            New = State#state{username = Username};
        ["$info" | _] ->
            New = info(State);
        
        _ ->
            New = response(State, "Command unknown or uncompleted")
    end,
    New;
handle(State, {message, Data}) ->
    response(State, "User said: " ++ Data).

response(State, Packet) ->
    case gen_tcp:send(State#state.socket, Packet ++ "\r\n") of
        ok -> State;
        {error, Reason} ->
            io:format("Send failed: ~p~n", [Reason]),
            exit(Reason)
    end.

help(State) ->
    response(State,
        "\n    Commands:\n"
        "     $help - show this help\n"
        "     $exit - close connection\n"
        "     $join <room> - enter in a chat\n"
        "     $username <name> - set your username\n"
        "     $info - show your current username and room\n").

join(State, Room) when State#state.username =/= undefined ->
    room_manager ! {join, Room, self(), State#state.username},
    State#state{room = Room};
join(State, _) ->
    response(State, "You must first add a username").

info(State)  when State#state.username =/= undefined andalso State#state.room =/= undefined->
    Temp = "Your username is " ++ State#state.username ++ " \n and your room is " ++ State#state.room,
    response(State, Temp);
info(State) ->
    response(State, "Username or room not specified").