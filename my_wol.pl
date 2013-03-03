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


max(A, B, A) :-
A >= B.

max(A, B, B) :-
A < B.

min(A, B, A) :-
A =< B.

min(A, B, B) :-
A > B.

/*min(Shortest, NumberOfMovesInput, Shortest1),

bloodlust(PlayerColour, CurrentBoardState, NewBoardState, Move) :-

.

self_preservation(PlayerColour, CurrentBoardState, NewBoardState, Move) :-

.

land_grab(PlayerColour, CurrentBoardState, NewBoardState, Move) :-

.

minimax(PlayerColour, CurrentBoardState, NewBoardState, Move) :-

.
*/
