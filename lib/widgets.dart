
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
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('No feeding sessions recorded yet.', style: TextStyle(fontSize: 16)),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Dismissible(
            key: Key(session.startTime.toString()),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              history.deleteSession(session);
              ScaffoldMessenger.of(context)
                ..removeCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(content: Text('Session deleted')),
                );
            },
            background: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
              ),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: Text(
                  session.breastSide == BreastSide.left ? "L" : "R",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                "${session.duration.inMinutes} min duration",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
              ),
              subtitle: Text(
                DateFormat.yMMMMd().add_jm().format(session.startTime),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        );
      },
    );
  }
}

class ManualEntryDialog extends StatefulWidget {
  const ManualEntryDialog({super.key});

  @override
  ManualEntryDialogState createState() => ManualEntryDialogState();
}

class ManualEntryDialogState extends State<ManualEntryDialog> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int? _selectedDuration;
  BreastSide _selectedSide = BreastSide.left;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Manual Entry'),
      content: SingleChildScrollView(
        child: Column(
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
            DropdownButtonFormField<int>(
              initialValue: _selectedDuration,
              hint: const Text('Duration (minutes)'),
              items: List.generate(61, (index) => index)
                  .map((minute) => DropdownMenuItem(
                        value: minute,
                        child: Text('$minute min'),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDuration = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ToggleButtons(
              isSelected: [_selectedSide == BreastSide.left, _selectedSide == BreastSide.right],
              onPressed: (index) {
                setState(() {
                  _selectedSide = index == 0 ? BreastSide.left : BreastSide.right;
                });
              },
              borderRadius: BorderRadius.circular(8),
              children: const [
                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Left')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Right')),
              ],
            )
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_selectedDuration != null) {
              final startTime = DateTime(
                _selectedDate.year,
                _selectedDate.month,
                _selectedDate.day,
                _selectedTime.hour,
                _selectedTime.minute,
              );
              final session = FeedSession(
                startTime: startTime,
                duration: Duration(minutes: _selectedDuration!),
                breastSide: _selectedSide,
              );
              Provider.of<HistoryModel>(context, listen: false).addSession(session);
              Navigator.of(context).pop();
            } else {
              // Optionally, show a snackbar or some feedback to the user
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select a duration')),
              );
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
