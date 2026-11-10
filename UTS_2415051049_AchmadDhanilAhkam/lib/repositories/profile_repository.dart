import '../models/profile.dart';
import '../services/profile_service.dart';

class ProfileRepository {
  final ProfileService _service;

  ProfileRepository(this._service);

  Future<Profile> getProfile() => _service.read();

  Future<void> saveProfile(Profile profile) => _service.write(profile);
}