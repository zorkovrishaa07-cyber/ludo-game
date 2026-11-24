import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../ui/victory/victory_dialog.dart';
import '../../ui/widgets/banner_ad_widget.dart';
import '../ludo/widgets/dice_widget.dart';
import 'controllers/snake_ladder_controller.dart';
import 'widgets/snake_board_painter.dart';

class SnakeLadderScreen extends StatefulWidget {
  final int playerCount;
  final bool vsAI;

  const SnakeLadderScreen({
    super.key,
    this.playerCount = 2,
    this.vsAI = true,
  });

  @override
  State<SnakeLadderScreen> createState() => _SnakeLadderScreenState();
}

class _SnakeLadderScreenState extends State<SnakeLadderScreen> {
  late SnakeLadderController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SnakeLadderController(
      playerCount: widget.playerCount,
      vsAI: widget.vsAI,
    );
    _controller.addListener(_onUpdate);
  }

  void _onUpdate() {
    if (_controller.isGameOver && _controller.winner != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => VictoryDialog(
            winnerName: _controller.winner!.name,
            winnerColor: _controller.winner!.color,
            onPlayAgain: () => _controller.resetGame(),
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
    final currentPlayer = _controller.currentPlayer;
    final boardSize = MediaQuery.of(context).size.width.clamp(300.0, 480.0) - 24;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Snakes & Ladders (1-100)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.resetGame(),
            tooltip: 'Restart Game',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Status & Turn header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: currentPlayer.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: currentPlayer.color, width: 2),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: currentPlayer.color,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Turn: ${currentPlayer.name} (Position: ${currentPlayer.position}/100)",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _controller.statusMessage,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Board
            Expanded(
              child: Center(
                child: Container(
                  width: boardSize,
                  height: boardSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(color: Colors.black45, blurRadius: 16, offset: Offset(0, 6)),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CustomPaint(
                    painter: SnakeBoardPainter(controller: _controller),
                  ),
                ),
              ),
            ),

            // Bottom Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentPlayer.isAI ? "Bot is rolling dice..." : "Tap dice to roll!",
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Reach 100 exactly to win!",
                        style: TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                  DiceWidget(
                    value: _controller.currentDiceValue,
                    isRolling: _controller.isRolling,
                    canRoll: !_controller.isRolling && !_controller.isMoving && !currentPlayer.isAI && !_controller.isGameOver,
                    activeColor: currentPlayer.color,
                    onTap: () => _controller.rollDice(),
                  ),
                ],
              ),
            ),

            // Google AdMob Persistent Banner Ad
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }
}
