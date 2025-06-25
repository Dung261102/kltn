// lib/controllers/user_controller.dart
import 'package:get/get.dart';
import 'dart:typed_data';

class UserController extends GetxController {
  var username = ''.obs;
  var avatarPath = 'assets/images/profile/avatar.jpg'.obs;
  var avatarBytes = Rx<Uint8List?>(null);

  void setUsername(String name) => username.value = name;
  void setAvatarPath(String path) {
    avatarPath.value = path;
    avatarBytes.value = null;
  }
  void setAvatarBytes(Uint8List? bytes) {
    avatarBytes.value = bytes;
    avatarPath.value = '';
  }
}