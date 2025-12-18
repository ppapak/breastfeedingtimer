import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

enum Gender { unknown, boy, girl }

class BabyProvider with ChangeNotifier {
  String _babyName = "baby name?";
  Gender _gender = Gender.unknown;
  File? _babyImage;

  String get babyName => _babyName;
  Gender get gender => _gender;
  File? get babyImage => _babyImage;

  static const _nameKey = 'baby_name';
  static const _genderKey = 'baby_gender';
  static const _imagePathKey = 'baby_image_path';

  BabyProvider() {
    loadBabyInfo();
  }

  Future<void> loadBabyInfo() async {
    final prefs = await SharedPreferences.getInstance();
    _babyName = prefs.getString(_nameKey) ?? "baby name?";
    final genderString = prefs.getString(_genderKey);
    if (genderString != null) {
      _gender = Gender.values
          .firstWhere((g) => g.toString() == genderString, orElse: () => Gender.unknown);
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
    } else {
      await prefs.remove(_imagePathKey);
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

  void updateBabyName(String name) {
    if (name.trim().isEmpty) {
      _babyName = "baby name?";
    } else {
      _babyName = name;
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
      final appDir = await getApplicationDocumentsDirectory();
      const fileName = 'baby_profile_image.jpg';
      final savedImage = await File(pickedFile.path).copy(path.join(appDir.path, fileName));
      _babyImage = savedImage;
      saveBabyInfo();
      notifyListeners();
    }
  }

  Future<void> deleteImage() async {
    if (_babyImage != null) {
      try {
        await _babyImage!.delete();
      } catch (e) {
        // Ignore errors if file doesn't exist
      }
      _babyImage = null;
      saveBabyInfo();
      notifyListeners();
    }
  }
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveTheme();
    notifyListeners();
  }

  void setSystemTheme() {
    _themeMode = ThemeMode.system;
    _saveTheme();
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('themeMode', _themeMode.toString());
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('themeMode');
    if (themeString != null) {
      _themeMode = ThemeMode.values
          .firstWhere((e) => e.toString() == themeString, orElse: () => ThemeMode.system);
    }
    notifyListeners();
  }
}

class TimerModel with ChangeNotifier {
  late BreastSide _currentSide;
  bool _isRunning = false;
  late Duration _duration;
  late Ticker _ticker;

  TimerModel() {
    _duration = Duration.zero;
    _ticker = Ticker(_tick);
  }

  BreastSide get currentSide => _currentSide;
  bool get isRunning => _isRunning;
  Duration get duration => _duration;

  void startTimer(BreastSide side) {
    _currentSide = side;
    _isRunning = true;
    _duration = Duration.zero;
    _ticker.start();
    notifyListeners();
  }

  void stopTimer() {
    _isRunning = false;
    _ticker.stop();
    notifyListeners();
  }

  void _tick(Duration elapsed) {
    _duration = elapsed;
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}

class HistoryModel with ChangeNotifier {
  List<Activity> _activities = [];

  List<Activity> get activities => _activities;

  HistoryModel() {
    loadHistory();
  }

  void addActivity(Activity activity) {
    _activities.add(activity);
    _activities.sort((a, b) => b.startTime.compareTo(a.startTime));
    saveHistory();
    notifyListeners();
  }

  void removeActivity(Activity activity) {
    _activities.remove(activity);
    saveHistory();
    notifyListeners();
  }

  void updateActivity(Activity oldActivity, Activity newActivity) {
    final index = _activities.indexOf(oldActivity);
    if (index != -1) {
      _activities[index] = newActivity;
      _activities.sort((a, b) => b.startTime.compareTo(a.startTime));
      saveHistory();
      notifyListeners();
    }
  }

  Future<void> saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> activityJson = _activities.map((a) => jsonEncode(a.toJson())).toList();
    await prefs.setStringList('history', activityJson);
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? activityJson = prefs.getStringList('history');
    if (activityJson != null) {
      _activities = activityJson.map((json) {
        final map = jsonDecode(json);
        if (map['type'] == 'FeedSession') {
          return FeedSession.fromJson(map);
        } else if (map['type'] == 'SolidFeed') {
          return SolidFeed.fromJson(map);
        }
        throw Exception('Unknown activity type');
      }).toList();
      _activities.sort((a, b) => b.startTime.compareTo(a.startTime));
      notifyListeners();
    }
  }

