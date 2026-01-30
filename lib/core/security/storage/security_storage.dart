import 'package:shared_preferences/shared_preferences.dart';

import '../rasp/rasp_threat_type.dart';

class SecurityStorage {
  static const _keyThreat = 'security_blocked_threat';

  /// บันทึกว่า block เพราะ threat อะไร
  static Future<void> markBlocked(RaspThreatType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThreat, type.name);
  }

  /// อ่าน threat ที่เคย block ไว้
  static Future<RaspThreatType?> getBlockedThreat() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_keyThreat);
    if (value == null) return null;

    for (final t in RaspThreatType.values) {
      if (t.name == value) return t;
    }
    return null; // ← ถ้า enum เปลี่ยนในอนาคต
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyThreat);
  }
}
