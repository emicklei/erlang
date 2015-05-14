-module(ring_benchmark).
-export([start/2]).
%
% Create a ring of N processes through which a message is send M times.
% First, create a chain of processes: First,...,Last
% Then send a composed message to the first process containing:
% - throw, the type of request
% - the message (payload)
% - the process id of the last created process of the ring
% - number of times the message must be thrown through the ring.
%
% @author Ernest Micklei, PhilemonWorks.com, May 2008
%
start(N,M) -> 
	First = spawn(fun() -> receive_send(void) end),
	Last = connect(First,N-1),
	First ! {throw,ball,Last,M},
	done.
%
% Create a new process that will send messages to the process with ID = To
% Repeat this Count times, forming a chain (not a ring!) of processes. 
% Return the process ID of the last created process.
%
connect(To,Count) ->
	Next = spawn(fun() -> receive_send(To) end),
 	case (Count =:= 1) of
		true -> Next;
		false -> connect(Next,Count-1)
	end.
%
% Each process will exectue this in a loop.
% To is the process ID of the next process in the ring.
% If a throw request is received then send it to the ring.
% When the message is received, throw it again if the count > 0 
% Else, send a die request to kill all processes of the ring.
%
receive_send(To) ->
	receive	
		{Message,Ring,Count} -> 
			case (To =:= void) of			
				true ->
					case (Count =:= 0) of
						true -> 
							{_,TimeAfter} = statistics(runtime),
							io:format("Completed in ~p [ms]~n",[TimeAfter]),
							Ring ! die;
						false ->
							Ring ! {Message,Ring,Count-1}
					end,
					receive_send(void);
				false ->
					To ! {Message,Ring,Count},
					receive_send(To)
			end;
		{throw,Message,Ring,Count} -> 		
			statistics(runtime),
			Ring ! {Message,Ring,Count},
			receive_send(To);
		die ->
			case (To =:= void) of
				true -> void;
				false -> To ! die
			end
	end.