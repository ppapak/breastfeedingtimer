import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'models.dart';
import 'providers.dart';
import 'widgets.dart';
import 'settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BabyProvider()),
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
    const Color primarySeedColor = Color(0xFF6750A4);

    final TextTheme appTextTheme = TextTheme(
      displayLarge:
          GoogleFonts.roboto(fontSize: 57, fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.roboto(fontSize: 14),
    );

    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.light,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        titleTextStyle: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle:
              GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
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
        titleTextStyle:
            GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.deepPurple.shade200,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle:
              GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TextEditingController _nameController;
  final FocusNode _nameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _nameFocusNode.addListener(_onNameFocusChange);
  }

  @override
  void dispose() {
    _nameFocusNode.removeListener(_onNameFocusChange);
    _nameFocusNode.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onNameFocusChange() {
    if (!_nameFocusNode.hasFocus) {
      final babyProvider = Provider.of<BabyProvider>(context, listen: false);
      babyProvider.updateBabyName(_nameController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final history = Provider.of<HistoryModel>(context);
    final babyProvider = Provider.of<BabyProvider>(context);

    if (_nameController.text != babyProvider.babyName) {
      _nameController.text = babyProvider.babyName ?? '';
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              GestureDetector(
                onTap: () => babyProvider.pickBabyPhoto(),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: babyProvider.babyPhotoPath == null
                          ? Theme.of(context).colorScheme.surfaceContainerHighest
                          : Colors.transparent,
                      backgroundImage: babyProvider.babyPhotoPath != null
                          ? FileImage(File(babyProvider.babyPhotoPath!))
                          : null,
                    ),
                    if (babyProvider.babyPhotoPath == null)
                      const Icon(Icons.add_a_photo, size: 20),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  style: Theme.of(context).appBarTheme.titleTextStyle,
                  decoration: InputDecoration(
                    hintText: 'Baby Name?',
                    border: InputBorder.none,
                    hintStyle: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                  ),
                  onTap: () {
                    if (_nameController.text == 'Baby Name?') {
                      _nameController.clear();
                    }
                  },
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(themeProvider.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode),
              onPressed: () => themeProvider.toggleTheme(),
              tooltip: 'Toggle Theme',
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                final historyText = history.activities
                    .take(200)
                    .map((activity) {
                      if (activity is FeedSession) {
                        return 'Feed at ${activity.startTime.toLocal()} for ${activity.duration.inMinutes} minutes on the ${activity.breastSide.toString().split('.').last} breast.';
                      } else if (activity is SolidFeed) {
                        return 'Solid food at ${activity.startTime.toLocal()}: ${activity.foodItem}.';
                      }
                      return '';
                    })
                    .join('\n');

                final params = ShareParams(
                  title: "Baby's Feeding History",
                  text: historyText,
                );

                SharePlus.instance.share(params);
              },
              tooltip: 'Share',
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
              tooltip: 'Settings',
            ),
          ],
        ),
        body: const Column(
          children: [
            TimerSection(),
            StatsPanel(),
            Expanded(
              child: HistoryList(),
            ),
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
    final history = Provider.of<HistoryModel>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBreastButton(context, BreastSide.left, timer, history),
          _buildAddButton(context, timer.isRunning),
          _buildBreastButton(context, BreastSide.right, timer, history),
        ],
      ),
    );
  }

  Widget _buildBreastButton(BuildContext context, BreastSide side,
      TimerModel timer, HistoryModel history) {
    final isSelected = timer.isRunning && timer.currentSide == side;
    final isDisabled = timer.isRunning && !isSelected;
    const buttonSize = 160.0;

    final totalLeft = history.totalDurationForSide(BreastSide.left);
    final totalRight = history.totalDurationForSide(BreastSide.right);
    final totalDuration = totalLeft + totalRight;

    double percentage = 0.0;
    if (totalDuration.inSeconds > 0) {
      if (side == BreastSide.left) {
        percentage = totalLeft.inSeconds / totalDuration.inSeconds;
      } else {
        percentage = totalRight.inSeconds / totalDuration.inSeconds;
      }
    }

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
            value: percentage,
            strokeWidth: 10,
            strokeAlign: -2,
            backgroundColor: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withAlpha(128),
            valueColor: AlwaysStoppedAnimation<Color>(
              side == BreastSide.left
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.secondary,
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: isDisabled
                  ? null
                  : () {
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
                backgroundColor: isSelected
                    ? Theme.of(context).colorScheme.tertiary
                    : Theme.of(context).colorScheme.surface,
                foregroundColor: isSelected
                    ? Theme.of(context).colorScheme.onTertiary
                    : Theme.of(context).colorScheme.onSurface,
                elevation: 8,
              ),
              child: isSelected
                  ? Text(formatDuration(timer.duration),
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold))
                  : Text(side == BreastSide.left ? "L" : "R",
                      style: const TextStyle(
                          fontSize: 60, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, bool isDisabled) {
    return FloatingActionButton(
      onPressed: isDisabled
          ? null
          : () async {
              showDialog(
                  context: context,
                  builder: (context) => const ManualEntryDialog());
            },
      elevation: 8,
      child: const Icon(Icons.add, size: 40),
    );
  }
}
