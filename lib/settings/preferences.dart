import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static const String BOOL_SIM_MODE = "SIM MODE";
  static const String INT_MAX_HEARTRATE = "MAX HEART RATE";
  static const String INT_MAX_POWER_SETPOINT = "MAX POWER SETPOINT RATE";

  static final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  static saveSimMode(bool simMode) async {
    SharedPreferences pref = await _prefs;
    pref.setBool(BOOL_SIM_MODE, simMode).then((value) => print('saveSimMode was successful: $value'));
  }

  static saveMaxHeartRate(int maxHeartRate) async {
    SharedPreferences pref = await _prefs;
    pref.setInt(INT_MAX_HEARTRATE, maxHeartRate).then((value) => print('saveMaxHeartRate was successful: $value'));
  }

  static Future<bool> isSimMode() async {
    SharedPreferences pref = await _prefs;
    bool? simMode = pref.getBool(BOOL_SIM_MODE);

    print('Sim mode value read : $simMode');

    if (simMode != null) {
      return simMode;
    }

    print("No value read from saved preferences. Returning default");
    return false;
  }

  static Future<int> getMaxHeartRate() async {
    SharedPreferences pref = await _prefs;
    int? maxHeartRate = pref.getInt(INT_MAX_HEARTRATE);

    print('INT_MAX_HEARTRATE value read : $maxHeartRate');

    if (maxHeartRate != null) {
      return maxHeartRate;
    }

    print("No value read from saved preferences. Returning default");
    return 180;
  }

  static Future<int> getMaxPowerSetpoint() async {
    SharedPreferences pref = await _prefs;
    int? maxPowerSetpoint = pref.getInt(INT_MAX_POWER_SETPOINT);

    print('INT_MAX_POWER_SETPOINT value read : $maxPowerSetpoint');

    if (maxPowerSetpoint != null) {
      return maxPowerSetpoint;
    }

    print("No value read from saved preferences. Returning default");
    return 280;
  }

  static saveMaxPowerSetpoint(int maxPowerSetpoint) async {
    SharedPreferences pref = await _prefs;
    pref.setInt(INT_MAX_POWER_SETPOINT, maxPowerSetpoint).then((value) => print('saveMaxPowerSetpoint was successful: $value'));
  }


}
