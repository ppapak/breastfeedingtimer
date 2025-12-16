
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Gender { unknown, boy, girl }

class BabyModel with ChangeNotifier {
  String _babyName = "baby name?";
  Gender _gender = Gender.unknown;
  File? _babyImage;

  String get babyName => _babyName;
  Gender get gender => _gender;
  File? get babyImage => _babyImage;

  static const _nameKey = 'baby_name';
  static const _genderKey = 'baby_gender';
  static const _imagePathKey = 'baby_image_path';

  BabyModel() {
    loadBabyInfo();
  }

  Future<void> loadBabyInfo() async {
    final prefs = await SharedPreferences.getInstance();
    _babyName = prefs.getString(_nameKey) ?? "baby name?";
    final genderString = prefs.getString(_genderKey);
    if (genderString != null) {
      _gender = Gender.values.firstWhere((g) => g.toString() == genderString, orElse: () => Gender.unknown);
    } else {
       _gender = Gender.unknown;
    }
    final imagePath = prefs.getString(_imagePathKey);
    if (imagePath != null) {
      _babyImage = File(imagePath);
    }
    notifyListeners();
  }

  Future<void> saveBabyInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, _babyName);
    await prefs.setString(_genderKey, _gender.toString());
    if (_babyImage != null) {
      await prefs.setString(_imagePathKey, _babyImage!.path);
    }
  }

  void setBabyName(String newName) {
    if (newName.trim().isEmpty) {
        _babyName = "baby name?";
    } else {
        _babyName = newName;
    }
    saveBabyInfo();
    notifyListeners();
  }

  void toggleGender() {
    if (_gender == Gender.girl) {
      _gender = Gender.boy;
    } else {
      _gender = Gender.girl;
    }
    saveBabyInfo();
    notifyListeners();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _babyImage = File(pickedFile.path);
      saveBabyInfo();
      notifyListeners();
    }
  }
}
