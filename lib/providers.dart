
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
  List<FeedSession> _sessions = [];
  static const _sessionsKey = 'feed_sessions';

  List<FeedSession> get sessions => _sessions;

  HistoryModel() {
    loadSessions();
  }

  Future<void> addSession(FeedSession session) async {
    _sessions.insert(0, session);
    await saveSessions();
    notifyListeners();
  }

  Future<void> deleteSession(FeedSession session) async {
    _sessions.remove(session);
    await saveSessions();
    notifyListeners();
  }

  Future<void> loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = prefs.getString(_sessionsKey) ?? '[]';
    final sessionsList = jsonDecode(sessionsJson) as List;
    _sessions = sessionsList.map((json) => FeedSession.fromJson(json)).toList();
    _sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    notifyListeners();
  }

  Future<void> saveSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = jsonEncode(_sessions.map((s) => s.toJson()).toList());
    await prefs.setString(_sessionsKey, sessionsJson);
  }

  // Analysis Getters
  Duration get timeSinceLastFeed {
    if (_sessions.isEmpty) {
      return Duration.zero;
    }
    return DateTime.now().difference(_sessions.first.startTime);
  }

  int get feedsInLast24Hours =>
      _sessions.where((s) => DateTime.now().difference(s.startTime).inHours < 24).length;

  List<FeedSession> get _todayFeeds =>
      _sessions.where((s) => s.startTime.day == DateTime.now().day && s.startTime.month == DateTime.now().month && s.startTime.year == DateTime.now().year).toList();

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
