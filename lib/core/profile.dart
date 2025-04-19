import 'dart:math';

import 'constants.dart';
import 'db_handler.dart';
import 'internal_types.dart';
import 'modals.dart';

/// [Profile] is the class that handles everything related to the user data and
/// fetches or modifies the user's data using [DbHanlder _db].
final class Profile {
  Profile({
    required DbHandler db,
    required this.dailyTasks,
    required this.dailyTaskEndTime,
    required this.weeklyTasks,
    required this.weeklyTaskEndTime,
    required this.sideQuests,
    required this.currentRewards,
    required this.pendingPunishments,
    required this.currentLevel,
    required this.prevLevel,
    required this.stats,
    required this.rewardPool,
    required this.punishmentPool,
    required this.dailyTaskPool,
    required this.weeklyTaskPool,
  }) : _db = db;

  final DbHandler _db;
  List<Task> dailyTasks;
  int dailyTaskEndTime;
  List<Task> weeklyTasks;
  int weeklyTaskEndTime;
  List<SideQuest> sideQuests;

  List<Reward> currentRewards;
  List<Punishment> pendingPunishments;

  int currentLevel;
  int prevLevel; // prev Week level but CBB to change var name rn
  StatsMap stats;

  List<Reward> rewardPool;
  List<Punishment> punishmentPool;
  List<Task> dailyTaskPool;
  List<Task> weeklyTaskPool;

  static Future<Profile> fromDb(DbHandler db) async {
    final List<Task> dailyTasks = await db.fetchAs<Task>(
      DbTable.dailyTasks,
      Task.fromJsonMap,
    );

    final int dailyTaskEndTime =
        (await db.fetchFirst(DbTable.dailyTaskEndTime))['time'] as int;

    final List<Task> weeklyTasks = await db.fetchAs<Task>(
      DbTable.weeklyTasks,
      Task.fromJsonMap,
    );

    final int weeklyTaskEndTime =
        (await db.fetchFirst(DbTable.weeklyTaskEndTime))['time'] as int;

    final sideQuests =
        await db.fetchAs<SideQuest>(DbTable.sideQuests, SideQuest.fromJsonMap);

    final List<Reward> currentRewards = await db.fetchAs<Reward>(
      DbTable.currentRewards,
      Reward.fromJsonMap,
    );

    final List<Punishment> pendingPunishments = await db.fetchAs<Punishment>(
      DbTable.pendingPunishments,
      Punishment.fromJsonMap,
    );

    late final int currentLevel;
    late final int prevLevel;
    final rawLevels = await db.fetch(DbTable.level); // both current and prev

    // checking whether the first level is the current level or prev level
    if (rawLevels.first['name'] as String == "current") {
      currentLevel = rawLevels.first['value'] as int;
      prevLevel = rawLevels.last['value'] as int;
    } else {
      currentLevel = rawLevels.last['value'] as int;
      prevLevel = rawLevels.first['value'] as int;
    }

    final rawStats = await db.fetch(DbTable.stats);
    final StatsMap stats = {};

    for (final rawStat in rawStats) {
      final statName = rawStat['name'] as String;
      stats[statName] = rawStat['value'] as int;
    }

    final rewardPool = await db.fetchAs<Reward>(
      DbTable.rewardPool,
      Reward.fromJsonMap,
    );

    final punishmentPool = await db.fetchAs<Punishment>(
      DbTable.punishmentPool,
      Punishment.fromJsonMap,
    );

    final dailyTaskPool = await db.fetchAs<Task>(
      DbTable.dailyTaskPool,
      Task.fromJsonMap,
    );

    final weeklyTaskPool = await db.fetchAs<Task>(
      DbTable.weeklyTaskPool,
      Task.fromJsonMap,
    );

    return Profile(
      db: db,
      dailyTasks: dailyTasks,
      dailyTaskEndTime: dailyTaskEndTime,
      weeklyTasks: weeklyTasks,
      weeklyTaskEndTime: weeklyTaskEndTime,
      sideQuests: sideQuests,
      currentRewards: currentRewards,
      pendingPunishments: pendingPunishments,
      currentLevel: currentLevel,
      prevLevel: prevLevel,
      stats: stats,
      rewardPool: rewardPool,
      punishmentPool: punishmentPool,
      dailyTaskPool: dailyTaskPool,
      weeklyTaskPool: weeklyTaskPool,
    );
  }

  Future<void> addToPendingPunishment() async {
    final length = punishmentPool.length;
    final idx = Random().nextInt(length);
    final punishment = punishmentPool[idx];
    pendingPunishments.add(punishment);
    await _db.insert(DbTable.pendingPunishments, punishment.toJsonMap());
  }

  Future<void> addToDailyTaskPool(final Task task) async {
    final data = task.toJsonMap(excludeRows: ['isComplete']);
    dailyTaskPool.add(task);
    await _db.insert(DbTable.dailyTaskPool, data);
  }

  Future<void> addToPunishmentPool(final Punishment punishment) async {
    final data = punishment.toJsonMap(excludeRows: ['isComplete']);
    punishmentPool.add(punishment);
    await _db.insert(DbTable.punishmentPool, data);
  }

