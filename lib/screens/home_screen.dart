import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../components/task_group.dart';
import '../core/constants.dart';
import '../core/modals.dart';
import '../core/profile.dart';
import 'screen.dart';

final class HomeScreen extends Screen {
  const HomeScreen(super.profile, {super.key}) : super(title: 'Home');

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final Profile profile;
  late final ConfettiController confettiController;

  @override
  void initState() {
    super.initState();
    profile = widget.profile;
    confettiController = ConfettiController(
      duration: const Duration(milliseconds: 200),
    );
    _evaluateTasks();
  }

  @override
  void dispose() {
    super.dispose();
    confettiController.dispose();
  }

  void _evaluateTasks() async {
    await profile.evaluateTaskCompletion();
  }

  @override
  Widget build(BuildContext context) {
    TabController tabController = TabController(length: 3, vsync: this);
    const space = SizedBox(height: 20.0);

    final currentTime = DateTime.now();
    final dailyTEndTime =
        DateTime.fromMillisecondsSinceEpoch(profile.dailyTaskEndTime)
            .difference(currentTime);
    final weeklyTEndTime =
        DateTime.fromMillisecondsSinceEpoch(profile.weeklyTaskEndTime)
            .difference(currentTime);

    late final String dailyTSubtitle;

    if (dailyTEndTime.inHours > 0) {
      final hours = dailyTEndTime.inHours;
      final minutes = (dailyTEndTime.inMinutes - hours * 60) ~/ 6;
      dailyTSubtitle = '$hours.$minutes hours left';
    } else {
      dailyTSubtitle = '${dailyTEndTime.inMinutes} minutes left';
    }

    late final String weeklyTSubtitle;

    if (weeklyTEndTime.inDays > 0) {
      final days = weeklyTEndTime.inDays;
      final hours = (weeklyTEndTime.inHours - days * 24) ~/ 2.4;
      weeklyTSubtitle = '$days.$hours days left';
    } else if (weeklyTEndTime.inHours > 0) {
      final hours = weeklyTEndTime.inHours;
      final minutes = (weeklyTEndTime.inMinutes - hours * 60) ~/ 6;
      weeklyTSubtitle = '$hours.$minutes hours left';
    } else {
      weeklyTSubtitle = '${weeklyTEndTime.inMinutes} minutes left';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            "Hello Mary",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: Text(
            "You have 4/7 tasks left to complete",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 5,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: tabController,
                // indicator: BoxDecoration(
                //   color: Colors.orange,
                //   borderRadius: BorderRadius.circular(12),
                // ),
                labelColor: const Color.fromARGB(255, 0, 0, 0),
                unselectedLabelColor: const Color.fromARGB(129, 0, 0, 0),
                tabs: [
                  Tab(child: Text("Daily Tasks")),
                  Tab(child: Text("Weekly Tasks")),
                  Tab(child: Text("Side Quests")),
                ],
              ),
            ),
          ),
        ),
        Expanded(
            child: TabBarView(
          controller: tabController,
          children: [
            TaskGroup(
              'Daily Tasks',
              subtitle: '($dailyTSubtitle)',
              tasks: profile.dailyTasks,
              onDone: (rawTask) => setState(() {
                final task = rawTask as Task;
                if (task.isComplete) return;

                profile.markTaskComplete(TaskType.daily, task);
                confettiController.play();
              }),
            ),
            TaskGroup(
              'Weekly Tasks',
              subtitle: '($weeklyTSubtitle)',
              tasks: profile.weeklyTasks,
              onDone: (rawTask) => setState(() {
                final task = rawTask as Task;
                if (task.isComplete) return;

                profile.markTaskComplete(TaskType.weekly, task);
                confettiController.play();
              }),
            ),
            TaskGroup(
              'Side Quests',
              tasks: profile.sideQuests,
              onDone: (rawTask) => setState(() {
                final quest = rawTask as SideQuest;
                if (quest.isComplete) return;

                profile.markTaskComplete(
                  TaskType.sideQuests,
                  quest,
                );
                confettiController.play();
              }),
            ),
          ],
        )),
        ConfettiWidget(
          confettiController: confettiController,
          blastDirection: -pi / 2.0,
          emissionFrequency: 0.4,
          blastDirectionality: BlastDirectionality.explosive,
          numberOfParticles: 20,
        ),
      ],
    );
  }
}
