
test_strategy(N, FirstPlayerStrategy, SecondPlayerStrategy) :-
test_strategy_counter(N, FirstPlayerStrategy, SecondPlayerStrategy, 0, 0, 0, 0, 0, 0, 0, 0)
.

/*finish print*/
test_strategy_counter(0, FirstPlayerStrategy, SecondPlayerStrategy, GamesPlayed, Draws, P1, P2, Longest, Shortest, Average, AverageTime) :-
write('Draws = '),
write(Draws),
nl,
write('Player 1 Wins = '),
write(P1),
nl,
write('Player 2 Wins = '),
write(P2),
nl,
write('Longest Game = '),
write(Longest),
nl,
write('Shortest Game = '),
write(Shortest),
nl,
write('Average Moves = '),
write(Average),
nl,
write('Average Time = '),
write(AverageTime)
.

/*first game*/
test_strategy_counter(N, FirstPlayerStrategy, SecondPlayerStrategy, 0, Draws, P1, P2, Longest, Shortest, Average, AverageTime) :-
statistics(runtime, [Time1,_]),
play(quiet, FirstPlayerStrategy, SecondPlayerStrategy, NumberOfMoves, WinningPlayer),
statistics(runtime, [Time2,_]),
Time is Time2 - Time1,
N1 is N-1,
(WinningPlayer == b ->
    P1Next is P1+1,
    P2Next is P2,
    DrawsNext is Draws
;   (WinningPlayer == r ->
        P2Next is P2+1,
        P1Next is P1,
        DrawsNext is Draws
    ;   DrawsNext is Draws+1,
        P2Next is P2,
        P1Next is P1
    )
),
test_strategy_counter(N1, FirstPlayerStrategy, SecondPlayerStrategy, 1, DrawsNext, P1Next, P2Next, NumberOfMoves, NumberOfMoves, NumberOfMoves, Time)
.

/*blue or red*/
test_strategy_counter(N, FirstPlayerStrategy, SecondPlayerStrategy, GamesPlayed, Draws, P1, P2, Longest, Shortest, Average, AverageTime) :-
statistics(runtime, [Time1,_]),
play(quiet, FirstPlayerStrategy, SecondPlayerStrategy, NumberOfMoves, WinningPlayer),
statistics(runtime, [Time2,_]),
Time is Time2 - Time1,
N1 is N-1,
GamesPlayed1 is GamesPlayed+1,
max(Longest, NumberOfMoves, Longest1),
min(Shortest, NumberOfMoves, Shortest1),
(WinningPlayer == b ->
    P1Next is P1+1,
    P2Next is P2,
    DrawsNext is Draws
;   (WinningPlayer == r ->
        P2Next is P2+1,
        P1Next is P1,
        DrawsNext is Draws
    ;   DrawsNext is Draws+1,
        P2Next is P2,
        P1Next is P1
    )
),
AverageNext is (((Average*GamesPlayed)+NumberOfMoves)/GamesPlayed1),
AverageTimeNext is (((AverageTime*GamesPlayed)+Time)/GamesPlayed1),
test_strategy_counter(N1, FirstPlayerStrategy, SecondPlayerStrategy, GamesPlayed1, DrawsNext, P1Next, P2Next, Longest1, Shortest1, AverageNext, AverageTimeNext)
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

max(A, B, A) :-
A >= B.

max(A, B, B) :-
A < B.

min(A, B, A) :-
A =< B.

min(A, B, B) :-
A > B.

forall(C1, C2) :- \+ (C1, \+ C2).

list_size_diff(List1, List2, Size) :-
length(List1, L1),
length(List2, L2),
Size = (L1 - L2).

getAlive(Colour, [A|[B]], Alive, OtherPlayerAlive):-
(Colour == b ->
    Alive = A,
    OtherPlayerAlive = B
;   Alive = B,
    OtherPlayerAlive = A
)
.

getPossMoves(Alive, OtherPlayerAlive, PossMoves) :-
 findall([A,B,MA,MB],(member([A,B], Alive),
                      neighbour_position(A,B,[MA,MB]),
	              \+member([MA,MB],Alive),
	              \+member([MA,MB],OtherPlayerAlive)),
	 PossMoves)
.

getBoardAfterMove(X, PossMoves, Move, Alive, OtherPlayerAlive, NextGen, OtherPlayerNextGen) :-
nth0(X, PossMoves, Move),
alter_board(Move, Alive, NewAlive),
next_generation([NewAlive,OtherPlayerAlive], [NextGen, OtherPlayerNextGen])
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bloodlust_helper(Alive, OtherPlayerAlive, Move) :-
getPossMoves(Alive, OtherPlayerAlive, PossMoves),
getBoardAfterMove(X, PossMoves, Move, Alive, OtherPlayerAlive, NextGen, OtherPlayerNextGen),
length(OtherPlayerNextGen, L1),
forall(member(WorseMove, PossMoves), 
(alter_board(WorseMove, Alive, NewAlive),
next_generation([NewAlive,OtherPlayerAlive], [_, WorseOtherPlayerNextGen]),
length(WorseOtherPlayerNextGen, L2),
L1 =< L2))
.

