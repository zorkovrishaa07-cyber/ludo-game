import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../ui/victory/victory_dialog.dart';
import '../../ui/widgets/banner_ad_widget.dart';
import 'controllers/ludo_controller.dart';
import 'models/ludo_models.dart';
import 'widgets/dice_widget.dart';
import 'widgets/ludo_board_painter.dart';

class LudoGameScreen extends StatefulWidget {
  final int playerCount;
  final bool vsAI;
  final bool isQuickRush;

  const LudoGameScreen({
    super.key,
    this.playerCount = 4,
    this.vsAI = true,
    this.isQuickRush = false,
  });

  @override
  State<LudoGameScreen> createState() => _LudoGameScreenState();
}

class _LudoGameScreenState extends State<LudoGameScreen> with SingleTickerProviderStateMixin {
  late LudoController _controller;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _controller = LudoController(
      playerCount: widget.playerCount,
      vsAI: widget.vsAI,
      isQuickRush: widget.isQuickRush,
    );
    _controller.addListener(_onControllerUpdate);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  void _onControllerUpdate() {
    if (_controller.isGameOver && _controller.winner != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => VictoryDialog(
            winnerName: _controller.winner!.name,
            winnerColor: _controller.winner!.displayColor,
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
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleBoardTap(Offset localPos, double boardSize) {
    if (_controller.movableTokens.isEmpty || _controller.currentPlayer.isAI) return;

    final double cellSize = boardSize / 15.0;

    // Check which movable token was clicked
    for (final token in _controller.movableTokens) {
      Offset tokenPos;
      if (token.isAtBase) {
        final slots = LudoPathData.getBaseSlots(token.color);
        final slot = slots[token.id % slots.length];
        tokenPos = Offset(slot.y * cellSize + cellSize / 2, slot.x * cellSize + cellSize / 2);
      } else if (token.isInHomeStretch) {
        final cell = LudoPathData.getHomeColumn(token.color)[token.step - 51];
        tokenPos = Offset(cell.y * cellSize + cellSize / 2, cell.x * cellSize + cellSize / 2);
      } else {
        final globalIdx = (LudoPathData.getStartOffset(token.color) + token.step) % 52;
        final cell = LudoPathData.commonPath[globalIdx];
        tokenPos = Offset(cell.y * cellSize + cellSize / 2, cell.x * cellSize + cellSize / 2);
      }

      if ((localPos - tokenPos).distance <= cellSize * 0.7) {
        _controller.moveToken(token);
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPlayer = _controller.currentPlayer;
    final boardSize = MediaQuery.of(context).size.width.clamp(300.0, 480.0) - 24;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isQuickRush ? 'Ludo Quick Rush (2 Tokens)' : 'Classic Ludo (4 Tokens)'),
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
            // Current Player Turn Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: currentPlayer.displayColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: currentPlayer.displayColor, width: 2),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: currentPlayer.displayColor,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Turn: ${currentPlayer.name}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (_controller.consecutiveSixes > 0)
                    Text(
                      "Sixes: ${_controller.consecutiveSixes}/2",
                      style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),

            // Ludo Board
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTapUp: (details) => _handleBoardTap(details.localPosition, boardSize),
                  child: Container(
                    width: boardSize,
                    height: boardSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Colors.black45, blurRadius: 16, offset: Offset(0, 6)),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: CustomPaint(
                      painter: LudoBoardPainter(
                        controller: _controller,
                        pulseAnimation: _pulseController,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Controls & Dice
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _controller.hasRolledDice
                            ? (_controller.movableTokens.isEmpty ? "No valid moves!" : "Tap a glowing token to move")
                            : (currentPlayer.isAI ? "Bot is rolling..." : "Tap dice to roll!"),
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Goal: ${_controller.isQuickRush ? '2 tokens to win' : '4 tokens to win'}",
                        style: const TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                  DiceWidget(
                    value: _controller.currentDiceValue,
                    isRolling: _controller.isDiceRolling,
                    canRoll: !_controller.hasRolledDice && !currentPlayer.isAI && !_controller.isGameOver,
                    activeColor: currentPlayer.displayColor,
                    onTap: () => _controller.rollDice(),
                  ),
                ],
              ),
            ),

            // Persistent Bottom Banner Ad (Google AdMob Test ID)
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }
}
