import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'models.dart';
import 'providers.dart';
import 'widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => TimerModel()),
        ChangeNotifierProvider(create: (context) => HistoryModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primarySeedColor = Colors.deepPurple;

    final TextTheme appTextTheme = TextTheme(
      displayLarge: GoogleFonts.oswald(fontSize: 57, fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.openSans(fontSize: 14),
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
          textStyle: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
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
          textStyle: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Flutter Material AI App',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          home: const MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final history = Provider.of<HistoryModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/images/icon2.png'), 
            ),
            SizedBox(width: 10),
            Text('Baby Tracker'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              final summary = "Baby's Feeding Summary:\n"
                  "Feeds in last 24h: ${history.feedsInLast24Hours}\n"
                  "Total duration today: ${history.totalTodayDuration.inMinutes} minutes";
              Share.share(summary);
            },
            tooltip: 'Share',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
            tooltip: 'Settings',
          ),
        ],
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            TimerSection(),
            StatsPanel(),
            HistoryList(),
          ],
        ),
      ),
    );
  }
}

class TimerSection extends StatelessWidget {
  const TimerSection({super.key});

  @override
  Widget build(BuildContext context) {
    final timer = Provider.of<TimerModel>(context);
    final history = Provider.of<HistoryModel>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBreastButton(context, BreastSide.left, timer, history),
          _buildAddButton(context),
          _buildBreastButton(context, BreastSide.right, timer, history),
        ],
      ),
    );
  }

  Widget _buildBreastButton(BuildContext context, BreastSide side, TimerModel timer, HistoryModel history) {
    final isSelected = timer.isRunning && timer.currentSide == side;
    const buttonSize = 150.0;

    String formatDuration(Duration d) {
        if (d.inMinutes > 0) {
            return "${d.inMinutes}m ${d.inSeconds.remainder(60)}s";
        } else {
            return "${d.inSeconds}s";
        }
    }

    return SizedBox(
      height: buttonSize,
      width: buttonSize,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: 0.5, // Placeholder value
            strokeWidth: 10,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(128),
            valueColor: AlwaysStoppedAnimation<Color>(
              side == BreastSide.left
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.secondary,
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                if (timer.isRunning && timer.currentSide == side) {
                  final session = FeedSession(
                    startTime: DateTime.now().subtract(timer.duration),
                    duration: timer.duration,
                    breastSide: side,
                  );
                  history.addActivity(session);
                  timer.stopTimer();
                } else {
                  timer.startTimer(side);
                }
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(40),
                backgroundColor: isSelected ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.surface,
                foregroundColor: isSelected ? Theme.of(context).colorScheme.onTertiary : Theme.of(context).colorScheme.onSurface,
                elevation: 8,
              ),
              child: isSelected
                  ? Text(formatDuration(timer.duration), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
                  : Text(side == BreastSide.left ? "L" : "R", style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        showDialog(context: context, builder: (context) => const ManualEntryDialog());
      },
      elevation: 8,
      child: const Icon(Icons.add, size: 40),
    );
  }
}
