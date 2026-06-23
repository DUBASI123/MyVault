import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/student_model.dart';
import '../constants/app_constants.dart';

class AppStorage {
  AppStorage._();
  static final AppStorage instance = AppStorage._();

  final _secure = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _secure.write(key: AppConstants.tokenKey, value: token);
  }

  Future<String?> getToken() => _secure.read(key: AppConstants.tokenKey);

  Future<void> saveStudent(StudentModel student) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.studentKey, jsonEncode(student.toJson()));
    await prefs.setBool(AppConstants.loggedInKey, true);
    if (student.collegeLogoUrl != null) {
      await prefs.setString(AppConstants.collegeLogoKey, student.collegeLogoUrl!);
    }
  }

  Future<StudentModel?> getStudent() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConstants.studentKey);
    if (raw == null) return null;
    return StudentModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.loggedInKey) ?? false;
  }

  Future<String?> getCollegeLogo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.collegeLogoKey);
  }

  Future<void> clearSession() async {
    await _secure.delete(key: AppConstants.tokenKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.studentKey);
    await prefs.remove(AppConstants.collegeLogoKey);
    await prefs.setBool(AppConstants.loggedInKey, false);
  }
}
