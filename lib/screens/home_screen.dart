import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../components/task_container.dart';
import '../core/constants.dart';
import '../core/modals/side_quests.dart';
import '../core/profile.dart';
import '../utils/audio.dart';
import 'pomodoro_screen.dart';
import 'screen.dart';

final class HomeScreen extends Screen {
  const HomeScreen(super.profile, {super.key}) : super(title: 'Home');

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late bool isQuestBeingAdded;
  late int tabIdx;
  late String randomQuote;
  late final TextEditingController textController;
  late final Profile profile;
  late final ConfettiController confettiController;
  late final TabController tabController;

  @override
  void initState() {
    super.initState();
    isQuestBeingAdded = false;
    randomQuote = _randomMotivationalQuote();
    tabIdx = 0;
    profile = widget.profile;
    textController = TextEditingController();
    confettiController = ConfettiController(
      duration: const Duration(milliseconds: 200),
    );
    tabController = TabController(length: 3, vsync: this);
    profile.evaluateTaskCompletion();
  }

  @override
  void dispose() {
    super.dispose();
    confettiController.dispose();
    tabController.dispose();
    textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scrnSize = MediaQuery.sizeOf(context);

    final currentTime = DateTime.now();
    final dailyTEndTime =
        DateTime.fromMillisecondsSinceEpoch(profile.dailyTaskEndTime)
            .difference(currentTime);
    final weeklyTEndTime =
        DateTime.fromMillisecondsSinceEpoch(profile.weeklyTaskEndTime)
            .difference(currentTime);

    late final String dailyTEndTimeStr;
    late final String dailyTEndTimeUnit;

    if (dailyTEndTime.inHours > 0) {
      final hours = dailyTEndTime.inHours;
      final minutes = (dailyTEndTime.inMinutes - hours * 60) ~/ 6;
      dailyTEndTimeStr = '$hours.$minutes';
      dailyTEndTimeUnit = 'hours';
    } else {
      dailyTEndTimeStr = '${dailyTEndTime.inMinutes}';
      dailyTEndTimeUnit = 'minutes';
    }

    late final String weeklyTEndTimeStr;
    late final String weeklyTEndTimeUnit;

    if (weeklyTEndTime.inDays > 0) {
      final days = weeklyTEndTime.inDays;
      final hours = (weeklyTEndTime.inHours - days * 24) ~/ 2.4;
      weeklyTEndTimeStr = '$days.$hours';
      weeklyTEndTimeUnit = 'days';
    } else if (weeklyTEndTime.inHours > 0) {
      final hours = weeklyTEndTime.inHours;
      final minutes = (weeklyTEndTime.inMinutes - hours * 60) ~/ 6;
      weeklyTEndTimeStr = '$hours.$minutes';
      weeklyTEndTimeUnit = 'hours';
    } else {
      weeklyTEndTimeStr = '${weeklyTEndTime.inMinutes}';
      weeklyTEndTimeUnit = 'minutes';
    }

    final int completedTask =
        profile.dailyTasks.where((t) => t.isComplete).length +
            profile.weeklyTasks.where((t) => t.isComplete).length;

    final int totalTask = profile.dailyTasks.length +
        profile.weeklyTasks.length +
        profile.sideQuests.length;

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: scrnSize.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fitWidth,
                    image: AssetImage('assets/dew-leaf.png'),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 10.0,
                    left: 5.0,
                    right: 5.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 10.0),
                        child: Text(
                          "Hello there!",
                          style: TextStyle(fontSize: 13, color: Colors.white),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Text(
                          "Tasks completed:",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          '$completedTask/$totalTask',
                          style: TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          randomQuote,
                          maxLines: 5,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: TabBar(
                  dividerHeight: 0.0,
                  controller: tabController,
                  labelColor: const Color.fromARGB(255, 0, 0, 0),
                  unselectedLabelColor: const Color.fromARGB(129, 0, 0, 0),
                  tabs: [
                    Tab(child: Text("Daily Tasks")),
                    Tab(child: Text("Weekly Tasks")),
                    Tab(child: Text("Side Quests")),
                  ],
                ),
              ),
              SizedBox(
                height: 300,
                child: TabBarView(
                  controller: tabController,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          for (final task in profile.dailyTasks)
                            TaskContainer(
                              task,
                              onDone: () {
                                profile
                                    .markTaskComplete(TaskType.daily, task)
                                    .then((_) {
                                  if (mounted) {
                                    setState(() {});
                                    confettiController.play();
                                    playJingle();
                                  }
                                });
                              },
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  dailyTEndTimeStr,
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(' $dailyTEndTimeUnit left'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: ListView(
                        children: [
                          for (final task in profile.weeklyTasks)
                            TaskContainer(
                              task,
                              onDone: () {
                                profile
                                    .markTaskComplete(TaskType.weekly, task)
                                    .then((_) {
                                  if (mounted) {
                                    setState(() {});
                                    confettiController.play();
                                    playJingle();
                                  }
                                });
                              },
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  weeklyTEndTimeStr,
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(' $weeklyTEndTimeUnit left'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: ListView(
                        children: [
                          for (final quest in profile.sideQuests)
                            TaskContainer(
                              quest,
                              onDone: () {
                                profile
                                    .markTaskComplete(
                                        TaskType.sideQuests, quest)
                                    .then((_) {
                                  if (mounted) {
                                    setState(() {});
                                    confettiController.play();
                                    playJingle();
                                  }
                                });
                              },
                            ),
                          if (isQuestBeingAdded)
                            Card(
                              elevation: 5.0,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 10.0,
                                  right: 10.0,
                                  bottom: 5.0,
                                ),
                                child: TextField(
                                  controller: textController,
                                ),
                              ),
                            ),
                          const SizedBox(height: 10.0),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade100,
                              elevation: 5.0,
                            ),
                            onPressed: () {
                              if (isQuestBeingAdded) {
                                final quest = SideQuest(
                                  id: DateTime.now().second,
                                  label: textController.text,
                                );
                                profile.addSideQuest(quest).then((_) {
                                  if (mounted) {
                                    setState(() {
                                      textController.clear();
                                      isQuestBeingAdded = false;
                                    });
                                  }
                                });
                              }

                              setState(() {
                                isQuestBeingAdded = true;
                              });
                            },
                            child: const Text(
                              "Add Side Quest",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: ConfettiWidget(
                  confettiController: confettiController,
                  blastDirection: -pi / 2.0,
                  blastDirectionality: BlastDirectionality.explosive,
                  numberOfParticles: 30,
                ),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, right: 10.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PomodoroScreen()),
                );
              },
              backgroundColor: Colors.white,
              icon: const Icon(
                Icons.timer_outlined,
                size: 28,
                color: Colors.black,
              ),
              label: const Text(
                'Pomodoro',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String _randomMotivationalQuote() {
  const quotes = <String>[
    "Best day to finish your work!",
    "You're 1 step closer to perfection!",
    "The day couldn't be any better!",
    "It's the perfect time!",
    "Happiness is key!",
    "Get ready with a cuppa' coffe",
    "You look the best when you smile :)",
    "You have made a great amount of progress!"
  ];
  final random = Random();
  final index = random.nextInt(quotes.length);
  return quotes[index];
}