  Future<void> clearHistory() async {
    _activities = [];
    saveHistory();
    notifyListeners();
  }

  DateTime? get lastFeedTime {
    if (_activities.isEmpty) {
      return null;
    }
    final lastActivity = _activities.first;
    if (lastActivity is FeedSession) {
      return lastActivity.startTime.add(lastActivity.duration);
    } else {
      return lastActivity.startTime;
    }
  }

  Duration get timeSinceLastFeed {
    if (lastFeedTime != null) {
      return DateTime.now().difference(lastFeedTime!);
    }
    return Duration.zero;
  }

  int get feedsInLast24Hours {
    final now = DateTime.now();
    return _activities.where((s) => now.difference(s.startTime).inHours < 24).length;
  }

  Duration get totalTodayDuration {
    final now = DateTime.now();
    final todayActivities =
        _activities.whereType<FeedSession>().where((s) => now.difference(s.startTime).inHours < 24 && s.startTime.day == now.day);
    if (todayActivities.isEmpty) return Duration.zero;
    return todayActivities.map((s) => s.duration).reduce((a, b) => a + b);
  }

  Duration get averageFeedDurationToday {
    final now = DateTime.now();
    final todayFeeds = _activities
        .whereType<FeedSession>()
        .where((s) => now.difference(s.startTime).inHours < 24 && s.startTime.day == now.day)
        .toList();
    if (todayFeeds.isEmpty) return Duration.zero;
    return todayFeeds.map((s) => s.duration).reduce((a, b) => a + b) ~/ todayFeeds.length;
  }

  Duration get averageFeedDurationYesterday {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final yesterdayFeeds = _activities
        .whereType<FeedSession>()
        .where((s) =>
            s.startTime.day == yesterday.day &&
            s.startTime.month == yesterday.month &&
            s.startTime.year == yesterday.year)
        .toList();
    if (yesterdayFeeds.isEmpty) return Duration.zero;
    return yesterdayFeeds.map((s) => s.duration).reduce((a, b) => a + b) ~/ yesterdayFeeds.length;
  }

  Duration get averageFeedDurationLast7Days {
    final now = DateTime.now();
    final last7DaysFeeds = _activities.whereType<FeedSession>().where((s) => now.difference(s.startTime).inDays < 7).toList();
    if (last7DaysFeeds.isEmpty) return Duration.zero;
    return last7DaysFeeds.map((s) => s.duration).reduce((a, b) => a + b) ~/ last7DaysFeeds.length;
  }

  Duration totalDurationForSide(BreastSide side) {
    final now = DateTime.now();
    final todayActivities = _activities
        .whereType<FeedSession>()
        .where((s) => now.difference(s.startTime).inHours < 24 && s.startTime.day == now.day && s.breastSide == side);
    if (todayActivities.isEmpty) return Duration.zero;
    return todayActivities.map((s) => s.duration).reduce((a, b) => a + b);
  }
}

class SetupProvider with ChangeNotifier {
  bool _isSetupComplete = false;
  List<String> _acceptanceDates = [];

  static const _setupCompleteKey = 'setup_complete';
  static const _acceptanceDatesKey = 'acceptance_dates';

  bool get isSetupComplete => _isSetupComplete;
  List<String> get acceptanceDates => _acceptanceDates;

  SetupProvider() {
    loadSetupInfo();
  }

  Future<void> loadSetupInfo() async {
    final prefs = await SharedPreferences.getInstance();
    _isSetupComplete = prefs.getBool(_setupCompleteKey) ?? false;
    _acceptanceDates = prefs.getStringList(_acceptanceDatesKey) ?? [];
    notifyListeners();
  }

  Future<void> completeSetup() async {
    final prefs = await SharedPreferences.getInstance();
    _isSetupComplete = true;
    _acceptanceDates.add(DateTime.now().toIso8601String());
    await prefs.setBool(_setupCompleteKey, true);
    await prefs.setStringList(_acceptanceDatesKey, _acceptanceDates);
    notifyListeners();
  }

  Future<void> resetSetup() async {
    final prefs = await SharedPreferences.getInstance();
    _isSetupComplete = false;
    await prefs.setBool(_setupCompleteKey, false);
    notifyListeners();
  }
}
