import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/bullet_list_view.dart';
import '../core/constants.dart';
import '../core/modals.dart';
import '../core/profile.dart';
import '../utils/audio.dart';
import '../utils/text.dart';
import 'screen.dart';

final class InventoryScreen extends Screen {
  const InventoryScreen(super.profile, {super.key}) : super(title: 'Inventory');

  @override
  State<StatefulWidget> createState() => _InventoryScreenState();
}

final class _InventoryScreenState extends State<InventoryScreen> {
  late final Profile profile;
  late final ConfettiController confettiController;

  @override
  void initState() {
    super.initState();
    profile = widget.profile;
    confettiController = ConfettiController(
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    super.dispose();
    confettiController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Rewards',
              style: GoogleFonts.monda(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            _CurrentRewardsContainer(
              profile,
              onRewardUse: () => setState(() {}),
            ),
            const SizedBox(height: 15.0),
            Text(
              'Pending Punishments',
              style: GoogleFonts.monda(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            _PendingPunishmentsContainer(
              profile,
              onDone: () {
                setState(() {});
                confettiController.play();
                playJingle();
              },
            ),
            Center(
              child: ConfettiWidget(
                confettiController: confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== EVERY REWARD RELATED THING ===========================

class _ClickedRewardCard extends StatelessWidget {
  const _ClickedRewardCard({
    required this.title,
    required this.description,
    required this.color,
    required this.onUse,
  });

  final String title;
  final String description;
  final Color color;
  final void Function() onUse;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final width = mq.size.width;
    final height = mq.size.height;
    final dialogSize = width < 500.0 ? 0.75 * width : 400.0; // clamp

    final horPadding = (width - dialogSize) / 2;
    final vertPadding = (height - dialogSize) / 2;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horPadding,
        vertical: vertPadding,
      ),
      child: Card(
        color: color,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                title,
                style: GoogleFonts.monda(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 30.0,
                ),
                child: OutlinedButton(
                  onPressed: onUse,
                  child: Text(
                    'Use',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentRewardsContainer extends StatelessWidget {
  const _CurrentRewardsContainer(
    this.profile, {
    required this.onRewardUse,
  });

  final Profile profile;
  final void Function() onRewardUse;

  @override
  Widget build(BuildContext context) {
    if (profile.currentRewards.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: const Text("Rewards will appear here when you get them :)"),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: Colors.black26,
          width: 2.0,
        ),
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        const numberOfCards = 4;
        final width = constraints.maxWidth;
        const cardPadding = 10.0;
        final cardSize = (width - 3.0 * cardPadding) / numberOfCards;
        final height = 2.2 * cardSize + 2.0 * cardPadding;

        return SizedBox(
          height: height,
          child: GridView(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: numberOfCards,
              crossAxisSpacing: cardPadding,
              mainAxisSpacing: cardPadding,
            ),
            children: profile.currentRewards.map((reward) {
              return _RewardCard(reward, onRewardUse, profile);
            }).toList(),
          ),
        );
      }),
    );
  }
}

class _RewardCard extends StatelessWidget {
  const _RewardCard(this.reward, this.onRewardEnd, this.profile);

  final Reward reward;
  final void Function() onRewardEnd;
  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final color = _rewardTypeToColor(reward.rewardType);

    return GestureDetector(
      onTap: () {
        // showDialog shows whatever child but expanded to the max
        showDialog(
          context: context,
          builder: (context) {
            return _ClickedRewardCard(
              title: _rewardTypeToTitle(reward.rewardType),
              description: reward.label,
              color: color,
              onUse: () {
                switch (reward.rewardType) {
                  // the ones that will need a menu
                  case RewardType.skipDailyTask:
                    _showSkipDailyTaskMenu(
                      context,
                      reward,
                      profile,
                      onRewardEnd,
                    );
                    break;
                  case RewardType.skipWeeklyTask:
                    _showSkipWeeklyTaskMenu(
                      context,
                      reward,
                      profile,
                      onRewardEnd,
                    );
                    break;
                  case RewardType.skipPunishment:
                    _showSkipPunishmentMenu(
                      context,
                      reward,
                      profile,
                      onRewardEnd,
                    );
                    break;
                  case RewardType.rerollDailyTask:
                    _showRerollDailyTaskMenu(
                      context,
                      reward,
                      profile,
                      onRewardEnd,
                    );
                    break;
                  case RewardType.rerollWeeklyTask:
                    _showRerollWeeklyTaskMenu(
                      context,
                      reward,
                      profile,
                      onRewardEnd,
                    );
                    break;
                  case RewardType.increaseStat:
                    _showIncreaseStatMenu(
                      context,
                      reward,
                      profile,
                      onRewardEnd,
                    );
                    // TODO: something to make x points gets added instead of a
                    // hard-coded number
                    break;

                  // the ones that won't need a menu
                  case RewardType.extendDTaskTime:
                    // TODO: need something to make sure to extend by a certain
                    // amount of time
                    //
                    // For now, extend by half a day precisely
                    _extendTime(profile, TaskType.daily,
                        dTaskTimeSpanMilliseconds ~/ 2);

                    // close the card and also remove it
                    Navigator.pop(context);
                    onRewardEnd();
                    break;
                  case RewardType.extendWTaskTime:
                    // TODO: need something to make sure to extend by a certain
                    // amount of time
                    //
                    // For now, extend by half a week precisely
                    _extendTime(profile, TaskType.weekly,
                        wTaskTimeSpanMilliseconds ~/ 2);

                    // close the card and also remove it
                    Navigator.pop(context);
                    onRewardEnd();
                    break;
                  case RewardType.skipEveryTask:
                    _skipEveryTaskWithReward(reward, profile);

                    // close the card and also remove it
                    Navigator.pop(context);
                    onRewardEnd();
                    break;
                  case RewardType.skipAllPunishments:
                    _skipAllPunishmentWithReward(
                      reward,
                      profile.pendingPunishments,
                      profile,
                    );

                    // close the card and also remove it
                    Navigator.pop(context);
                    onRewardEnd();
                    break;
                  case RewardType.skipAllDailyTasks:
                    _skipTasksWithReward(
                      reward,
                      profile.dailyTasks,
                      TaskType.daily,
                      profile,
                    );

                    // close the card and also remove it
                    Navigator.pop(context);
                    onRewardEnd();
                    break;
                  case RewardType.skipAllWeeklyTasks:
                    _skipTasksWithReward(
                      reward,
                      profile.weeklyTasks,
                      TaskType.weekly,
                      profile,
                    );

                    // close the card and also remove it
                    Navigator.pop(context);
                    onRewardEnd();
                    break;
                  case RewardType.noSideEffect:
                    _removeReward(reward, profile);

                    // close the card and also remove it
                    Navigator.pop(context);
                    onRewardEnd();
                    break;
                }
              },
            );
          },
        );
      },
      child: Card(color: color),
    );
  }

  static String _rewardTypeToTitle(final RewardType rewardType) {
    if (rewardType == RewardType.noSideEffect) return 'Woohooo';
    return pascalToNormal(rewardType.name);
  }

  static Color _rewardTypeToColor(RewardType rewardType) {
    switch (rewardType) {
      case RewardType.extendDTaskTime:
      case RewardType.extendWTaskTime:
        return Colors.pinkAccent;
      case RewardType.rerollDailyTask:
      case RewardType.rerollWeeklyTask:
        return Colors.orangeAccent;
      case RewardType.skipAllDailyTasks:
      case RewardType.skipAllWeeklyTasks:
      case RewardType.skipAllPunishments:
      case RewardType.skipEveryTask:
      case RewardType.skipWeeklyTask:
      case RewardType.skipDailyTask:
      case RewardType.skipPunishment:
        return Colors.greenAccent;
      default:
        return Colors.lightGreenAccent;
    }
  }
}

// ================== Things to help with the reward thingy ====================
Future<void> _extendTime(
  final Profile profile,
  final TaskType taskType,
  final int milliseconds,
) async {
  await profile.extendTime(taskType, milliseconds);
}

Future<void> _increaseStatWithReward(
  final Reward reward,
  final String statName,
  final int amount,
  final Profile profile,
) async {
  await profile.removeFromCurrentReward(reward);
  await profile.increaseStat(statName, amount);
}

Future<void> _removeReward(final Reward reward, final Profile profile) async {
  await profile.removeFromCurrentReward(reward);
}

Future<void> _rerollTaskWithReward(
  final Reward reward,
  final Task task,
  final TaskType taskType,
  final Profile profile,
) async {
  await profile.removeFromCurrentReward(reward);
  await profile.addUniqueTasks(taskType, 1);
  await profile.removePendingTask(taskType, task);
}

Future<void> _skipEveryTaskWithReward(
  final Reward reward,
  final Profile profile,
) async {
  await profile.removeFromCurrentReward(reward);

  for (final task in profile.dailyTasks) {
    await profile.markTaskComplete(TaskType.daily, task);
  }

  for (final task in profile.weeklyTasks) {
    await profile.markTaskComplete(TaskType.weekly, task);
  }
}

Future<void> _skipAllPunishmentWithReward(
  final Reward reward,
  final List<Punishment> punishment,
  final Profile profile,
) async {
  await profile.removeFromCurrentReward(reward);

  for (final punishment in profile.pendingPunishments) {
    await profile.markPunishmentComplete(punishment);
  }
}

Future<void> _skipTasksWithReward(
  final Reward reward,
  final List<Task> tasks,
  final TaskType taskType,
  final Profile profile,
) async {
  await profile.removeFromCurrentReward(reward);

  for (final task in tasks) {
    await profile.markTaskComplete(taskType, task);
  }
}

final class _SelectMenu extends StatelessWidget {
  const _SelectMenu({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // essentially an app bar
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back),
              ),
              const Text('Choose one')
            ],
          ),

          // scroll bar
          Flexible(child: ListView(children: children)),
        ],
      ),
    );
  }
}

