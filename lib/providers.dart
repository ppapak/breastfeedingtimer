import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models.dart';
import 'package:image_picker/image_picker.dart';

class BabyProvider with ChangeNotifier {
  String? _babyName;
  String? _babyPhotoPath;

  String? get babyName => _babyName;
  String? get babyPhotoPath => _babyPhotoPath;

  BabyProvider() {
    loadBabyInfo();
  }

  Future<void> updateBabyName(String name) async {
    _babyName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('babyName', name);
    notifyListeners();
  }

  Future<void> pickBabyPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _babyPhotoPath = pickedFile.path;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('babyPhotoPath', _babyPhotoPath!);
      notifyListeners();
    }
  }

  Future<void> loadBabyInfo() async {
    final prefs = await SharedPreferences.getInstance();
    _babyName = prefs.getString('babyName');
    _babyPhotoPath = prefs.getString('babyPhotoPath');
    notifyListeners();
  }
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setSystemTheme() {
    _themeMode = ThemeMode.system;
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

  DateTime? get lastFeedTime {
    final feedSessions = _activities.whereType<FeedSession>().toList();
    if (feedSessions.isNotEmpty) {
      final lastFeed = feedSessions.first;
      return lastFeed.startTime.add(lastFeed.duration);
    }
    return null;
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
    final todayActivities = _activities.whereType<FeedSession>().where((s) => now.difference(s.startTime).inHours < 24 && s.startTime.day == now.day);
    if (todayActivities.isEmpty) return Duration.zero;
    return todayActivities.map((s) => s.duration).reduce((a, b) => a + b);
  }

  Duration get averageFeedDurationToday {
    final now = DateTime.now();
    final todayFeeds = _activities.whereType<FeedSession>().where((s) => now.difference(s.startTime).inHours < 24 && s.startTime.day == now.day).toList();
    if (todayFeeds.isEmpty) return Duration.zero;
    return todayFeeds.map((s) => s.duration).reduce((a, b) => a + b) ~/ todayFeeds.length;
  }

  Duration get averageFeedDurationYesterday {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final yesterdayFeeds = _activities.whereType<FeedSession>().where((s) => s.startTime.day == yesterday.day && s.startTime.month == yesterday.month && s.startTime.year == yesterday.year).toList();
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
    final todayActivities = _activities.whereType<FeedSession>().where((s) => now.difference(s.startTime).inHours < 24 && s.startTime.day == now.day && s.breastSide == side);
    if (todayActivities.isEmpty) return Duration.zero;
    return todayActivities.map((s) => s.duration).reduce((a, b) => a + b);
  }
}
