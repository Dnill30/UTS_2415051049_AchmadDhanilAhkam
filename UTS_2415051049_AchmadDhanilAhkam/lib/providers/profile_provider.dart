import 'package:flutter/foundation.dart';

import '../models/profile.dart';
import '../repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository;

  ProfileProvider(this._repository);

  Profile _profile = Profile.defaultProfile;

  Profile get profile => _profile;

  Future<void> load() async {
    try {
      _profile = await _repository.getProfile();
    } catch (e) {
      debugPrint('profile load error: $e');
    }
    notifyListeners();
  }

  /// Mengembalikan null jika berhasil, atau pesan error jika gagal.
  Future<String?> save(Profile profile) async {
    try {
      await _repository.saveProfile(profile);
      _profile = profile;
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('profile save error: $e');
      return 'Gagal menyimpan profile.';
    }
  }
}