import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/botm_nav_bar.dart';
import 'core/db_handler.dart';
import 'core/profile.dart';
import 'screens/home_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/pool_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  // NOTE: Must always stay at top for other things to work.
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isFirstTime = prefs.getBool('isFirstTime') ?? true;
  final db = await DbHandler.getInstance();

  if (kDebugMode) {
    await db.setToDebugMode();
  } else if (isFirstTime) {
    await prefs.setBool('isFirstTime', false);
    await db.setToDefault();
  }

  late final Profile profile;

  try {
    profile = await Profile.fromDb(db);
  } catch (e) {
    // TODO: add error screen thing (Anuj)
    runApp(MaterialApp(
      title: 'Lvl Up',
      debugShowCheckedModeBanner: kDebugMode,
      theme: ThemeData(useMaterial3: true),
      home: Text(e.toString()),
    ));
    return;
  }

  runApp(MaterialApp(
    title: 'Lvl Up',
    debugShowCheckedModeBanner: kDebugMode,
    theme: ThemeData(useMaterial3: true),
    home: MyApp(profile),
  ));
}

final class MyApp extends StatefulWidget {
  const MyApp(this.profile, {super.key});

  final Profile profile;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late int pageIdx;
  late final List<Screen> pages;
  late final PageController pageController;
  late final Profile profile;

  @override
  void initState() {
    profile = widget.profile;
    pageIdx = 0;
    pages = [
      HomeScreen(profile),
      InventoryScreen(profile),
      PoolScreen(profile),
      SettingsScreen(profile),
    ];
    pageController = PageController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final page = pages[pageIdx];

    return Scaffold(
      drawer: Drawer(child: SettingsScreen(profile)),
      appBar: AppBar(
        title: Text(
          page.title,
          style: GoogleFonts.monda(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(profile),
                ),
              );
            },
            icon: Icon(
              Icons.person_outline_rounded,
              color: Colors.purple.shade500,
            ),
          )
        ],
      ),
      body: PageView(
        controller: pageController,
        physics: NeverScrollableScrollPhysics(),
        children: pages,
      ),
      bottomNavigationBar: BotmNavBar(
        selectedIdx: pageIdx,
        onIdxChange: (int idx) {
          setState(() => pageIdx = idx);
          pageController.animateToPage(
            idx,
            duration: const Duration(milliseconds: 320),
            curve: Curves.linear,
          );
        },
      ),
    );
  }
}
