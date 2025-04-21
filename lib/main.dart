import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/db_handler.dart';
import 'core/profile.dart';
import 'screens/home_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/pool_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/screen.dart';
import 'screens/settings_screen.dart';

import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

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
    debugShowCheckedModeBanner: false, // TODO
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
  late final Profile profile;

  @override
  void initState() {
    profile = widget.profile;
    pageIdx = 0;
    pages = [
      HomeScreen(profile),
      PoolScreen(profile),
      InventoryScreen(profile),
      SettingsScreen(profile),
    ];
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
              icon: ClipOval(child: Image.asset('assets/face.jpg')),
            )
          ],
        ),
        body: pages[pageIdx],
        bottomNavigationBar: StylishBottomBar(
          option: DotBarOptions(
            dotStyle: DotStyle.tile,
            gradient: const LinearGradient(
              colors: [
                Colors.deepPurple,
                Colors.pink,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          items: [
            BottomBarItem(
              icon: const Icon(Icons.home_outlined),
              title: const Text('Home'),
              backgroundColor: Colors.black,
              selectedIcon: const Icon(Icons.home_filled),
            ),
            BottomBarItem(
              icon: const Icon(Icons.add_circle),
              title: const Text('Add Tasks'),
              backgroundColor: Colors.orange,
            ),
            BottomBarItem(
              icon: const Icon(Icons.inventory),
              title: const Text('Rewards'),
              backgroundColor: const Color.fromARGB(255, 6, 194, 128),
            ),
          ],
          currentIndex: pageIdx,
          onTap: (index) {
            setState(() {
              pageIdx = index;
            });
          },
        ));
  }
}
