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
    loadHistory();
  }

  DateTime? get lastFeedTime => _activities.isNotEmpty ? _activities.first.startTime : null;

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

  Future<void> loadHistory() async {
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

  // Average feed duration today
  Duration get averageFeedDurationToday {
    final todayFeeds = _activities.whereType<FeedSession>().where((s) {
      final now = DateTime.now();
      return s.startTime.year == now.year &&
          s.startTime.month == now.month &&
          s.startTime.day == now.day;
    }).toList();

    if (todayFeeds.isEmpty) {
      return Duration.zero;
    }

    final totalDuration =
        todayFeeds.fold<Duration>(Duration.zero, (prev, s) => prev + s.duration);
    return totalDuration ~/ todayFeeds.length;
  }

  // Average feed duration yesterday
  Duration get averageFeedDurationYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayFeeds = _activities.whereType<FeedSession>().where((s) {
      return s.startTime.year == yesterday.year &&
          s.startTime.month == yesterday.month &&
          s.startTime.day == yesterday.day;
    }).toList();

    if (yesterdayFeeds.isEmpty) {
      return Duration.zero;
    }

    final totalDuration = yesterdayFeeds.fold<Duration>(
        Duration.zero, (prev, s) => prev + s.duration);
    return totalDuration ~/ yesterdayFeeds.length;
  }

  // Average feed duration in the last 7 days
  Duration get averageFeedDurationLast7Days {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final last7DaysFeeds = _activities
        .whereType<FeedSession>()
        .where((s) => s.startTime.isAfter(sevenDaysAgo))
        .toList();

    if (last7DaysFeeds.isEmpty) {
      return Duration.zero;
    }

    final totalDuration = last7DaysFeeds.fold<Duration>(
        Duration.zero, (prev, s) => prev + s.duration);
    return totalDuration ~/ last7DaysFeeds.length;
  }
}
