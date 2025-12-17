import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'models.dart';
import 'providers.dart';

class ManualEntryDialog extends StatefulWidget {
  const ManualEntryDialog({super.key});

  @override
  State<ManualEntryDialog> createState() => _ManualEntryDialogState();
}

class _ManualEntryDialogState extends State<ManualEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _startTime;
  late TimeOfDay _timeOfDay;
  late Duration _duration;
  late BreastSide _breastSide;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _duration = const Duration(minutes: 10);
    _breastSide = BreastSide.left;
    _timeOfDay = TimeOfDay.fromDateTime(_startTime);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Manual Feed Entry'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Date: ${DateFormat.yMd().format(_startTime)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _startTime,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() {
                    _startTime = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      _startTime.hour,
                      _startTime.minute,
                    );
                  });
                }
              },
            ),
            ListTile(
              title: Text('Time: ${_timeOfDay.format(context)}'),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: _timeOfDay,
                );
                if (pickedTime != null) {
                  setState(() {
                    _timeOfDay = pickedTime;
                    _startTime = DateTime(
                      _startTime.year,
                      _startTime.month,
                      _startTime.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Text('Duration: ${_duration.inMinutes} minutes'),
            Slider(
              value: _duration.inMinutes.toDouble(),
              min: 1,
              max: 120,
              divisions: 119,
              label: '${_duration.inMinutes} min',
              onChanged: (value) {
                setState(() {
                  _duration = Duration(minutes: value.toInt());
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _breastSide = BreastSide.left;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(24),
                    backgroundColor: _breastSide == BreastSide.left
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surface,
                    foregroundColor: _breastSide == BreastSide.left
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  child: const Text('L', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _breastSide = BreastSide.right;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(24),
                    backgroundColor: _breastSide == BreastSide.right
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.surface,
                    foregroundColor: _breastSide == BreastSide.right
                        ? Theme.of(context).colorScheme.onSecondary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  child: const Text('R', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final history = Provider.of<HistoryModel>(context, listen: false);
              final newSession = FeedSession(
                startTime: _startTime,
                duration: _duration,
                breastSide: _breastSide,
              );
              history.addActivity(newSession);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class DurationPicker extends StatefulWidget {
  final Duration initialDuration;

  const DurationPicker({super.key, required this.initialDuration});

  @override
  State<DurationPicker> createState() => _DurationPickerState();
}

class _DurationPickerState extends State<DurationPicker> {
  late int _minutes;

  @override
  void initState() {
    super.initState();
    _minutes = widget.initialDuration.inMinutes;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Duration'),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () {
              setState(() {
                if (_minutes > 0) _minutes--;
              });
            },
          ),
          Text('$_minutes min'),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() {
                _minutes++;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(Duration(minutes: _minutes));
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class HistoryList extends StatelessWidget {
  const HistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    final history = Provider.of<HistoryModel>(context);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.activities.length,
      itemBuilder: (context, index) {
        final activity = history.activities[index];
        if (activity is FeedSession) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                activity.breastSide == BreastSide.left ? 'L' : 'R',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text('${activity.duration.inMinutes} min feed'),
            subtitle: Text(DateFormat.yMd().add_jm().format(activity.startTime)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    history.removeActivity(activity);
                  },
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink(); 
      },
    );
  }
}

class StatsPanel extends StatelessWidget {
  const StatsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final history = Provider.of<HistoryModel>(context);

    String formatDuration(Duration d) {
      if (d.inHours > 0) {
        return "${d.inHours}h ${d.inMinutes.remainder(60)}m";
      } else if (d.inMinutes > 0) {
        return "${d.inMinutes}m";
      } else {
        return "${d.inSeconds}s";
      }
    }

    String formatAverageDuration(Duration d) {
      if (d == Duration.zero) return '0m 0s';
      final minutes = d.inMinutes;
      final seconds = d.inSeconds.remainder(60);
      return '${minutes}m ${seconds}s';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(context, "Feeds/24h", "${history.feedsInLast24Hours}", Icons.restaurant_menu),
                const SizedBox(width: 24),
                _buildStatItem(context, "Total Today", "${history.totalTodayDuration.inMinutes}m", Icons.timer),
                const SizedBox(width: 24),
                _buildStatItem(context, "Last Feed", formatDuration(history.timeSinceLastFeed), Icons.history),
                const SizedBox(width: 24),
                _buildStatItem(context, "Avg Today", formatAverageDuration(history.averageFeedDurationToday), Icons.timelapse),
                const SizedBox(width: 24),
                _buildStatItem(context, "Avg Yesterday", formatAverageDuration(history.averageFeedDurationYesterday), Icons.timelapse),
                const SizedBox(width: 24),
                _buildStatItem(context, "Avg Last 7 Days", formatAverageDuration(history.averageFeedDurationLast7Days), Icons.timelapse),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
        const SizedBox(height: 2),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
