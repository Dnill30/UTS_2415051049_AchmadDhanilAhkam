import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile.dart';

class ProfileService {
  static const _kName = 'profile_name';
  static const _kNim = 'profile_nim';
  static const _kKelas = 'profile_kelas';
  static const _kBio = 'profile_bio';
  static const _kColor = 'profile_avatar_color';

  Future<Profile> read() async {
    final prefs = await SharedPreferences.getInstance();
    const d = Profile.defaultProfile;
    return Profile(
      name: prefs.getString(_kName) ?? d.name,
      nim: prefs.getString(_kNim) ?? d.nim,
      kelas: prefs.getString(_kKelas) ?? d.kelas,
      bio: prefs.getString(_kBio) ?? d.bio,
      avatarColor: prefs.getInt(_kColor) ?? d.avatarColor,
    );
  }

  Future<void> write(Profile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kName, profile.name);
    await prefs.setString(_kNim, profile.nim);
    await prefs.setString(_kKelas, profile.kelas);
    await prefs.setString(_kBio, profile.bio);
    await prefs.setInt(_kColor, profile.avatarColor);
  }
}