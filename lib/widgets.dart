
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'models.dart';
import 'providers.dart';

class HistoryList extends StatelessWidget {
  const HistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    final history = Provider.of<HistoryModel>(context);
    final sessions = history.sessions;

    if (sessions.isEmpty) {
      return const Center(child: Text('No feeding sessions recorded yet.'));
    }

    return ListView.builder(
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        final previousSession = index > 0 ? sessions[index - 1] : null;
        final showDateHeader = previousSession == null || !isSameDay(session.startTime, previousSession.startTime);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDateHeader)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Text(
                  DateFormat.yMMMMd().format(session.startTime),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ListTile(
              leading: _buildBreastIcon(context, session.breastSide),
              title: Text(DateFormat.Hm().format(session.startTime), style: Theme.of(context).textTheme.bodyLarge),
              trailing: Text(
                "${session.duration.inMinutes.toString().padLeft(2, '0')}m ${session.duration.inSeconds.remainder(60).toString().padLeft(2, '0')}s",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        );
      },
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildBreastIcon(BuildContext context, BreastSide side) {
    return CustomPaint(
      size: const Size(40, 40),
      painter: _BreastIconPainter(side, Theme.of(context).colorScheme.secondary, Colors.white),
    );
  }
}

class _BreastIconPainter extends CustomPainter {
  final BreastSide side;
  final Color backgroundColor;
  final Color foregroundColor;

  _BreastIconPainter(this.side, this.backgroundColor, this.foregroundColor);

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = backgroundColor;
    final foregroundPaint = Paint()
      ..color = foregroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(center, radius, backgroundPaint);

    if (side == BreastSide.left) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius / 2),
        0, // Start angle
        3.14, // Sweep angle (180 degrees)
        false,
        foregroundPaint,
      );
    } else {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius / 2),
        3.14, // Start angle (180 degrees)
        3.14, // Sweep angle (180 degrees)
        false,
        foregroundPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}



class ManualEntryDialog extends StatefulWidget {
  const ManualEntryDialog({super.key});

  @override
  ManualEntryDialogState createState() => ManualEntryDialogState();
}

class ManualEntryDialogState extends State<ManualEntryDialog> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final _durationController = TextEditingController();
  BreastSide _selectedSide = BreastSide.left;

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Manual Entry'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text('Date: ${DateFormat.yMd().format(_selectedDate)}'),
            trailing: const Icon(Icons.calendar_today),
            onTap: _pickDate,
          ),
          ListTile(
            title: Text('Time: ${_selectedTime.format(context)}'),
            trailing: const Icon(Icons.access_time),
            onTap: _pickTime,
          ),
          TextField(
            controller: _durationController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Duration (minutes)',
            ),
          ),
          const SizedBox(height: 20),
          ToggleButtons(
            isSelected: [_selectedSide == BreastSide.left, _selectedSide == BreastSide.right],
            onPressed: (index) {
              setState(() {
                _selectedSide = index == 0 ? BreastSide.left : BreastSide.right;
              });
            },
            children: const [
              Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Left')),
              Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Right')),
            ],
          )
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            final duration = int.tryParse(_durationController.text);
            if (duration != null) {
              final startTime = DateTime(
                _selectedDate.year,
                _selectedDate.month,
                _selectedDate.day,
                _selectedTime.hour,
                _selectedTime.minute,
              );
              final session = FeedSession(
                startTime: startTime,
                duration: Duration(minutes: duration),
                breastSide: _selectedSide,
              );
              Provider.of<HistoryModel>(context, listen: false).addSession(session);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }
}
