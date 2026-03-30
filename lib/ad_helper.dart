import 'dart:io';

class AdHelper {
  // App ID
  static String get appId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-6210141361081782~7373955180';
    } else {
      return 'ca-app-pub-3940256099942544~1458002511'; // iOS test ID
    }
  }

  // Banner Ad Unit ID
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-6210141361081782/9029817634';
    } else {
      return 'ca-app-pub-3940256099942544/2934735716'; // iOS test ID
    }
  }

  // Interstitial Ad Unit ID
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-6210141361081782/1192670150';
    } else {
      return 'ca-app-pub-3940256099942544/4411468910'; // iOS test ID
    }
  }
}