void _showIncreaseStatMenu(
  BuildContext context,
  Reward reward,
  Profile profile,
  void Function() onEnd,
) {
  showDialog(
    context: context,
    builder: (context) {
      final statNames = profile.stats.keys.where(
        (name) => name.startsWith('prev') == false,
      );

      return _SelectMenu(
        children: statNames.map((stat) {
          return OutlinedButton(
            onPressed: () {
              _increaseStatWithReward(reward, stat, 5, profile);

              // pop the both dialog (clicked card and card)
              Navigator.pop(context);
              Navigator.pop(context);

              onEnd();
            },
            child: Text(stat),
          );
        }).toList(growable: false),
      );
    },
  );
}

void _showRerollDailyTaskMenu(
  BuildContext context,
  Reward reward,
  Profile profile,
  void Function() onEnd,
) {
  showDialog(
    context: context,
    builder: (context) {
      final tasks = profile.dailyTasks;
      final filteredTasks = tasks.where((e) => !e.isComplete);

      return _SelectMenu(
        children: filteredTasks.map((task) {
          return OutlinedButton(
            onPressed: () {
              _rerollTaskWithReward(reward, task, TaskType.daily, profile);

              // pop the both dialog (clicked card and card)
              Navigator.pop(context);
              Navigator.pop(context);

              onEnd();
            },
            child: Text(task.label),
          );
        }).toList(growable: false),
      );
    },
  );
}

