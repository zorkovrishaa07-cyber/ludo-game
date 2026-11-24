import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_config.dart';

class AdHelper {
  static final AdHelper _instance = AdHelper._internal();
  factory AdHelper() => _instance;
  AdHelper._internal();

  static String get bannerAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) return AdConfig.bannerAdUnitId;
    return '';
  }

  static String get interstitialAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) return AdConfig.interstitialAdUnitId;
    return '';
  }

  static String get rewardedAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) return AdConfig.rewardedAdUnitId;
    return '';
  }

  bool _isInitialized = false;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;

  /// Initialize Google Mobile Ads SDK safely
  Future<void> initialize() async {
    if (kIsWeb) return;
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      preloadInterstitialAd();
    } catch (e) {
      debugPrint('AdMob initialization error: $e');
    }
  }

  /// Preload Interstitial Ad so it's ready for Match-End
  void preloadInterstitialAd() {
    if (kIsWeb || !_isInitialized || _isInterstitialLoading || _interstitialAd != null) {
      return;
    }

    _isInterstitialLoading = true;
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
          debugPrint('Interstitial Ad preloaded successfully.');
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isInterstitialLoading = false;
          debugPrint('Interstitial Ad failed to preload: ${error.message}');
        },
      ),
    );
  }

  /// Show Match-End Interstitial Ad
  /// STRICT POLICY: Never called during active gameplay, ONLY on victory/game over
  void showMatchEndInterstitial({VoidCallback? onAdClosed}) {
    if (kIsWeb || _interstitialAd == null) {
      onAdClosed?.call();
      preloadInterstitialAd();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        preloadInterstitialAd();
        onAdClosed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        preloadInterstitialAd();
        onAdClosed?.call();
      },
    );

    _interstitialAd!.show();
  }
}
