-module(chain_servers).
-export([start/0, serv1/1, serv2/1, serv3/1]).

%Team: Madison Roberts and Ashley Price

serv1(Next) -> receive
    {add, X, Y} ->
        io:format("(serv1) ~p + ~p = ~p~n", [X, Y, X + Y]),
        serv1(Next);
    {sub, X, Y} ->
        io:format("(serv1) ~p - ~p = ~p~n", [X, Y, X - Y]),
        serv1(Next);
    {mult, X, Y} ->
        io:format("(serv1) ~p * ~p = ~p~n", [X, Y, X * Y]),
        serv1(Next);
    {'div', X, Y} when Y =/= 0 ->
        io:format("(serv1) ~p / ~p = ~p~n", [X, Y, X / Y]),
        serv1(Next);
    {neg, X} ->
        io:format("(serv1) neg(~p) = ~p~n", [X, -X]),
        serv1(Next);
    {sqrt, X} when X >= 0 ->
        io:format("(serv1) sqrt(~p) = ~p~n", [X, math:sqrt(X)]),
        serv1(Next);
    halt ->
        Next ! halt,
        io:format("(serv1) Halting.~n");
    Msg ->
        Next ! Msg,
        serv1(Next)
    end.

serv2(Next) -> receive
    [H | T] when is_integer(H) ->
        Sum = lists:sum([X || X <- [H | T], is_number(X)]), %if you can find another way to do this, please let me know
        io:format("(serv2) Sum of numbers: ~p~n", [Sum]),
        serv2(Next);
    [H | T] when is_float(H) ->
        Product = lists:foldl(fun(X, Acc) when is_number(X) -> X * Acc; (_, Acc) -> Acc end, 1, [H | T]), %same here
        io:format("(serv2) Product of numbers: ~p~n", [Product]),
        serv2(Next);
    halt ->
        Next ! halt,
        io:format("(serv2) Halting.~n");
    Msg ->
        Next ! Msg,
        serv2(Next)
    end.

serv3(UnhandledCount) -> receive
    {error, Msg} ->
        io:format("(serv3) Error: ~p~n", [Msg]),
        serv3(UnhandledCount);
    halt ->
        io:format("(serv3) Halting. Unhandled messages: ~p~n", [UnhandledCount]);
    Msg ->
        io:format("(serv3) Not handled: ~p~n", [Msg]),
        serv3(UnhandledCount + 1)
    end.

start() ->
    Serv3 = spawn(?MODULE, serv3, [0]),
    Serv2 = spawn(?MODULE, serv2, [Serv3]),
    Serv1 = spawn(?MODULE, serv1, [Serv2]),
    loop(Serv1).

loop(Serv1) ->
    io:format("Enter message: "),
    {ok, Input} = io:read(""),
    case Input of
        all_done -> ok;
         _ -> Serv1 ! Input, loop(Serv1)
    end.
