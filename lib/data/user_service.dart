import '../core/network/api_client.dart';
import '../models/user.dart';

class UserService {
  UserService(this._client);

  final ApiClient _client;

  Future<User> updateProfileImage(FileUpload file) async {
    final response = await _client.patchMultipart(
      '/users/me/profile-image',
      fields: const {},
      files: {'profile_image': file},
    );
    return User.fromJson(response.dataMap);
  }

  Future<User> removeProfileImage() async {
    final response = await _client.delete('/users/me/profile-image');
    return User.fromJson(response.dataMap);
  }
}
