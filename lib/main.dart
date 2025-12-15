
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

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
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const BreastfeedingApp(),
    ),
  );
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setSystemTheme() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
}

class BreastfeedingApp extends StatelessWidget {
  const BreastfeedingApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primarySeedColor = Colors.deepPurple;

    final TextTheme appTextTheme = TextTheme(
      displayLarge: GoogleFonts.oswald(fontSize: 48, fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.openSans(fontSize: 14),
      labelLarge: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
    );

    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.light,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: primarySeedColor,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primarySeedColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );

    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.dark,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.deepPurple.shade200,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Breastfeeding Timer',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          home: const HomeScreen(),
        );
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: const Header(),
              expandedHeight: 80,
              floating: true,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withAlpha(179),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            )
          ];
        },
        body: ListView(
          children: const [
            TimerControl(),
            StatsPanel(),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("History", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            HistoryList(),
          ],
        ),
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
  late FocusNode _focusNode;
  String _originalName = '';

  @override
  void initState() {
    super.initState();
    final babyModel = Provider.of<BabyModel>(context, listen: false);
    _nameController = TextEditingController(text: babyModel.babyName);
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) {
        final newName = _nameController.text.trim();
        if (newName.isNotEmpty) {
          babyModel.setBabyName(newName);
        } else {
          _nameController.text = _originalName;
          babyModel.setBabyName(_originalName);
        }
        setState(() {
          _isEditing = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _shareApp() {
    Share.share(text: 'Check out this awesome breastfeeding timer app!\n\n[App URL goes here]');
  }

  @override
  Widget build(BuildContext context) {
    final babyModel = Provider.of<BabyModel>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _isEditing
            ? SizedBox(
                width: 150,
                child: TextField(
                  controller: _nameController,
                  focusNode: _focusNode,
                  autofocus: true,
                  onSubmitted: (newName) {
                    // The focus listener will handle saving.
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'Enter baby name',
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
              )
            : GestureDetector(
                onTap: () {
                  setState(() {
                    _isEditing = true;
                    _originalName = babyModel.babyName;
                    _nameController.clear();
                  });
                },
                child: Text(
                  babyModel.babyName.isNotEmpty ? babyModel.babyName : 'Add Your Baby Name',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
              ),
        Row(
          children: [
            IconButton(
              icon: Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => themeProvider.toggleTheme(),
              tooltip: 'Toggle Theme',
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareApp,
            ),
            IconButton(
              icon: const Icon(Icons.settings),
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
      return "${d.inMinutes.toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}";
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            formatDuration(timer.duration),
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBreastButton(context, BreastSide.left, timer, history),
              _buildAddButton(context),
              _buildBreastButton(context, BreastSide.right, timer, history),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreastButton(BuildContext context, BreastSide side, TimerModel timer, HistoryModel history) {
    final isSelected = timer.isRunning && timer.currentSide == side;

    return ElevatedButton(
      onPressed: () {
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
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(30),
        backgroundColor: isSelected ? Theme.of(context).colorScheme.secondary : null,
      ),
      child: Text(side == BreastSide.left ? "L" : "R", style: const TextStyle(fontSize: 24)),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        showDialog(context: context, builder: (context) => const ManualEntryDialog());
      },
      child: const Icon(Icons.add),
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
      } else {
        return "${d.inMinutes}m";
      }
    }

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Statistics", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem("Feeds in 24h", "${history.feedsInLast24Hours}"),
                _buildStatItem("Total Time Today", "${history.totalTodayDuration.inMinutes}m"),
                _buildStatItem("Since Last Feed", formatDuration(history.timeSinceLastFeed)),
              ],
            ),
            const SizedBox(height: 10),
            if (history.totalTodayFeeds > 0)
              const AspectRatio(
                aspectRatio: 2,
                child: BreastSideChart(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

class BreastSideChart extends StatelessWidget {
  const BreastSideChart({super.key});

  @override
  Widget build(BuildContext context) {
    final history = Provider.of<HistoryModel>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildChartSegment(context, "Left", history.leftBreastPercentage, Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        _buildChartSegment(context, "Right", history.rightBreastPercentage, Theme.of(context).colorScheme.secondary),
      ],
    );
  }

  Widget _buildChartSegment(BuildContext context, String label, double percentage, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 80,
          width: 80,
          child: Stack(
            children: [
              SizedBox(
                height: 80,
                width: 80,
                child: CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Center(child: Text("${percentage.toStringAsFixed(0)}%")),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Text(label),
      ],
    );
  }
}
