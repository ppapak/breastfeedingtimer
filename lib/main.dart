
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'models.dart';
import 'providers.dart';
import 'widgets.dart';
import 'baby_provider.dart';
import 'settings_page.dart';
import 'purchase_provider.dart';
import 'paywall_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TimerModel()),
        ChangeNotifierProvider(create: (context) => HistoryModel()),
        ChangeNotifierProvider(create: (context) => BabyModel()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        Provider(create: (context) => PurchaseProvider()),
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
    final purchaseProvider = Provider.of<PurchaseProvider>(context, listen: false);
    purchaseProvider.initialize();

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Breastfeeding Timer',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
            ),
            textTheme: GoogleFonts.latoTextTheme(),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            textTheme: GoogleFonts.latoTextTheme(),
          ),
          themeMode: themeProvider.themeMode,
          home: const InitialScreen(),
        );
      },
    );
  }
}

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  InitialScreenState createState() => InitialScreenState();
}

class InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();
    if (kReleaseMode) {
      _checkTrialStatus();
    }
  }

  Future<void> _checkTrialStatus() async {
    final purchaseProvider = Provider.of<PurchaseProvider>(context, listen: false);
    final isTrialActive = await purchaseProvider.isTrialActive();

    if (!isTrialActive) {
      final isPurchased = purchaseProvider.isProductPurchased('subscription_gold');
      if (!isPurchased) {
        if (mounted) {
          unawaited(
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PaywallScreen(purchaseProvider: purchaseProvider),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
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
    Share.share('Check out this awesome breastfeeding timer app!\n\n[App URL goes here]');
  }

  @override
  Widget build(BuildContext context) {
    final babyModel = Provider.of<BabyModel>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                babyModel.pickImage();
              },
              child: CircleAvatar(
                radius: 20,
                backgroundImage: babyModel.babyImage != null ? FileImage(babyModel.babyImage!) : null,
                child: babyModel.babyImage == null
                    ? const Icon(Icons.add_a_photo, size: 20)
                    : null,
              ),
            ),
            const SizedBox(width: 10),
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
                      babyModel.babyName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                  ),
          ],
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

    String formatDuration(Duration d) {
      return "${d.inMinutes.toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8.0),
      child: Column(
        children: [
          Text(
            formatDuration(timer.duration),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 24),
          Consumer<HistoryModel>(
            builder: (context, history, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBreastButton(context, BreastSide.left, timer, history),
                  _buildAddButton(context),
                  _buildBreastButton(context, BreastSide.right, timer, history),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBreastButton(BuildContext context, BreastSide side, TimerModel timer, HistoryModel history) {
    final isSelected = timer.isRunning && timer.currentSide == side;
    final percentage = side == BreastSide.left ? history.leftBreastPercentage : history.rightBreastPercentage;
    const buttonSize = 110.0;

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
              child: Text(side == BreastSide.left ? "L" : "R", style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(context, "Feeds/24h", "${history.feedsInLast24Hours}", Icons.restaurant_menu),
              _buildStatItem(context, "Total Today", "${history.totalTodayDuration.inMinutes}m", Icons.timer),
              _buildStatItem(context, "Last Feed", formatDuration(history.timeSinceLastFeed), Icons.history),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.secondary, size: 28),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