bloodlust(Colour, CurrentBoardState, NewBoardState, Move) :-
getAlive(Colour, CurrentBoardState, Alive, OtherPlayerAlive),
bloodlust_helper(Alive, OtherPlayerAlive, Move),
(Colour == b ->
    alter_board(Move, Alive, NewAliveBlues),
    alter_board(Move, OtherPlayerAlive, NewAliveReds)
;   alter_board(Move, Alive, NewAliveReds),
    alter_board(Move, OtherPlayerAlive, NewAliveBlues)
),
next_generation([NewAliveBlues, NewAliveReds], NewBoardState)
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


self_preservation_helper(Alive, OtherPlayerAlive, Move) :-
getPossMoves(Alive, OtherPlayerAlive, PossMoves),
getBoardAfterMove(X, PossMoves, Move, Alive, OtherPlayerAlive, NextGen, OtherPlayerNextGen),
length(NextGen, L1),
forall(member(WorseMove, PossMoves), 
(alter_board(WorseMove, Alive, NewAlive),
next_generation([NewAlive,OtherPlayerAlive], [WorseNextGen, _]),
length(WorseNextGen, L2),
L1 >= L2))
.

self_preservation(Colour, CurrentBoardState, NewBoardState, Move) :-
getAlive(Colour, CurrentBoardState, Alive, OtherPlayerAlive),
self_preservation_helper(Alive, OtherPlayerAlive, Move),
(Colour == b ->
    alter_board(Move, Alive, NewAliveBlues),
    alter_board(Move, OtherPlayerAlive, NewAliveReds)
;   alter_board(Move, Alive, NewAliveReds),
    alter_board(Move, OtherPlayerAlive, NewAliveBlues)
),
next_generation([NewAliveBlues, NewAliveReds], NewBoardState)
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

land_grab(Alive, OtherPlayerAlive, Move) :-
getPossMoves(Alive, OtherPlayerAlive, PossMoves),
getBoardAfterMove(X, PossMoves, Move, Alive, OtherPlayerAlive, NextGen, OtherPlayerNextGen),
list_size_diff(NextGen, OtherPlayerNextGen, Size1),
forall(member(WorseMove, PossMoves), 
(alter_board(WorseMove, Alive, NewAlive),
next_generation([NewAlive,OtherPlayerAlive], [WorseNextGen, WorseOtherPlayerNextGen]),
list_size_diff(WorseNextGen, WorseOtherPlayerNextGen, Size2),
Size1 >= Size2))
.

land_grab(Colour, CurrentBoardState, NewBoardState, Move) :-
getAlive(Colour, CurrentBoardState, Alive, OtherPlayerAlive),
land_grab(Alive, OtherPlayerAlive, Move),
(Colour == b ->
    alter_board(Move, Alive, NewAliveBlues),
    alter_board(Move, OtherPlayerAlive, NewAliveReds)
;   alter_board(Move, Alive, NewAliveReds),
    alter_board(Move, OtherPlayerAlive, NewAliveBlues)
),
next_generation([NewAliveBlues, NewAliveReds], NewBoardState)
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

minimax_score('b',Move,[AliveBlues,AliveReds],Score)
   :- alter_board(Move,AliveBlues,NewAliveBlues),
      next_generation([NewAliveBlues,AliveReds],NextBoardState),
      land_grab('r',NextBoardState,FinalBoardState,_),
      next_generation(FinalBoardState,[FinalBluePositions,FinalRedPositions]),
      length(FinalBluePositions,OwnScore),
      length(FinalRedPositions,OtherPlayerScore),
      Score is OwnScore - OtherPlayerScore.
minimax_score('r',Move,[AliveReds,AliveBlues],Score)
   :- alter_board(Move,AliveReds,NewAliveReds),
      next_generation([AliveBlues,NewAliveReds],NextBoardState),
      land_grab('b',NextBoardState,FinalBoardState,_),
      next_generation(FinalBoardState,[FinalBluePositions,FinalRedPositions]),
      length(FinalBluePositions,OtherPlayerScore),
      length(FinalRedPositions,OwnScore),
      Score is OwnScore - OtherPlayerScore.

minimax_move(Colour,Alive,OtherPlayerAlive,Move)
  :- findall(([A,B,MA,MB],Score),
            (
             member([A,B],Alive),neighbour_position(A,B,[MA,MB]),
             \+member([MA,MB],Alive),\+member([MA,MB],OtherPlayerAlive),
             minimax_score(Colour,[A,B,MA,MB],[Alive,OtherPlayerAlive],Score)
            ),
            PossibleMoveScore),
     findall(Score, member((_,Score),PossibleMoveScore),ScoreList),
     max_list(ScoreList,MaxScore),
     member((Move,MaxScore),PossibleMoveScore).

% strategy entry point - makes move based on player colour %
minimax('b',[AliveBlues,AliveReds],[NewAliveBlues,AliveReds],Move)
  :- minimax_move('b',AliveBlues,AliveReds,Move),
     alter_board(Move,AliveBlues,NewAliveBlues).
minimax('r',[AliveBlues,AliveReds],[AliveBlues,NewAliveReds],Move)
  :- minimax_move('r',AliveReds,AliveBlues,Move),
     alter_board(Move,AliveReds,NewAliveReds).
