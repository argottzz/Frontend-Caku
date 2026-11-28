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

  Future<User> updateProfile({String? nama, String? phoneNumber}) async {
    final body = <String, dynamic>{};
    if (nama != null && nama.trim().isNotEmpty) body['nama'] = nama.trim();
    if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
      body['phone_number'] = phoneNumber.trim();
    }
    final response = await _client.patch('/users/me', body: body);
    return User.fromJson(response.dataMap);
  }
}
