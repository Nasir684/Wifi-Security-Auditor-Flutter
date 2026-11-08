import 'package:shared_preferences/shared_preferences.dart';

/// Stores the user's explicit ownership confirmation locally on this device.
class OwnershipService {
  static const String _keyPrefix = 'owned_network_';

  static Future<void> saveOwnership(String bssid) async {
    final normalizedBssid = bssid.trim().toLowerCase();
    if (normalizedBssid.isEmpty) return;

    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(
      '$_keyPrefix$normalizedBssid',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<bool> hasOwnershipConfirmation(String bssid) async {
    final normalizedBssid = bssid.trim().toLowerCase();
    if (normalizedBssid.isEmpty) return false;

    final preferences = await SharedPreferences.getInstance();
    return preferences.containsKey('$_keyPrefix$normalizedBssid');
  }
}
