
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class TimerModel with ChangeNotifier {
  Timer? _timer;
  Duration _duration = Duration.zero;
  bool _isRunning = false;
  BreastSide? _currentSide;

  Duration get duration => _duration;
  bool get isRunning => _isRunning;
  BreastSide? get currentSide => _currentSide;

  void startTimer(BreastSide side) {
    if (_isRunning) {
      stopTimer();
    }
    _currentSide = side;
    _duration = Duration.zero;
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _duration += const Duration(seconds: 1);
      notifyListeners();
    });
    notifyListeners();
  }

  void stopTimer() {
    _timer?.cancel();
    _isRunning = false;
    _currentSide = null;
    notifyListeners();
  }
}

class HistoryModel with ChangeNotifier {
  List<Activity> _activities = [];
  static const _activitiesKey = 'activities';

  List<Activity> get activities => _activities;

  HistoryModel() {
    loadActivities();
  }

  Future<void> addActivity(Activity activity) async {
    _activities.insert(0, activity);
    await saveActivities();
    notifyListeners();
  }

  Future<void> deleteActivity(Activity activity) async {
    _activities.remove(activity);
    await saveActivities();
    notifyListeners();
  }

  Future<void> loadActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final activitiesJson = prefs.getString(_activitiesKey) ?? '[]';
    final activitiesList = jsonDecode(activitiesJson) as List;
    _activities = activitiesList.map((json) {
      if (json['type'] == 'FeedSession') {
        return FeedSession.fromJson(json);
      } else if (json['type'] == 'SolidFeed') {
        return SolidFeed.fromJson(json);
      } else {
        throw Exception('Unknown activity type');
      }
    }).toList();
    _activities.sort((a, b) => b.startTime.compareTo(a.startTime));
    notifyListeners();
  }

  Future<void> saveActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final activitiesJson = jsonEncode(_activities.map((a) => a.toJson()).toList());
    await prefs.setString(_activitiesKey, activitiesJson);
  }

  // Analysis Getters
  Duration get timeSinceLastFeed {
    if (_activities.isEmpty) {
      return Duration.zero;
    }
    return DateTime.now().difference(_activities.first.startTime);
  }

  int get feedsInLast24Hours =>
      _activities.where((a) => a is FeedSession && DateTime.now().difference(a.startTime).inHours < 24).length;

  List<FeedSession> get _todayFeeds =>
      _activities.whereType<FeedSession>().where((s) => s.startTime.day == DateTime.now().day && s.startTime.month == DateTime.now().month && s.startTime.year == DateTime.now().year).toList();

  int get totalTodayFeeds => _todayFeeds.length;

  Duration get totalTodayDuration =>
      _todayFeeds.fold<Duration>(Duration.zero, (prev, s) => prev + s.duration);

  double get leftBreastPercentage {
    if (_todayFeeds.isEmpty) return 0;
    final leftCount = _todayFeeds.where((s) => s.breastSide == BreastSide.left).length;
    return (leftCount / _todayFeeds.length) * 100;
  }

  double get rightBreastPercentage {
    if (_todayFeeds.isEmpty) return 0;
    final rightCount = _todayFeeds.where((s) => s.breastSide == BreastSide.right).length;
    return (rightCount / _todayFeeds.length) * 100;
  }
}
