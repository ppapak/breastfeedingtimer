
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Gender { unknown, boy, girl }

class BabyModel with ChangeNotifier {
  String _babyName = "add your baby name";
  Gender _gender = Gender.unknown;

  String get babyName => _babyName;
  Gender get gender => _gender;

  static const _nameKey = 'baby_name';
  static const _genderKey = 'baby_gender';

  BabyModel() {
    loadBabyInfo();
  }

  Future<void> loadBabyInfo() async {
    final prefs = await SharedPreferences.getInstance();
    _babyName = prefs.getString(_nameKey) ?? "add your baby name";
    final genderString = prefs.getString(_genderKey);
    if (genderString != null) {
      _gender = Gender.values.firstWhere((g) => g.toString() == genderString, orElse: () => Gender.unknown);
    } else {
       _gender = Gender.unknown;
    }
    notifyListeners();
  }

  Future<void> saveBabyInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, _babyName);
    await prefs.setString(_genderKey, _gender.toString());
  }

  void setBabyName(String newName) {
    if (newName.trim().isEmpty) {
        _babyName = "add your baby name";
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
}
