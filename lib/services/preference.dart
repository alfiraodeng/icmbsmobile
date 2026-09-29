import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_model.dart';
import '../models/profile_model.dart';

class PreferenceService {
  static Future<SharedPreferences> get _instance async =>
      prefs ??= await SharedPreferences.getInstance();
  static SharedPreferences? prefs;

  static Future<SharedPreferences> init() async {
    prefs = await _instance;
    return prefs ?? await SharedPreferences.getInstance();
  }

  static Future<void> setAuth(AuthModel auth) async {
    await prefs?.setString('authJson', jsonEncode(auth.toJson()));
  }

  static Future<void> setProfile(ProfileModel profile) async {
    await prefs?.setString('profileJson', jsonEncode(profile.toJson()));
  }

  static Future<void> setProfilePict(String pict) async {
    ProfileModel? profile = getProfile();
    if (profile != null) {
      profile.foto = pict;
      await setProfile(profile);
    }
  }

  static Future<void> setUserPassword(String user, String pswd) async {
    await prefs?.setString('userLogin', user);
    await prefs?.setString('pswdLogin', pswd);
  }

  static Future<void> setDataSync(Map<String, dynamic> master) async {
    await prefs?.setString('dataSync', jsonEncode(master));
  }

  static Future<void> setNotif(int total) async {
    await prefs?.setInt('notif', total);
  }

  static String? getUser() {
    return prefs?.getString('userLogin');
  }

  static String? getPassword() {
    return prefs?.getString('pswdLogin');
  }

  static Future<void> removeAuth() async {
    await prefs?.remove('authJson');
  }

  static Future<void> removeProfile() async {
    await prefs?.remove('profileJson');
  }

  static AuthModel? getAuth() {
    String? auth = prefs?.getString('authJson');
    if (auth != null) {
      return AuthModel.fromJson(jsonDecode(auth));
    }
    return null;
  }

  static ProfileModel? getProfile() {
    String? profile = prefs?.getString('profileJson');
    if (profile != null) {
      return ProfileModel.fromJson(jsonDecode(profile));
    }
    return null;
  }

  static Map<String, dynamic>? getDataSync() {
    String? master = prefs?.getString('dataSync');
    if (master != null) {
      return jsonDecode(master) as Map<String, dynamic>;
    }
    return null;
  }

  static int getNotif() {
    return prefs?.getInt('notif') ?? 0;
  }
}
