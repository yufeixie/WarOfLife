:- ensure_loaded('war_of_life.pl').

test_strategy(N, FirstPlayerStrategy, SecondPlayerStrategy) :-
test_strategy_counter(N, FirstPlayerStrategy, SecondPlayerStrategy, 0, 0, 0, 0, 0, 0, 0, 0)
.

/*finish print*/
test_strategy_counter(0, FirstPlayerStrategy, SecondPlayerStrategy, GamesPlayed, Draws, P1, P2, Longest, Shortest, Average, AverageTime) :-
AverageTimeForGame is AverageTime / (1000*GamesPlayed),
write('Player 1 Wins = '),
write(P1),
nl,
write('Player 2 Wins = '),
write(P2),
nl,
write('Draws = '),
write(Draws),
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
write(AverageTimeForGame)
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
AverageTimeNext is AverageTime+Time,
test_strategy_counter(N1, FirstPlayerStrategy, SecondPlayerStrategy, GamesPlayed1, DrawsNext, P1Next, P2Next, Longest1, Shortest1, AverageNext, AverageTimeNext)
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


max_list([H|T], M) :- 
    max_list(T, H, M). 

max_list([], Max, Max).
max_list([H|T], Max, M) :- 
    Max1 is max(Max, H), 
    max_list(T, Max1, M).

min_list([H|T], Min) :-
    min_list(T, H, Min).

min_list([], Min, Min).
min_list([H|T], Min0, Min) :-
    Min1 is min(H, Min0),
    min_list(T, Min1, Min).

sum_list([Item], Item).
sum_list([Item1,Item2 | Tail], Total) :-
    sum_list([Item1+Item2|Tail], Total).

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

getBoardAfterMove(X, PossMoves, Move, Alive, OtherPlayerAlive, NextGen, OtherPlayerNextGen) :-
nth0(X, PossMoves, Move),
alter_board(Move, Alive, NewAlive),
next_generation([NewAlive,OtherPlayerAlive], [NextGen, OtherPlayerNextGen])
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bloodlust('b',[Blues,Reds],[NewBlues,Reds],Move) :- 
    strategy_helper('b',Blues,Reds,'b',Move),
    alter_board(Move,Blues,NewBlues).

bloodlust('r',[Blues,Reds],[Blues,NewReds],Move) :- 
    strategy_helper('r',Reds,Blues,'b',Move),
    alter_board(Move,Reds,NewReds).

self_preservation('b',[Blues,Reds],[NewBlues,Reds],Move):- 
    strategy_helper('b',Blues,Reds,'s',Move),
    alter_board(Move,Blues,NewBlues).

self_preservation('r',[Blues,Reds],[Blues,NewReds],Move) :-
    strategy_helper('r',Reds,Blues,'s',Move),
    alter_board(Move,Reds,NewReds).

land_grab('b',[Blues,Reds],[NewBlues,Reds],Move) :-
    strategy_helper('b',Blues,Reds,'l',Move),
    alter_board(Move,Blues,NewBlues).

land_grab('r',[Blues,Reds],[Blues,NewReds],Move) :-
    strategy_helper('r',Reds,Blues,'l',Move),
    alter_board(Move,Reds,NewReds).

minimax('b',[Blues,Reds],[NewBlues,Reds],Move) :-
    strategy_helper('b',Blues,Reds,'m',Move),
    alter_board(Move,Blues,NewBlues).

minimax('r',[Blues,Reds],[Blues,NewReds],Move) :-
    strategy_helper('r',Reds,Blues,'m',Move),
    alter_board(Move,Reds,NewReds).

strategy_helper(Colour,Alive,OtherPlayerAlive,Strategy,Move) :- 
  findall(([A,B,MA,MB],Score),
            (
             member([A,B],Alive),neighbour_position(A,B,[MA,MB]),
             \+member([MA,MB],Alive),\+member([MA,MB],OtherPlayerAlive),
             determine_strategy(Strategy,Colour,[A,B,MA,MB],[Alive,OtherPlayerAlive],Score)
            ),
            PossibleMoveScore),
     findall(Score, member((_,Score),PossibleMoveScore), ScoreList),
     find_min_max(Strategy,ScoreList,MinScore),
     member((Move,MinScore),PossibleMoveScore).

