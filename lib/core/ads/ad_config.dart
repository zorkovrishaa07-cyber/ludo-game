/// Google AdMob Configuration
///
/// Set [isTestMode] to `true` while developing/testing.
/// Set [isTestMode] to `false` and enter your real AdMob Ad Unit IDs before uploading to Play Store.
class AdConfig {
  // Toggle between Test Ads and Production Live Ads
  static const bool isTestMode = true;

  // Google AdMob Official Test IDs (Do NOT change these)
  static const String testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String testRewardedId = 'ca-app-pub-3940256099942544/5224354917';
  static const String testAppId = 'ca-app-pub-3940256099942544~3347511713';

  // ===========================================================================
  // PRODUCTION LIVE AD IDs (Replace these with your actual IDs from admob.com)
  // ===========================================================================
  static const String prodBannerId = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
  static const String prodInterstitialId = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
  static const String prodRewardedId = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
  static const String prodAppId = 'ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY';

  // Get active Banner ID
  static String get bannerAdUnitId => isTestMode ? testBannerId : prodBannerId;

  // Get active Interstitial Video ID
  static String get interstitialAdUnitId => isTestMode ? testInterstitialId : prodInterstitialId;

  // Get active Rewarded Video ID
  static String get rewardedAdUnitId => isTestMode ? testRewardedId : prodRewardedId;
}
