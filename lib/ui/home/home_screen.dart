import 'package:flutter/material.dart';
import '../../core/audio/sound_service.dart';
import '../../core/theme/app_theme.dart';
import '../../games/ludo/ludo_game_screen.dart';
import '../../games/snake_ladder/snake_ladder_screen.dart';
import '../../games/tic_tac_toe/tic_tac_toe_screen.dart';
import '../widgets/banner_ad_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Board Games Arcade'),
        actions: [
          IconButton(
            icon: Icon(
              SoundService().soundEnabled ? Icons.volume_up : Icons.volume_off,
              color: Colors.white70,
            ),
            onPressed: () async {
              await SoundService().toggleSound();
              setState(() {});
            },
            tooltip: 'Toggle Sound Effects',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Welcome Header
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE94560), Color(0xFF0F3460)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.casino, size: 36, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Multi-Casual Games',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Pass & Play offline or play vs Smart AI',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Game Cards List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildGameCard(
                    title: 'Ludo Classic (4 Tokens)',
                    subtitle: 'Full traditional board experience for 2-4 players',
                    icon: Icons.grid_view_rounded,
                    gradient: const [Color(0xFFE53935), Color(0xFFC62828)],
                    onPlayVsAI: () => _openScreen(const LudoGameScreen(playerCount: 4, vsAI: true, isQuickRush: false)),
                    onPlayPassAndPlay: () => _openScreen(const LudoGameScreen(playerCount: 4, vsAI: false, isQuickRush: false)),
                  ),
                  const SizedBox(height: 12),
                  _buildGameCard(
                    title: 'Ludo Quick Rush (2 Tokens)',
                    subtitle: 'Fast-paced 5-minute intense match',
                    icon: Icons.electric_bolt_rounded,
                    gradient: const [Color(0xFFFF8F00), Color(0xFFEF6C00)],
                    onPlayVsAI: () => _openScreen(const LudoGameScreen(playerCount: 4, vsAI: true, isQuickRush: true)),
                    onPlayPassAndPlay: () => _openScreen(const LudoGameScreen(playerCount: 4, vsAI: false, isQuickRush: true)),
                  ),
                  const SizedBox(height: 12),
                  _buildGameCard(
                    title: 'Snakes & Ladders',
                    subtitle: 'Classic 1 to 100 zigzag board adventure',
                    icon: Icons.stairs_rounded,
                    gradient: const [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                    onPlayVsAI: () => _openScreen(const SnakeLadderScreen(playerCount: 2, vsAI: true)),
                    onPlayPassAndPlay: () => _openScreen(const SnakeLadderScreen(playerCount: 2, vsAI: false)),
                  ),
                  const SizedBox(height: 12),
                  _buildGameCard(
                    title: 'Tic-Tac-Toe',
                    subtitle: 'Quick 1-minute brain duel (X vs O)',
                    icon: Icons.close_rounded,
                    gradient: const [Color(0xFF00ADB5), Color(0xFF393E46)],
                    onPlayVsAI: () => _openScreen(const TicTacToeScreen(vsAI: true)),
                    onPlayPassAndPlay: () => _openScreen(const TicTacToeScreen(vsAI: false)),
                  ),
                  const SizedBox(height: 16),
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

  void _openScreen(Widget screen) {
    SoundService().playClick();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  Widget _buildGameCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onPlayVsAI,
    required VoidCallback onPlayPassAndPlay,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.people, size: 18),
                  label: const Text('Pass & Play', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: onPlayPassAndPlay,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.smart_toy, size: 18),
                  label: const Text('Vs Computer', style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE94560),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: onPlayVsAI,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
