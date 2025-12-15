

enum BreastSide { left, right }

class FeedSession {
  final DateTime startTime;
  final Duration duration;
  final BreastSide breastSide;

  FeedSession({
    required this.startTime,
    required this.duration,
    required this.breastSide,
  });

  Map<String, dynamic> toJson() => {
        'startTime': startTime.toIso8601String(),
        'duration': duration.inSeconds,
        'breastSide': breastSide.toString(),
      };

  factory FeedSession.fromJson(Map<String, dynamic> json) => FeedSession(
        startTime: DateTime.parse(json['startTime']),
        duration: Duration(seconds: json['duration']),
        breastSide: BreastSide.values.firstWhere((e) => e.toString() == json['breastSide']),
      );
}
