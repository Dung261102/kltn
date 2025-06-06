//Chứa logic chuyển đổi giữa light/dark theme

import 'package:flutter/material.dart';
//thư viện get_storage - thư viện lưu trữ cục bộ (local storage) - sqlite
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart'; //thư viện dart

class ThemeService {
  final _box = GetStorage();
  final _key = "isDarkMode";

  _saveThemeToBox(bool isDarkMode) => _box.write(_key, isDarkMode);

  bool _loadThemeFromBox() => _box.read(_key) ?? false;
  ThemeMode get theme => _loadThemeFromBox() ? ThemeMode.dark : ThemeMode.light;
  void switchTheme() {
    Get.changeThemeMode(_loadThemeFromBox() ? ThemeMode.light : ThemeMode.dark);
    _saveThemeToBox(!_loadThemeFromBox());
  }
}
