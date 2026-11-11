import 'package:shared_preferences/shared_preferences.dart';
class ProService {
  static const String _key = 'is_pro_wanalab';
  static bool _isPro = false;
  static bool get isPro => _isPro;
  static Future<void> init() async { final p = await SharedPreferences.getInstance(); _isPro = p.getBool(_key) ?? false; }
  static Future<void> setPro(bool v) async { _isPro = v; final p = await SharedPreferences.getInstance(); await p.setBool(_key, v); }
  static Future<void> enableProForTesting() async => await setPro(true);
  static Future<void> disableProForTesting() async => await setPro(false);
}
