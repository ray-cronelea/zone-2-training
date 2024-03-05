import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static const String SIM_MODE = "SIM MODE";
  static final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  static saveSimMode(bool simMode) async {
    SharedPreferences pref = await _prefs;
    pref.setBool(SIM_MODE, simMode).then((value) => print('Did setBool write: $value'));
  }

  static Future<bool> isSimMode() async {
    SharedPreferences pref = await _prefs;
    bool? simMode = pref.getBool(SIM_MODE);

    print('Sim mode value read : $simMode');

    if (simMode != null) {
      return simMode;
    }

    print("No value read from saved preferences. Returning default");
    return false;
  }
}
