enum TttPiece { none, x, o }

class TttWinResult {
  final TttPiece winner;
  final List<int>? winningPattern; // e.g. [0, 1, 2]

  const TttWinResult({required this.winner, this.winningPattern});
}
