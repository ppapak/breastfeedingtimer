
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis'),
      ),
      body: Consumer<HistoryModel>(
        builder: (context, history, child) {
          return ListView(
            children: [
              ListTile(
                title: const Text('Average Feed Duration (Today)'),
                trailing: Text(_formatDuration(history.averageFeedDurationToday)),
              ),
              ListTile(
                title: const Text('Average Feed Duration (Yesterday)'),
                trailing: Text(_formatDuration(history.averageFeedDurationYesterday)),
              ),
              ListTile(
                title: const Text('Average Feed Duration (Last 7 Days)'),
                trailing: Text(_formatDuration(history.averageFeedDurationLast7Days)),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }
}
