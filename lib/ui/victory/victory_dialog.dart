import 'package:flutter/material.dart';
import '../../core/ads/ad_helper.dart';
import '../../core/audio/sound_service.dart';

class VictoryDialog extends StatelessWidget {
  final String winnerName;
  final Color winnerColor;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  const VictoryDialog({
    super.key,
    required this.winnerName,
    required this.winnerColor,
    required this.onPlayAgain,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    SoundService().playVictory();

    return WillPopScope(
      onWillPop: () async => false, // Prevent accidental dismissal
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFF16213E),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: winnerColor.withOpacity(0.2),
                  border: Border.all(color: winnerColor, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: winnerColor.withOpacity(0.5),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Color(0xFFFFD700),
                  size: 54,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'VICTORY!',
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$winnerName Wins The Game!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.home, color: Colors.white70),
                      label: const Text('Menu', style: TextStyle(color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        // Strict Ad Policy: Show interstitial video test ad on match finish
                        AdHelper().showMatchEndInterstitial(onAdClosed: () {
                          Navigator.of(context).pop();
                          onHome();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.replay, color: Colors.white),
                      label: const Text('Play Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE94560),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        AdHelper().showMatchEndInterstitial(onAdClosed: () {
                          Navigator.of(context).pop();
                          onPlayAgain();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