  Future<void> addToRewardPool(final Reward reward) async {
    final data = reward.toJsonMap();
    rewardPool.add(reward);
    await _db.insert(DbTable.rewardPool, data);
  }

  Future<void> addToWeeklyTaskPool(final Task task) async {
    final data = task.toJsonMap(excludeRows: ['isComplete']);
    weeklyTaskPool.add(task);
    await _db.insert(DbTable.weeklyTaskPool, data);
  }

  Future<void> addUniqueTasks(final TaskType taskType, final int amount) async {
    late final List<Task> tasks;
    late final List<Task> taskPool;
    late final DbTable table;
    int time = DateTime.now().millisecondsSinceEpoch;

    switch (taskType) {
      case TaskType.daily:
        // had to shuffle so that's why copy
        taskPool = dailyTaskPool.toList(growable: false)..shuffle();
        tasks = dailyTasks;
        table = DbTable.dailyTasks;
        time += dTaskTimeSpan;
        dailyTaskEndTime = time;
        break;
      case TaskType.weekly:
        // had to shuffle so that's why copy
        taskPool = weeklyTaskPool.toList(growable: false)..shuffle();
        tasks = weeklyTasks;
        table = DbTable.weeklyTasks;
        time += wTaskTimeSpan;
        weeklyTaskEndTime = time;
        break;
      default:
        throw UnimplementedError('${taskType.name} cannot be regenerated');
    }

    int count = 0;

    final extraTasks = taskPool.where((task) {
      // if the number of tasks needed has been reached, then skip over
      if (count >= amount) {
        return false;
      }

      // if tasks contains a task with same id, then return false
      final isPresent =
          tasks.indexWhere((e) => e.id == task.id) == -1 ? false : true;

      // if task was present, then we won't add it
      count += isPresent ? 0 : 1;

      // if task was not present, then you can add it
      return !isPresent;
    });

    tasks.addAll(extraTasks);

    for (final task in extraTasks) {
      final data = task.toJsonMap();
      await _db.insert(table, data);
    }
  }

  bool checkComplete(final TaskType taskType) {
    late final List<Task> tasks;

    switch (taskType) {
      case TaskType.daily:
        tasks = dailyTasks;
        break;
      case TaskType.weekly:
        tasks = weeklyTasks;
        break;
      default:
        throw UnimplementedError('${taskType.name} cannot be evaluated');
    }

    for (final task in tasks) {
      if (task.isComplete == false) {
        return false;
      }
    }

    return true;
  }

  Future<void> decreaseStat(final String stat, final int amount) async {
    // If this errors, then it is intentional
    stats[stat] = stats[stat]! - amount;

    // TODO: push to dbHandler
  }

  Future<void> deleteFromDailyTaskPool(final int id) async {
    await _db.remove(DbTable.dailyTaskPool, where: 'id = $id');
    dailyTaskPool.removeWhere((e) => e.id == id);
  }

  Future<void> deleteFromPunishmentPool(final int id) async {
    await _db.remove(DbTable.punishmentPool, where: 'id = $id');
    punishmentPool.removeWhere((e) => e.id == id);
  }

  Future<void> deleteFromRewardPool(final int id) async {
    await _db.remove(DbTable.rewardPool, where: 'id = $id');
    rewardPool.removeWhere((e) => e.id == id);
  }

  Future<void> deleteFromWeeklyTaskPool(final int id) async {
    await _db.remove(DbTable.weeklyTaskPool, where: 'id = $id');
    weeklyTaskPool.removeWhere((e) => e.id == id);
  }

  Future<void> evaluateTaskCompletion() async {
    final currentTimeEpoch = DateTime.now().millisecondsSinceEpoch;

    if (currentTimeEpoch > dailyTaskEndTime) {
      final dailyComplete = checkComplete(TaskType.daily);

      if (dailyComplete == false) {
        await addToPendingPunishment();
      }

      final oldTasks = dailyTasks.toList(growable: false);
      await addUniqueTasks(TaskType.daily, maxDTasks);

      for (final task in oldTasks) {
        await removePendingTask(TaskType.daily, task);
      }

      await _setTime(
        TaskType.daily,
        DateTime.now().millisecondsSinceEpoch + dTaskTimeSpan,
      );
    }

    if (currentTimeEpoch > weeklyTaskEndTime) {
      final weeklyComplete = checkComplete(TaskType.weekly);

      if (weeklyComplete == false) {
        await addToPendingPunishment();
      }

      final oldTasks = weeklyTasks.toList(growable: false);
      await addUniqueTasks(TaskType.weekly, maxWTasks);

      for (final task in oldTasks) {
        await removePendingTask(TaskType.weekly, task);
      }

      await _setTime(
        TaskType.weekly,
        DateTime.now().millisecondsSinceEpoch + wTaskTimeSpan,
      );
    }
  }

