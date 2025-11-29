import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthManager extends ChangeNotifier {
  static final AuthManager _instance = AuthManager._internal();
  factory AuthManager() => _instance;
  AuthManager._internal();

  String? _username;
  String? _role;
  String? _userId;
  String? _themeOverride;
  
  // New profile fields
  String? _fullName;
  String? _absentNumber;
  String? _className;
  String? _dateOfBirth;
  String? _gender;

  bool get isLoggedIn => _username != null;
  String get username => _username ?? 'Tamu';
  String get role => _role ?? 'guest';
  String get currentTheme => _themeOverride ?? _role ?? 'guest';
  String? get userId => _userId;
  
  // Getters for new fields
  String? get fullName => _fullName;
  String? get absentNumber => _absentNumber;
  String? get className => _className;
  String? get dateOfBirth => _dateOfBirth;
  String? get gender => _gender;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');
    _username = prefs.getString('username');
    _role = prefs.getString('role');
    _themeOverride = prefs.getString('themeOverride');
    
    _fullName = prefs.getString('fullName');
    _absentNumber = prefs.getString('absentNumber');
    _className = prefs.getString('className');
    _dateOfBirth = prefs.getString('dateOfBirth');
    _gender = prefs.getString('gender');
    
    notifyListeners();
  }

  Future<void> login(
    String id, 
    String username, 
    String role, {
    String? fullName,
    String? absentNumber,
    String? className,
    String? dateOfBirth,
    String? gender,
  }) async {
    _userId = id;
    _username = username;
    _role = role;
    _themeOverride = null; // Reset override on login
    
    _fullName = fullName;
    _absentNumber = absentNumber;
    _className = className;
    _dateOfBirth = dateOfBirth;
    _gender = gender;
    
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', id);
    await prefs.setString('username', username);
    await prefs.setString('role', role);
    await prefs.remove('themeOverride');
    
    if (fullName != null) await prefs.setString('fullName', fullName);
    if (absentNumber != null) await prefs.setString('absentNumber', absentNumber);
    if (className != null) await prefs.setString('className', className);
    if (dateOfBirth != null) await prefs.setString('dateOfBirth', dateOfBirth);
    if (gender != null) await prefs.setString('gender', gender);
  }

  Future<void> updateProfile({
    String? fullName,
    String? absentNumber,
    String? className,
    String? dateOfBirth,
    String? gender,
  }) async {
    _fullName = fullName;
    _absentNumber = absentNumber;
    _className = className;
    _dateOfBirth = dateOfBirth;
    _gender = gender;
    
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    if (fullName != null) await prefs.setString('fullName', fullName);
    if (absentNumber != null) await prefs.setString('absentNumber', absentNumber);
    if (className != null) await prefs.setString('className', className);
    if (dateOfBirth != null) await prefs.setString('dateOfBirth', dateOfBirth);
    if (gender != null) await prefs.setString('gender', gender);
  }

  Future<void> logout() async {
    _userId = null;
    _username = null;
    _role = null;
    _themeOverride = null;
    
    _fullName = null;
    _absentNumber = null;
    _className = null;
    _dateOfBirth = null;
    _gender = null;
    
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('username');
    await prefs.remove('role');
    await prefs.remove('themeOverride');
    
    await prefs.remove('fullName');
    await prefs.remove('absentNumber');
    await prefs.remove('className');
    await prefs.remove('dateOfBirth');
    await prefs.remove('gender');
  }

  Future<void> setThemeOverride(String? theme) async {
    _themeOverride = theme;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    if (theme != null) {
      await prefs.setString('themeOverride', theme);
    } else {
      await prefs.remove('themeOverride');
    }
  }

  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
