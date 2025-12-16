
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'models.dart';
import 'providers.dart';
import 'widgets.dart';
import 'purchase_provider.dart';
import 'notification_service.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final history = HistoryModel();
    await history.loadHistory(); // You might need to adjust this
    final timeSinceLastFeed = DateTime.now().difference(history.lastFeedTime ?? DateTime.now());

    if (timeSinceLastFeed.inHours >= 5) {
      final notificationService = NotificationService();
      await notificationService.init();
      await notificationService.showNotification(
        'Time for a feed?',
        'It has been over 5 hours since your last logged feed.',
      );
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: kDebugMode);
  Workmanager().registerPeriodicTask(
    "1",
    "checkLastFeed",
    frequency: const Duration(hours: 1),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => TimerModel()),
        ChangeNotifierProvider(create: (context) => HistoryModel()),
        ChangeNotifierProvider(create: (context) => PurchaseProvider()),
      ],
      child: const MyApp(),
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
    final timer = Provider.of<TimerModel>(context);
    final history = Provider.of<HistoryModel>(context);
    final purchaseProvider = Provider.of<PurchaseProvider>(context);

    final isSubscribed = kDebugMode || purchaseProvider.isSubscribed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Material AI Demo'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.auto_mode),
            onPressed: () => themeProvider.setSystemTheme(),
            tooltip: 'Set System Theme',
          ),
        ],
      ),
      body: Column(
        children: [
          const StatsPanel(),
          if (isSubscribed)
            Expanded(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildBreastButton(context, BreastSide.left, timer, history),
                    _buildBreastButton(context, BreastSide.right, timer, history),
                  ],
                ),
              ),
            )
          else
            const Paywall(),
        ],
      ),
      floatingActionButton: isSubscribed ? _buildAddButton(context) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(height: 48),
      ),
    );
  }

  Widget _buildBreastButton(BuildContext context, BreastSide side, TimerModel timer, HistoryModel history) {
    final isSelected = timer.isRunning && timer.currentSide == side;
    final percentage = side == BreastSide.left ? history.leftBreastPercentage : history.rightBreastPercentage;
    const buttonSize = 110.0;

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
            value: percentage / 100,
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
                padding: const EdgeInsets.all(30),
                backgroundColor: isSelected ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.surface,
                foregroundColor: isSelected ? Theme.of(context).colorScheme.onTertiary : Theme.of(context).colorScheme.onSurface,
                elevation: 8,
              ),
              child: isSelected
                  ? Text(formatDuration(timer.duration), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
                  : Text(side == BreastSide.left ? "L" : "R", style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
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
      child: const Icon(Icons.add, size: 32),
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

class Paywall extends StatelessWidget {
  const Paywall({super.key});

  @override
  Widget build(BuildContext context) {
    final purchaseProvider = Provider.of<PurchaseProvider>(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (purchaseProvider.isTrialAvailable)
            ElevatedButton(
              onPressed: () {
                purchaseProvider.startTrial();
              },
              child: const Text('Start 7-Day Free Trial'),
            )
          else
            ElevatedButton(
              onPressed: () {
                purchaseProvider.purchaseSubscription();
              },
              child: const Text('Subscribe Weekly'),
            ),
          const SizedBox(height: 20),
          const Text(
            'Subscribe to access all features',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
