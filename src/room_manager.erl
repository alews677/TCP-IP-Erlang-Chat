%%% @author Ale <poli.ale.ws@gmail.com>
%%% @copyright (C) 2025, Ale
%%% @doc 
%%%
%%% @end
%%% Created : 27 Jul 2025 by Ale <poli.ale.ws@gmail.com>
 
-module(room_manager).
-export([loop/1]).

loop(Rooms) ->
    receive
        {join, RoomName, UserPid, UserName} ->
            RoomPid = find_or_create_room(RoomName, Rooms),
            RoomPid ! {join, UserPid, UserName},
            NewRooms = add_room(RoomName, RoomPid, Rooms),
            loop(NewRooms);

        {message, RoomName, FromPid, Text} ->
            case lists:keyfind(RoomName, 1, Rooms) of
                false ->
                    io:format("Room ~p not found~n", [RoomName]),
                    loop(Rooms);
                {_, RoomPid} ->
                    RoomPid ! {message, FromPid, Text},
                    loop(Rooms)
            end;

        Any ->
            io:format("Room manager received unknown message: ~p~n", [Any]),
            loop(Rooms)
    end.




find_or_create_room(Name, Rooms) ->
    case lists:keyfind(Name, 1, Rooms) of
        false ->
            RoomPid = spawn(room, init, [Name]),
            io:format("Created new room ~p with pid ~p~n", [Name, RoomPid]),
            RoomPid;
        {_, Pid} -> Pid
    end.

add_room(Name, Pid, Rooms) ->
    case lists:keyfind(Name, 1, Rooms) of
        false -> [{Name, Pid} | Rooms]; %% adding a room if not in Rooms
        _ -> Rooms
    end.
