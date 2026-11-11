class ProService {
  static bool isPro = false;

  // CALL THIS IN main() FOR TESTING ONLY
  static void enableProForTesting() {
    isPro = true;
    print("WanaLab Pro ENABLED for testing - Wana, Waziristan");
  }

  static bool get isProUser => isPro;
}
