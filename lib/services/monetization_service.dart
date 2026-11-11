import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// WanaLab Monetization - Free tier with Ads, Pro $4.99
/// Test IDs - Replace with your real IDs before Play Store publish
class MonetizationService {
  // TEST IDs (Google official) - Replace before release
  static const String _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  // PRODUCTION IDs - TODO: Replace when you get AdMob approval
  // static const String _bannerAdUnitId = 'ca-app-pub-YOUR_ID/XXXX';
  // static const String _interstitialAdUnitId = 'ca-app-pub-YOUR_ID/XXXX';
  // static const String _rewardedAdUnitId = 'ca-app-pub-YOUR_ID/XXXX';

  static final MonetizationService _instance = MonetizationService._internal();
  factory MonetizationService() => _instance;
  MonetizationService._internal();

  bool _isPro = false;
  bool _isInitialized = false;

  bool get isPro => _isPro;

  Future<void> initialize() async {
    if (_isInitialized) return;
    final prefs = await SharedPreferences.getInstance();
    _isPro = prefs.getBool('wanalab_is_pro') ?? false;
    _isInitialized = true;
    
    // Initialize AdMob
    await MobileAds.instance.initialize();
  }

  Future<void> setPro(bool value) async {
    _isPro = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('wanalab_is_pro', value);
  }

  // For testing Pro UI without purchase
  Future<void> enableProForTesting() async {
    await setPro(true);
  }

  Future<void> disableProForTesting() async {
    await setPro(false);
  }

  BannerAd createBanner() => BannerAd(
        adUnitId: _bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: const BannerAdListener(),
      );

  Future<void> showInterstitialAfterScan() async {
    await initialize();
    if (isPro) return;

    await InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) => ad.dispose(),
            onAdFailedToShowFullScreenContent: (ad, _) => ad.dispose(),
          );
          ad.show();
        },
        onAdFailedToLoad: (error) {
          // print('Interstitial failed: $error');
        },
      ),
    );
  }

  Future<bool> showRewardedForPdf(Future<void> Function() onReward) async {
    await initialize();
    if (isPro) {
      await onReward();
      return true;
    }

    final completer = Completer<bool>();
    await RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          var rewarded = false;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              if (!completer.isCompleted) completer.complete(rewarded);
            },
            onAdFailedToShowFullScreenContent: (ad, _) {
              ad.dispose();
              if (!completer.isCompleted) completer.complete(false);
            },
          );
          ad.show(onUserEarnedReward: (_, __) async {
            rewarded = true;
            try {
              await onReward();
            } catch (_) {
              rewarded = false;
            }
          });
        },
        onAdFailedToLoad: (error) {
          if (!completer.isCompleted) completer.complete(false);
        },
      ),
    );
    return completer.future;
  }

  String get proPrice => '\$4.99';
  String get proFeatures => 'No Ads, No Watermark, Unlimited Pro Reports - WanaLab';
}
