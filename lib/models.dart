
enum BreastSide { left, right }

abstract class Activity {
  final DateTime startTime;

  Activity({required this.startTime});

  Map<String, dynamic> toJson();
}

class FeedSession extends Activity {
  final Duration duration;
  final BreastSide breastSide;

  FeedSession({
    required super.startTime,
    required this.duration,
    required this.breastSide,
  });

  factory FeedSession.fromJson(Map<String, dynamic> json) {
    return FeedSession(
      startTime: DateTime.parse(json['startTime']),
      duration: Duration(seconds: json['duration']),
      breastSide: BreastSide.values.firstWhere((e) => e.toString() == json['breastSide']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'FeedSession',
        'startTime': startTime.toIso8601String(),
        'duration': duration.inSeconds,
        'breastSide': breastSide.toString(),
      };
}

class SolidFeed extends Activity {
  final String food;

  SolidFeed({
    required super.startTime,
    required this.food,
  });

  factory SolidFeed.fromJson(Map<String, dynamic> json) {
    return SolidFeed(
      startTime: DateTime.parse(json['startTime']),
      food: json['food'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'SolidFeed',
        'startTime': startTime.toIso8601String(),
        'food': food,
      };
}
