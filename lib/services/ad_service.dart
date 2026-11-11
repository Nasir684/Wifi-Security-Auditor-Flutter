import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';

class AdService {
  static RewardedAd? _rewardedAd;
  static bool _isLoading = false;
  static const String rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917'; // TEST ID - replace before release

  static Future<void> init() async {
    await MobileAds.instance.initialize();
    loadRewardedAd();
  }

  static void loadRewardedAd() {
    if (_isLoading) return; _isLoading = true;
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) { _rewardedAd = ad; _isLoading = false; },
        onAdFailedToLoad: (error) { _isLoading = false; Future.delayed(const Duration(seconds: 5), loadRewardedAd); },
      ),
    );
  }

  static Future<bool> showRewardedAd({required Function onRewarded}) async {
    if (_rewardedAd == null) { loadRewardedAd(); return false; }
    Completer<bool> completer = Completer<bool>();
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) { ad.dispose(); loadRewardedAd(); if (!completer.isCompleted) completer.complete(false); },
      onAdFailedToShowFullScreenContent: (ad, error) { ad.dispose(); loadRewardedAd(); if (!completer.isCompleted) completer.complete(false); },
    );
    _rewardedAd!.show(onUserEarnedReward: (ad, reward) { onRewarded(); if (!completer.isCompleted) completer.complete(true); });
    _rewardedAd = null;
    return completer.future;
  }
}
