
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
    final activities = history.activities;

    if (activities.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('No activities recorded yet.', style: TextStyle(fontSize: 16)),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Dismissible(
            key: Key(activity.startTime.toString()),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              history.deleteActivity(activity);
              ScaffoldMessenger.of(context)
                ..removeCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(content: Text('Activity deleted')),
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
            child: _buildActivityTile(context, activity),
          ),
        );
      },
    );
  }

  Widget _buildActivityTile(BuildContext context, Activity activity) {
    if (activity is FeedSession) {
      return ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          child: Text(
            activity.breastSide == BreastSide.left ? "L" : "R",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          "${activity.duration.inMinutes} min duration",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
        ),
        subtitle: Text(
          DateFormat.yMMMMd().add_jm().format(activity.startTime),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    } else if (activity is SolidFeed) {
      return ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(Icons.restaurant, color: Colors.white),
        ),
        title: Text(
          activity.food,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
        ),
        subtitle: Text(
          activity.grams != null
              ? '${activity.grams}g - ${DateFormat.yMMMMd().add_jm().format(activity.startTime)}'
              : DateFormat.yMMMMd().add_jm().format(activity.startTime),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}

class ManualEntryDialog extends StatefulWidget {
  const ManualEntryDialog({super.key});

  @override
  ManualEntryDialogState createState() => ManualEntryDialogState();
}

class ManualEntryDialogState extends State<ManualEntryDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  // Breastfeeding state
  double _selectedDuration = 15.0;
  BreastSide _selectedSide = BreastSide.left;

  // Solid food state
  final TextEditingController _foodController = TextEditingController(text: 'Formula');
  final TextEditingController _gramsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _foodController.dispose();
    _gramsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Manual Entry'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Breastfeeding'),
                Tab(text: 'Solid Food'),
              ],
            ),
            Flexible(
              child: SizedBox(
                height: 300,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBreastfeedingForm(),
                    _buildSolidFoodForm(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _saveEntry,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildBreastfeedingForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
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
            const SizedBox(height: 20),
            Text('Duration: ${_selectedDuration.round()} minutes'),
            Slider(
              value: _selectedDuration,
              min: 0,
              max: 60,
              divisions: 60,
              label: '${_selectedDuration.round()} min',
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
    );
  }

  Widget _buildSolidFoodForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
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
            TextFormField(
              controller: _foodController,
              decoration: const InputDecoration(labelText: 'Food'),
            ),
            TextFormField(
              controller: _gramsController,
              decoration: const InputDecoration(labelText: 'Grams'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  void _saveEntry() {
    final startTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    if (_tabController.index == 0) {
      // Breastfeeding
      final session = FeedSession(
        startTime: startTime,
        duration: Duration(minutes: _selectedDuration.round()),
        breastSide: _selectedSide,
      );
      Provider.of<HistoryModel>(context, listen: false).addActivity(session);
      Navigator.of(context).pop();
    } else {
      // Solid Food
      if (_foodController.text.isNotEmpty) {
        final solidFeed = SolidFeed(
          startTime: startTime,
          food: _foodController.text,
          grams: int.tryParse(_gramsController.text),
        );
        Provider.of<HistoryModel>(context, listen: false).addActivity(solidFeed);
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a food')),
        );
      }
    }
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
