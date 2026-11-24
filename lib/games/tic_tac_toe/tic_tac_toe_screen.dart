import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../ui/victory/victory_dialog.dart';
import '../../ui/widgets/banner_ad_widget.dart';
import 'controllers/ttt_controller.dart';
import 'models/ttt_model.dart';

class TicTacToeScreen extends StatefulWidget {
  final bool vsAI;

  const TicTacToeScreen({super.key, this.vsAI = true});

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  late TttController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TttController(vsAI: widget.vsAI);
    _controller.addListener(_onUpdate);
  }

  void _onUpdate() {
    if (_controller.isGameOver && _controller.winResult != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final winnerPiece = _controller.winResult!.winner;
        final isDraw = winnerPiece == TttPiece.none;
        final winnerName = isDraw
            ? "Game Drawn!"
            : (winnerPiece == TttPiece.x ? "Player X" : (widget.vsAI ? "Computer (O)" : "Player O"));
        final winnerColor = winnerPiece == TttPiece.x ? const Color(0xFFE94560) : const Color(0xFF00ADB5);

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => VictoryDialog(
            winnerName: winnerName,
            winnerColor: isDraw ? Colors.amber : winnerColor,
            onPlayAgain: () => _controller.resetRound(),
            onHome: () => Navigator.of(context).pop(),
          ),
        );
      });
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final boardDim = (size.width - 48).clamp(280.0, 400.0);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vsAI ? 'Tic-Tac-Toe (Vs Computer)' : 'Tic-Tac-Toe (Pass & Play)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.resetRound(),
            tooltip: 'Reset Round',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Score Board
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildScoreItem("Player X", "${_controller.xScore}", const Color(0xFFE94560)),
                  _buildScoreItem("Ties", "${_controller.drawScore}", Colors.white54),
                  _buildScoreItem(
                    widget.vsAI ? "Computer (O)" : "Player O",
                    "${_controller.oScore}",
                    const Color(0xFF00ADB5),
                  ),
                ],
              ),
            ),

            // Turn Indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                _controller.currentTurn == TttPiece.x ? "Turn: Player X" : (widget.vsAI ? "Computer is thinking..." : "Turn: Player O"),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _controller.currentTurn == TttPiece.x ? const Color(0xFFE94560) : const Color(0xFF00ADB5),
                ),
              ),
            ),

            // 3x3 Grid
            Expanded(
              child: Center(
                child: Container(
                  width: boardDim,
                  height: boardDim,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F3460),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black45, blurRadius: 16, offset: Offset(0, 6)),
                    ],
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 9,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      final piece = _controller.board[index];
                      final isWinningCell = _controller.winResult?.winningPattern?.contains(index) ?? false;

                      return GestureDetector(
                        onTap: () => _controller.makeMove(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isWinningCell ? Colors.amber.withOpacity(0.3) : const Color(0xFF16213E),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isWinningCell ? Colors.amber : Colors.white12,
                              width: isWinningCell ? 3 : 1,
                            ),
                          ),
                          child: Center(
                            child: piece == TttPiece.none
                                ? const SizedBox.shrink()
                                : Text(
                                    piece == TttPiece.x ? 'X' : 'O',
                                    style: TextStyle(
                                      fontSize: boardDim * 0.16,
                                      fontWeight: FontWeight.w900,
                                      color: piece == TttPiece.x
                                          ? const Color(0xFFE94560)
                                          : const Color(0xFF00ADB5),
                                    ),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Bottom Banner Ad (Google AdMob Test ID)
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreItem(String label, String score, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(score, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
