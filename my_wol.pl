test_strategy(N, FirstPlayerStrategy, SecondPlayerStrategy) :-
test_strategy_counter(N, FirstPlayerStrategy, SecondPlayerStrategy, 0, 0, 0, 0, 0, 0, 0, 0)
.


/*finish print*/
test_strategy_counter(0, FirstPlayerStrategy, SecondPlayerStrategy, GamesPlayed, NumberOfMovesInput, Draws, P1, P2, Longest, Shortest, Average) :-
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
write(Average)
.


/*first game*/
test_strategy_counter(N, FirstPlayerStrategy, SecondPlayerStrategy, 0, NumberOfMovesInput, Draws, P1, P2, Longest, Shortest, Average) :-
play(quiet, FirstPlayerStrategy, SecondPlayerStrategy, NumberOfMoves, WinningPlayer),
N1 is N-1,
(WinningPlayer == b ->
    P1Next is P1+1,
    P2Next is P2
;   P2Next is P2+1,
    P1Next is P1
),
test_strategy_counter(N1, FirstPlayerStrategy, SecondPlayerStrategy, 1, NumberOfMoves, Draws, P1Next, P2Next, NumberOfMoves, NumberOfMoves, NumberOfMoves)
.

/*draw*/
test_strategy_counter(N, FirstPlayerStrategy, SecondPlayerStrategy, GamesPlayed, 250, Draws, P1, P2, Longest, Shortest, Average) :-
play(quiet, FirstPlayerStrategy, SecondPlayerStrategy, NumberOfMoves, WinningPlayer),
N1 is N-1,
GamesPlayed1 is GamesPlayed+1,
DrawsNext is Draws+1,
max(Longest, 250, Longest1),
min(Shortest, 250, Shortest1),
P1Next is P1+1,
P2Next is P2+1,
AverageNext is (((Average*GamesPlayed)+NumberOfMoves)/GamesPlayed1),
test_strategy_counter(N1, FirstPlayerStrategy, SecondPlayerStrategy, GamesPlayed1, NumberOfMoves, DrawsNext, P1Next, P2Next, Longest1, Shortest1, AverageNext)
.

/*blue or red*/
test_strategy_counter(N, FirstPlayerStrategy, SecondPlayerStrategy, GamesPlayed, NumberOfMovesInput, Draws, P1, P2, Longest, Shortest, Average) :-
play(quiet, FirstPlayerStrategy, SecondPlayerStrategy, NumberOfMoves, WinningPlayer),
N1 is N-1,
GamesPlayed1 is GamesPlayed+1,
max(Longest, NumberOfMoves, Longest1),
min(Shortest, NumberOfMoves, Shortest1),
(WinningPlayer == b ->
    P1Next is P1+1,
    P2Next is P2
;   P2Next is P2+1,
    P1Next is P1
),
AverageNext is (((Average*GamesPlayed)+NumberOfMoves)/GamesPlayed1),
test_strategy_counter(N1, FirstPlayerStrategy, SecondPlayerStrategy, GamesPlayed1, NumberOfMoves, Draws, P1Next, P2Next, Longest1, Shortest1, AverageNext)
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bloodlust_helper(Alive, OtherPlayerAlive, Move) :-
 findall([A,B,MA,MB],(member([A,B], Alive),
                      neighbour_position(A,B,[MA,MB]),
	              \+member([MA,MB],Alive),
	              \+member([MA,MB],OtherPlayerAlive)),
	 PossMoves),
nth0(X, PossMoves, Move),
alter_board(Move, Alive, NewAlive),
next_generation([NewAlive,OtherPlayerAlive], [Other,OtherPlayerNewAlive]),
length(OtherPlayerNewAlive, L1),
forall(member(WorseMove, PossMoves), 
(alter_board(WorseMove, Alive, WorseNewAlive),
next_generation([WorseNewAlive,OtherPlayerAlive], [Other2,WorseOtherPlayerNewAlive]),
length(WorseOtherPlayerNewAlive, L2),
L1 =< L2))
.


getAlive(Colour, [A|[B]], Alive, OtherPlayerAlive):-
(Colour == b ->
    Alive = A,
    OtherPlayerAlive = B
;   Alive = B,
    OtherPlayerAlive = A
)
.

% [[1,1],[2,6],[3,4],[3,5],[3,8],[4,1],[4,2],[5,7],[6,2],[7,1],[7,3],[7,5]]

% [[1,8],[2,2],[2,8],[3,7],[4,6],[5,3],[6,6],[7,6],[7,7],[7,8],[8,3],[8,7]]

% [[2,2],[2,3],[3,3]]

% [[1,1]]



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
 findall([A,B,MA,MB],(member([A,B], Alive),
                      neighbour_position(A,B,[MA,MB]),
	              \+member([MA,MB],Alive),
	              \+member([MA,MB],OtherPlayerAlive)),
	 PossMoves),
nth0(X, PossMoves, Move),
alter_board(Move, Alive, NewAlive),
next_generation([NewAlive,OtherPlayerAlive], [OtherPlayerNewAlive, Other]),
length(OtherPlayerNewAlive, L1),
forall(member(WorseMove, PossMoves), 
(alter_board(WorseMove, Alive, WorseNewAlive),
next_generation([WorseNewAlive,OtherPlayerAlive], [WorseOtherPlayerNewAlive, Other2]),
length(WorseOtherPlayerNewAlive, L2),
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

list_size_diff(List1, List2, Size) :-
length(List1, L1),
length(List2, L2),
Size = (L1 - L2).

land_grab(Alive, OtherPlayerAlive, Move) :-
 findall([A,B,MA,MB],(member([A,B], Alive),
                      neighbour_position(A,B,[MA,MB]),
	              \+member([MA,MB],Alive),
	              \+member([MA,MB],OtherPlayerAlive)),
	 PossMoves),
nth0(X, PossMoves, Move),
alter_board(Move, Alive, NewAlive),
next_generation([NewAlive,OtherPlayerAlive], [NextGen,OtherNextGen]),
list_size_diff(NextGen, OtherNextGen, Size1),
forall(member(WorseMove, PossMoves), 
(alter_board(WorseMove, Alive, WorseNewAlive),
next_generation([WorseNewAlive,OtherPlayerAlive], [NextGen2,OtherNextGen2]),
list_size_diff(NextGen2, OtherNextGen2, Size2),
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



