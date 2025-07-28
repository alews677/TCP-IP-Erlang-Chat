%%%-------------------------------------------------------------------
%%% @author Ale <poli.ale.ws@gmail.com>
%%% @copyright (C) 2025, Ale
%%% @doc
%%%
%%% @end
%%% Created : 21 Jul 2025 by Ale <poli.ale.ws@gmail.com>
%%%-------------------------------------------------------------------
-module(room).
-export([init/1]).

init(Name) ->
    io:format("Room ~p started~n", [Name]),
    loop(Name, []).

loop(Name, Users) ->
    receive
        {join, UserPid, UserName} ->
            NewUsers = add_user({UserPid, UserName}, Users),
            loop(Name, NewUsers);

        {message, FromPid, Text} ->
            case find_username(FromPid, Users) of
                undefined -> loop(Name, Users);
                UserName ->
                    broadcast(Users, UserName, Text),
                    loop(Name, Users)
            end;

        {get_name, From} ->
            From ! {room_name, self(), Name},
            loop(Name, Users)
    end.

add_user({Pid, UserName}, Users) ->
    case lists:keyfind(Pid, 1, Users) of
        false -> [{Pid, UserName} | Users];
        _ -> Users
    end.

find_username(Pid, Users) ->
    case lists:keyfind(Pid, 1, Users) of
        false -> undefined;
        {_Pid, Name} -> Name
    end.

broadcast(Users, UserName, Text) ->
    Formatted = io_lib:format("~s >>> ~s~n", [UserName, Text]),
    lists:foreach(fun({Pid, _}) -> Pid ! {room_message, Formatted} end, Users).