find_min_max('b',ScoreList,Move) :-
    min_list(ScoreList,Move).

find_min_max('s',ScoreList,Move) :-
    max_list(ScoreList,Move).

find_min_max('l',ScoreList,Move) :-
    max_list(ScoreList,Move).

find_min_max('m',ScoreList,Move) :-
    max_list(ScoreList,Move).

determine_strategy('b',Colour,[A,B,MA,MB],[Alive,OtherPlayerAlive],Score) :-
    bloodlust_helper(Colour,[A,B,MA,MB],[Alive,OtherPlayerAlive],Score).

determine_strategy('s',Colour,[A,B,MA,MB],[Alive,OtherPlayerAlive],Score) :-
    self_pres_helper(Colour,[A,B,MA,MB],[Alive,OtherPlayerAlive],Score).    

determine_strategy('l',Colour,[A,B,MA,MB],[Alive,OtherPlayerAlive],Score) :-
    land_grab_helper(Colour,[A,B,MA,MB],[Alive,OtherPlayerAlive],Score).

determine_strategy('m',Colour,[A,B,MA,MB],[Alive,OtherPlayerAlive],Score) :-
    minimax_helper(Colour,[A,B,MA,MB],[Alive,OtherPlayerAlive],Score).

bloodlust_helper('b',Move,[Blues,Reds],Score) :-
    alter_board(Move,Blues,NewBlues),
    next_generation([NewBlues,Reds],[_,NewRedPositions]),
    length(NewRedPositions,Score).

bloodlust_helper('r',Move,[Reds,Blues],Score) :-
    alter_board(Move,Reds,NewReds),
    next_generation([Blues,NewReds],[NewBluePositions,_]),
    length(NewBluePositions,Score).

self_pres_helper('r',Move,[Reds,Blues],Score) :-
    alter_board(Move,Reds,NewReds),
    next_generation([Blues,NewReds],[_,NewRedPositions]),
    length(NewRedPositions,Score).

self_pres_helper('b',Move,[Blues,Reds],Score) :- 
    alter_board(Move,Blues,NewBlues),
    next_generation([NewBlues,Reds],[NewBluePositions,_]),
    length(NewBluePositions,Score).

land_grab_helper('r',Move,[Reds,Blues],Score) :-
    alter_board(Move,Reds,NewReds),
    next_generation([Blues,NewReds],[NewBluePositions,NewRedPositions]),
    length(NewBluePositions,OtherPlayerScore),
    length(NewRedPositions,OwnScore),
    Score is OwnScore - OtherPlayerScore.

land_grab_helper('b',Move,[Blues,Reds],Score) :-
    alter_board(Move,Blues,NewBlues),
    next_generation([NewBlues,Reds],[NewBluePositions,NewRedPositions]),
    length(NewBluePositions,OwnScore),
    length(NewRedPositions,OtherPlayerScore),
    Score is OwnScore - OtherPlayerScore.

minimax_helper('r',Move,[Reds,Blues],Score) :-
    alter_board(Move,Reds,NewReds),
    next_generation([Blues,NewReds],NewBoardState),
    land_grab('b',NewBoardState,FinalBoardState,_),
    next_generation(FinalBoardState,[FinalBluePositions,FinalRedPositions]),
    length(FinalBluePositions,OtherPlayerScore),
    length(FinalRedPositions,OwnScore),
    Score is OwnScore - OtherPlayerScore.

minimax_helper('b',Move,[Blues,Reds],Score) :-
    alter_board(Move,Blues,NewBlues),
    next_generation([NewBlues,Reds],NewBoardState),
    land_grab('r',NewBoardState,FinalBoardState,_),
    next_generation(FinalBoardState,[FinalBluePositions,FinalRedPositions]),
    length(FinalBluePositions,OwnScore),
    length(FinalRedPositions,OtherPlayerScore),
    Score is OwnScore - OtherPlayerScore.