void _showRerollWeeklyTaskMenu(
  BuildContext context,
  Reward reward,
  Profile profile,
  void Function() onEnd,
) {
  showDialog(
    context: context,
    builder: (context) {
      final tasks = profile.weeklyTasks;
      final filteredTasks = tasks.where((e) => !e.isComplete);

      return _SelectMenu(
        children: filteredTasks.map((task) {
          return OutlinedButton(
            onPressed: () {
              _rerollTaskWithReward(reward, task, TaskType.weekly, profile);

              // pop the both dialog (clicked card and card)
              Navigator.pop(context);
              Navigator.pop(context);

              onEnd();
            },
            child: Text(task.label),
          );
        }).toList(growable: false),
      );
    },
  );
}

void _showSkipDailyTaskMenu(
  BuildContext context,
  Reward reward,
  Profile profile,
  void Function() onEnd,
) {
  showDialog(
    context: context,
    builder: (context) {
      final tasks = profile.dailyTasks;
      final filteredTasks = tasks.where((e) => !e.isComplete);

      return _SelectMenu(
        children: filteredTasks.map((task) {
          return OutlinedButton(
            onPressed: () {
              _skipTasksWithReward(reward, [task], TaskType.daily, profile);

              // pop the both dialog (clicked card and card)
              Navigator.pop(context);
              Navigator.pop(context);

              onEnd();
            },
            child: Text(task.label),
          );
        }).toList(growable: false),
      );
    },
  );
}

void _showSkipPunishmentMenu(
  BuildContext context,
  Reward reward,
  Profile profile,
  void Function() onEnd,
) {
  showDialog(
    context: context,
    builder: (context) {
      final pnishmnts = profile.pendingPunishments;
      final filtered = pnishmnts.where((e) => !e.isComplete);

      return _SelectMenu(
        children: filtered.map((punishment) {
          return OutlinedButton(
            onPressed: () {
              _skipAllPunishmentWithReward(reward, [punishment], profile);

              // pop the both dialog (clicked card and card)
              Navigator.pop(context);
              Navigator.pop(context);

              onEnd();
            },
            child: Text(punishment.label),
          );
        }).toList(growable: false),
      );
    },
  );
}

void _showSkipWeeklyTaskMenu(
  BuildContext context,
  Reward reward,
  Profile profile,
  void Function() onEnd,
) {
  showDialog(
    context: context,
    builder: (context) {
      final tasks = profile.weeklyTasks;
      final filteredTasks = tasks.where((e) => !e.isComplete);

      return _SelectMenu(
        children: filteredTasks.map((task) {
          return OutlinedButton(
            onPressed: () {
              _skipTasksWithReward(reward, [task], TaskType.weekly, profile);

              // pop the both dialog (clicked card and card)
              Navigator.pop(context);
              Navigator.pop(context);

              onEnd();
            },
            child: Text(task.label),
          );
        }).toList(growable: false),
      );
    },
  );
}

// ===================== EVERY PUNISHMENT RELATED THING =======================

class _PendingPunishmentsContainer extends StatelessWidget {
  const _PendingPunishmentsContainer(this.profile, {required this.onDone});

  final Profile profile;
  final void Function() onDone;

  @override
  Widget build(BuildContext context) {
    final punishments = profile.pendingPunishments;
    late final List<Widget> children;

    if (punishments.isEmpty) {
      children = [Text("None because you are punctual and awesome :)")];
    } else {
      children = punishments.map((punishment) {
        return BulletCheckTile(
          label: punishment.label,
          isDone: false,
          onDone: () {
            _markPunishmentAsComplete(profile, punishment)
                .then((_) => onDone());
          },
        );
      }).toList(growable: false);
    }

    return Card(
      elevation: 5,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(shrinkWrap: true, children: children),
      ),
    );
  }
}

Future<void> _markPunishmentAsComplete(
  final Profile profile,
  final Punishment punishment,
) async {
  await profile.markPunishmentComplete(punishment);
}
