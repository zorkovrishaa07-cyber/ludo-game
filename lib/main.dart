import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/ads/ad_helper.dart';
import 'core/audio/sound_service.dart';
import 'core/theme/app_theme.dart';
import 'ui/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for optimal board game layout
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Sound Service
  await SoundService().init();

  // Initialize Google Mobile Ads SDK (AdMob)
  await AdHelper().initialize();

  runApp(const LudoMultiGamesApp());
}

class LudoMultiGamesApp extends StatelessWidget {
  const LudoMultiGamesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ludo & Casual Games Bundle',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