  Future<void> extendTime(final TaskType taskType, int milliseconds) async {
    switch (taskType) {
      case TaskType.daily:
        dailyTaskEndTime += milliseconds;
        await _db.empty(DbTable.dailyTaskEndTime);
        await _db.insert(
          DbTable.dailyTaskEndTime,
          {'time': dailyTaskEndTime},
        );
        break;
      case TaskType.weekly:
        weeklyTaskEndTime += milliseconds;
        await _db.empty(DbTable.weeklyTaskEndTime);
        await _db.insert(
          DbTable.weeklyTaskEndTime,
          {'time': weeklyTaskEndTime},
        );
        break;
      default:
        throw UnimplementedError('not implemented for $taskType');
    }
  }

  Future<void> increaseStat(final String stat, final int amount) async {
    // If this errors, then it is intentional
    stats[stat] = stats[stat]! + amount;

    // TODO: push to dbHandler
  }

  Future<void> markPunishmentComplete(final Punishment punishment) async {
    pendingPunishments.removeWhere((e) => e.id == punishment.id);
    await _db.remove(
      DbTable.pendingPunishments,
      where: 'id = ${punishment.id!}',
    );
  }

  Future<void> markTaskComplete(
    final TaskType taskType,
    final DbAble task,
  ) async {
    final id = task.id!; // if this fails, then it is intentional

    switch (taskType) {
      case TaskType.daily:
        final taskIdx = dailyTasks.indexWhere((t) => t.id == id);
        final task = dailyTasks[taskIdx].copyWith(isComplete: true);
        dailyTasks.removeAt(taskIdx);
        dailyTasks.insert(taskIdx, task);
        await _db.update(DbTable.dailyTasks, task);
        return;
      case TaskType.weekly:
        final taskIdx = weeklyTasks.indexWhere((t) => t.id == id);
        final task = weeklyTasks[taskIdx].copyWith(isComplete: true);
        weeklyTasks.removeAt(taskIdx);
        weeklyTasks.insert(taskIdx, task);
        await _db.update(DbTable.weeklyTasks, task);
        return;
      case TaskType.sideQuests:
        final taskIdx = sideQuests.indexWhere((t) => t.id == id);
        final task = sideQuests[taskIdx].copyWith(isComplete: true);
        sideQuests.removeAt(taskIdx);
        sideQuests.insert(taskIdx, task);
        await _db.update(DbTable.sideQuests, task);
        return;
    }
  }

  Future<void> removeFromCurrentReward(final Reward reward) async {
    currentRewards.removeWhere((e) => e.id == reward.id);
    await _db.remove(DbTable.currentRewards, where: 'id = ${reward.id!}');
  }

  Future<void> removePendingTask(
    final TaskType taskType,
    final DbAble task,
  ) async {
    switch (taskType) {
      case TaskType.daily:
        dailyTasks.remove(task);
        await _db.remove(DbTable.dailyTasks, where: 'id = ${task.id!}');
        break;
      case TaskType.weekly:
        weeklyTasks.remove(task);
        await _db.remove(DbTable.weeklyTasks, where: 'id = ${task.id!}');
      case TaskType.sideQuests:
        sideQuests.remove(task);
        await _db.remove(DbTable.sideQuests, where: 'id = ${task.id!}');
    }
  }

  Future<void> _setTime(final TaskType taskType, int milliseconds) async {
    switch (taskType) {
      case TaskType.daily:
        dailyTaskEndTime = milliseconds;
        await _db.empty(DbTable.dailyTaskEndTime);
        await _db.insert(
          DbTable.dailyTaskEndTime,
          {'time': dailyTaskEndTime},
        );
        break;
      case TaskType.weekly:
        weeklyTaskEndTime = milliseconds;
        await _db.empty(DbTable.weeklyTaskEndTime);
        await _db.insert(
          DbTable.weeklyTaskEndTime,
          {'time': weeklyTaskEndTime},
        );
        break;
      default:
        throw UnimplementedError('not implemented for $taskType');
    }
  }

  Future<void> updateDailyTaskPoolItem(final Task task) async {
    final index = dailyTaskPool.indexWhere((e) => e.id == task.id);
    dailyTaskPool.removeAt(index);
    dailyTaskPool.insert(index, task);
    await _db.update(DbTable.dailyTaskPool, task, exclude: ['isComplete']);
  }

  Future<void> updatePunishmentPoolItem(final Punishment pnishmnt) async {
    final index = punishmentPool.indexWhere((e) => e.id == pnishmnt.id);
    punishmentPool.removeAt(index);
    punishmentPool.insert(index, pnishmnt);
    await _db.update(DbTable.punishmentPool, pnishmnt, exclude: ['isComplete']);
  }

  Future<void> updateRewardPoolItem(final Reward reward) async {
    final index = rewardPool.indexWhere((e) => e.id == reward.id);
    rewardPool.removeAt(index);
    rewardPool.insert(index, reward);
    await _db.update(DbTable.rewardPool, reward);
  }

  Future<void> updateWeeklyTaskPoolItem(final Task task) async {
    final index = weeklyTaskPool.indexWhere((e) => e.id == task.id);
    weeklyTaskPool.removeAt(index);
    weeklyTaskPool.insert(index, task);
    await _db.update(DbTable.weeklyTaskPool, task, exclude: ['isComplete']);
  }
}
