-module(ring_benchmark).
-compile(export_all).

start(N,M) -> 
	First = spawn(fun() -> receive_send(void) end),
	io:format("Created ~p~n",[First]),
	Last = connect(First,N-1),
	io:format("~p will send messages to ~p~n", [First,Last]),
	for(1,M, fun(K)->
				io:format("sending ~p to ~p~n",[{Last,K},First]),
				First ! {throw,Last,K}
			end),
	First ! {die,Last},
	done.

connect(To,S) ->
	Next = spawn(fun() -> receive_send(To) end),
	io:format("Created ~p~n",[Next]),
	io:format("~p will send messages to ~p~n", [Next,To]),
 	case (S =:= 1) of
		true -> Next;
		false -> connect(Next,S-1)
	end.

receive_send(To) ->
	receive		
		{K} -> 
			case (To =:= void) of			
				true ->
					io:format("~p received ~p~n",[self(),K]),
					receive_send(void);
				false ->
					io:format("~p received ~p, sending it to: ~p~n",[self(),K,To]), 
					To ! {K},
					receive_send(To)
			end;
		{throw,Ring,K} -> 
			io:format("~p received ~p, sending it to: ~p~n",[self(),K,Ring]), 
			Ring ! {K},
			receive_send(To);
		{die,Ring} ->
			Ring ! die,
			io:format("~p died~n",[self()]);
		die ->
			io:format("~p died~n",[self()]),
			case (To =:= void) of
				true -> void;
				false -> To ! die
			end
	end.
	
for(M,M,F) -> F(M);
for(K,M,F) -> F(K),for(K+1,M,F).