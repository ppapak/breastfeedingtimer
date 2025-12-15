
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import 'models.dart';
import 'providers.dart';
import 'widgets.dart';
import 'baby_provider.dart';
import 'settings_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TimerModel()),
        ChangeNotifierProvider(create: (context) => HistoryModel()),
        ChangeNotifierProvider(create: (context) => BabyModel()),
      ],
      child: const BreastfeedingApp(),
    ),
  );
}

class BreastfeedingApp extends StatelessWidget {
  const BreastfeedingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Breastfeeding Timer',
      theme: ThemeData(
        primaryColor: const Color(0xFF4A5C55),
        scaffoldBackgroundColor: const Color(0xFFD4E2D4),
        colorScheme: const ColorScheme.light().copyWith(
          primary: const Color(0xFF4A5C55),
          secondary: const Color(0xFFF7A78C),
        ),
        textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme).copyWith(
          displayLarge: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4A5C55)),
          bodyLarge: const TextStyle(fontSize: 16, color: Color(0xFF4A5C55)),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: const [
          SizedBox(height: 40), // Add some space at the top
          Header(),
          TimerControl(),
          StatsPanel(),
          Expanded(child: HistoryList()),
        ],
      ),
    );
  }
}

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  HeaderState createState() => HeaderState();
}

class HeaderState extends State<Header> {
  bool _isEditing = false;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final babyModel = Provider.of<BabyModel>(context, listen: false);
    _nameController = TextEditingController(text: babyModel.babyName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  IconData _getBabyIcon(Gender gender) {
    switch (gender) {
      case Gender.boy:
        return Icons.child_care;
      case Gender.girl:
        return Icons.face_3;
      default:
        return Icons.child_care;
    }
  }

  void _launchEmail() async {
    final history = Provider.of<HistoryModel>(context, listen: false);
    final baby = Provider.of<BabyModel>(context, listen: false);
    final subject = 'Breastfeeding History for ${baby.babyName}';
    final body = history.sessions.map((session) {
      final startTime = DateFormat.yMd().add_Hms().format(session.startTime);
      final duration = session.duration.inMinutes;
      final side = session.breastSide == BreastSide.left ? 'Left' : 'Right';
      return 'Start Time: $startTime, Duration: $duration minutes, Side: $side';
    }).join('\n');

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: '',
      query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      throw 'Could not launch $emailLaunchUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    final babyModel = Provider.of<BabyModel>(context);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => babyModel.toggleGender(),
                child: Icon(_getBabyIcon(babyModel.gender), size: 40, color: const Color(0xFF4A5C55)),
              ),
              const SizedBox(width: 10),
              _isEditing
                  ? SizedBox(
                      width: 150,
                      child: TextField(
                        controller: _nameController,
                        autofocus: true,
                        onSubmitted: (newName) {
                          babyModel.setBabyName(newName);
                          setState(() {
                            _isEditing = false;
                          });
                        },
                         decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        setState(() {
                          _isEditing = true;
                        });
                      },
                      child: Text(babyModel.babyName, style: Theme.of(context).textTheme.displayLarge),
                    ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.share, color: const Color(0xFF4A5C55)),
                onPressed: _launchEmail,
              ),
              IconButton(
                icon: Icon(Icons.settings, color: const Color(0xFF4A5C55)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsPage()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TimerControl extends StatelessWidget {
  const TimerControl({super.key});

  @override
  Widget build(BuildContext context) {
    final timer = Provider.of<TimerModel>(context);
    final history = Provider.of<HistoryModel>(context, listen: false);

    String formatDuration(Duration d) {
      return "${d.inMinutes.toString().padLeft(2, '0')}m ${d.inSeconds.remainder(60).toString().padLeft(2, '0')}s";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Text(
            formatDuration(timer.duration),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 48),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBreastButton(context, BreastSide.left, timer, history, key: const Key('left_breast_button')),
              _buildAddButton(context, timer, history),
              _buildBreastButton(context, BreastSide.right, timer, history, key: const Key('right_breast_button')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreastButton(BuildContext context, BreastSide side, TimerModel timer, HistoryModel history, {Key? key}) {
    final isSelected = timer.isRunning && timer.currentSide == side;

    return GestureDetector(
      key: key,
      onTap: () {
        if (timer.isRunning && timer.currentSide == side) {
          final session = FeedSession(
            startTime: DateTime.now().subtract(timer.duration),
            duration: timer.duration,
            breastSide: side,
          );
          history.addSession(session);
          timer.stopTimer();
        } else {
          timer.startTimer(side);
        }
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.secondary : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).primaryColor, width: 3),
        ),
        child: _buildBreastIcon(context, side),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, TimerModel timer, HistoryModel history) {
    return FloatingActionButton(
      onPressed: () async {
        _showManualEntryDialog(context);
      },
      backgroundColor: Theme.of(context).primaryColor,
      child: const Icon(Icons.add),
    );
  }

  void _showManualEntryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return const ManualEntryDialog();
      },
    );
  }
}

class StatsPanel extends StatelessWidget {
  const StatsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final history = Provider.of<HistoryModel>(context);

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7A78C),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${history.timeSinceLastFeed.inMinutes}m since last breast feeding."),
          const SizedBox(height: 5),
          Text("${history.feedsInLast24Hours} feeds in the last 24 hours."),
          const Divider(height: 20, thickness: 1, color: Colors.white),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16),
              const SizedBox(width: 5),
              Text("TODAY"),
            ],
          ),
          const SizedBox(height: 5),
          Text(
              "- ${history.totalTodayFeeds} total feeds with ${history.totalTodayDuration.inMinutes} total mins feed time, using ${history.leftBreastPercentage.toStringAsFixed(1)}% your Left and ${history.rightBreastPercentage.toStringAsFixed(1)}% your Right breast."),
        ],
      ),
    );
  }
}

Widget _buildBreastIcon(BuildContext context, BreastSide side) {
  return CustomPaint(
    size: const Size(60, 60),
    painter: _BreastIconPainter(side, Theme.of(context).primaryColor),
  );
}

class _BreastIconPainter extends CustomPainter {
  final BreastSide side;
  final Color color;

  _BreastIconPainter(this.side, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(center, radius, paint);

    if (side == BreastSide.left) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius / 2),
        0, // Start angle
        3.14, // Sweep angle (180 degrees)
        false,
        paint,
      );
    } else {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius / 2),
        3.14, // Start angle (180 degrees)
        3.14, // Sweep angle (180 degrees)
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
