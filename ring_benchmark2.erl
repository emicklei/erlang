-module(ring_benchmark).
-compile(export_all).

start(N,M) -> 
	First = spawn(fun() -> receive_send() end),
	io:format("Created ~p~n",[First]),
	Last = connect(First,N-1),
	io:format("sending ~p to ~p~n",[M,Last]),
	Last ! {Last,M},
	stop.

connect(To,K) ->
	Next = spawn(fun() -> receive_send(To) end),
	io:format("Created ~p~n",[Next]),
 	case (K =:= 1) of
		true -> Next;
		false -> 
			io:format("~p will send messages to ~p~n", [Next,To]),
			connect(Next,K-1)
	end.

receive_send() ->
	receive
		die -> 
			io:format("~p NOT received die~n", [self()]);
		{Last,1} -> 
			io:format("~p received ~p, sending die to ~p~n", [self(),{Last,1},Last]),
			Last ! die;
		{Last,K} -> 
			io:format("~p received ~p, sending it to ~p~n", [self(),{Last,K},Last]),
			Last ! {Last,K-1},
			receive_send()
	end.

receive_send(To) ->
	receive
		die -> 
			io:format("~p received die, sending die to: ~p~n",[self(),To]),
			To ! die;
		{Last,K} -> 
			io:format("~p received ~p, sending it to: ~p~n",[self(),{Last,K},To]), 			
			To ! {Last,K},
			receive_send(To)
	end.