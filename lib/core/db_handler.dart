import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'constants.dart';
import 'internal_types.dart';
import 'modals.dart';

const dbVersion = 1;

final class DbHandler {
  const DbHandler(this._db);

  final Database _db;

  static Future<void> _createDbTables(Database db, int version) async {
    for (final table in DbTable.values) {
      await db.execute(table.schema);
    }
  }

  static Future<DbHandler> getInstance() async {
    const dbName = 'database.db';
    late final Database db;

    // sqflite supported platforms
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      final dbPath = path.join(await getDatabasesPath(), dbName);
      db = await openDatabase(dbPath);
    } else {
      // platforms that do not support sqflite need sqflite_common_ffi
      sqfliteFfiInit();
      final appDir = await getApplicationDocumentsDirectory();
      final dbPath = path.join(appDir.path, dbName);

      db = await databaseFactoryFfi.openDatabase(dbPath);
    }

    return DbHandler(db);
  }

  Future<void> execute(final String sql) async {
    await _db.execute(sql);
  }

  Future<void> empty(final DbTable table) async {
    await _db.delete(table.name);
  }

  Future<List<JsonMap>> fetch(
    final DbTable table, [
    bool toCopy = false,
  ]) async {
    List<JsonMap> results = await _db.query(table.name);

    if (toCopy) {
      results = results.map((e) => JsonMap.of(e)).toList();
    }

    return results;
  }

  /// Casts the fetched [JsonMap] to [T] using [tFromJson] and then returns it.
  Future<List<T>> fetchAs<T extends DbAble>(
    final DbTable table,
    final T Function(JsonMap) tFromJson,
  ) async {
    final List<JsonMap> rawItems = await fetch(table);
    final List<T> items = rawItems.map((e) => tFromJson(e)).toList();

    return items;
  }

  Future<JsonMap> fetchFirst(
    final DbTable table, [
    bool toCopy = false,
  ]) async {
    final List<JsonMap> results = await _db.query(table.name);

    return toCopy ? JsonMap.of(results.first) : results.first;
  }

  Future<void> insert(
    final DbTable table,
    JsonMap data, {
    List<String> ignoreRows = const <String>[],
  }) async {
    for (final String row in ignoreRows) {
      data.remove(row);
    }

    await _db.insert(table.name, data);
  }

  Future<void> remove(
    final DbTable table, {
    required String where,
  }) async {
    await _db.delete(table.name, where: where);
  }

  Future<void> update(
    final DbTable table,
    DbAble newItemWithSameID, {
    List<String>? exclude,
  }) async {
    if (newItemWithSameID.id == null) {
      throw Exception('No id bozo');
    }

    // TODO: add conflict handler or resolver or something
    await _db.update(
      table.name,
      newItemWithSameID.toJsonMap(excludeRows: exclude),
      where: 'id = ?',
      whereArgs: <int>[newItemWithSameID.id!],
    );
  }

  /// Takes randomly shuffled stuffs from the pools set by [setToDefault] and
  /// uses that to fill in the optional tables like [pendingPunishments] and
  /// [currentRewards]
  Future<void> setToDebugMode() async {
    await setToDefault();

    // scopes in rest of the function to avoid too many variables pollution
    {
      final pendingPunishments = await fetchAs<Punishment>(
        DbTable.punishmentPool,
        Punishment.fromJsonMap,
      );

      pendingPunishments.shuffle();

      for (final punishment in pendingPunishments.sublist(0, 3)) {
        final data = punishment.toJsonMap();
        await insert(DbTable.pendingPunishments, data);
      }
    }

    {
      final currentRewards = await fetchAs<Reward>(
        DbTable.rewardPool,
        Reward.fromJsonMap,
      );

      currentRewards.shuffle();

      for (final reward in currentRewards.sublist(0, 10)) {
        final data = reward.toJsonMap();
        await insert(DbTable.currentRewards, data);
      }
    }

    // add side quests
    const sideQuests = <SideQuest>[
      SideQuest(id: 0, label: 'Random task 1 innit'),
      SideQuest(id: 1, label: 'Random task 2 innit'),
      SideQuest(id: 2, label: 'Random task 3 innit'),
    ];

    for (final quest in sideQuests) {
      final data = quest.toJsonMap();
      await insert(DbTable.sideQuests, data);
    }
  }

  Future<void> setToDefault() async {
    // Get rid of all the pre-made tables
    for (final table in DbTable.values) {
      try {
        await execute('DROP TABLE ${table.name}');
      } on DatabaseException {
        if (kDebugMode) {
          debugPrint('Exception on ${table.name}. Skipping over.');
        }
      }
    }

    await _createDbTables(_db, dbVersion);

    final int millisecondsEpoch = DateTime.now().millisecondsSinceEpoch;
    const secondsInADay = dTaskTimeSpan;
    const secondsInAWeek = wTaskTimeSpan;

    await insert(
      DbTable.dailyTaskEndTime,
      {'time': millisecondsEpoch + secondsInADay},
    );
    await insert(
      DbTable.weeklyTaskEndTime,
      {'time': millisecondsEpoch + secondsInAWeek},
    );

    const levels = <String, int>{
      'current': 1,
      'prev': 1,
    };

    for (final level in levels.entries) {
      final data = {'name': level.key, 'value': level.value};
      await insert(DbTable.level, data);
    }

    const StatsMap stats = {
      'intelligence': 30,
      'social': 30,
      'health': 30,
      'charisma': 30,
      'others': 30,
      'prevWeekIntelligence': 30,
      'prevWeekSocial': 30,
      'prevWeekHealth': 30,
      'prevWeekCharisma': 30,
      'prevWeekOthers': 30,
    };

    for (final statEntry in stats.entries) {
      final data = {'name': statEntry.key, 'value': statEntry.value};
      await insert(DbTable.stats, data);
    }

    // TODO: add meaningful tasks
    const dailyTaskPool = <Task>[
      Task(id: 0, label: 'abc', stats: {'intelligence': 5}),
      Task(id: 1, label: 'def', stats: {'social': 2}),
      Task(id: 2, label: 'ghi', stats: {'others': 1}),
      Task(id: 3, label: 'jkl', stats: {'health': 3}),
      Task(id: 4, label: 'mno', stats: {'charisma': 2}),
      Task(id: 5, label: 'pqr', stats: {'charisma': 1}),
      Task(id: 6, label: 'stu', stats: {'health': 4}),
      Task(id: 7, label: 'vwx', stats: {'others': 4}),
      Task(id: 8, label: 'yz1', stats: {'social': 5}),
      Task(id: 9, label: '234', stats: {'intelligence': 2}),
      Task(id: 10, label: '567', stats: {'social': 1}),
      Task(id: 11, label: '890', stats: {'health': 2}),
    ];

    for (final task in dailyTaskPool) {
      final data = task.toJsonMap(excludeRows: ['isComplete']);
      await insert(DbTable.dailyTaskPool, data);
    }

    final dailyTasks =
        (await fetchAs<Task>(DbTable.dailyTaskPool, Task.fromJsonMap)
              ..shuffle())
            .sublist(0, maxDTasks);

    for (final task in dailyTasks) {
      await insert(
        DbTable.dailyTasks,
        task.toJsonMap(),
      );
    }

    // TODO: add meaningful tasks
    const weeklyTaskPool = <Task>[
      Task(id: 0, label: 'abcd', stats: {'intelligence': 15}),
      Task(id: 1, label: 'defg', stats: {'social': 12, 'charisma': 5}),
      Task(id: 2, label: 'ghij', stats: {'others': 11, 'intelligence': 10}),
      Task(id: 3, label: 'jklm', stats: {'health': 13}),
      Task(id: 4, label: 'mnop', stats: {'charisma': 12}),
      Task(id: 5, label: 'pqrs', stats: {'charisma': 11}),
      Task(id: 6, label: 'stuv', stats: {'health': 14, 'others': 10}),
      Task(id: 7, label: 'vwxy', stats: {'others': 14}),
      Task(id: 8, label: 'yz12', stats: {'social': 15}),
      Task(id: 9, label: '2345', stats: {'intelligence': 12}),
      Task(id: 10, label: '5678', stats: {'social': 11}),
      Task(id: 11, label: '890.', stats: {'health': 12, 'social': 5}),
    ];

    for (final task in weeklyTaskPool) {
      final data = task.toJsonMap(excludeRows: ['isComplete']);
      await insert(DbTable.weeklyTaskPool, data);
    }

    final weeklyTasks =
        (await fetchAs<Task>(DbTable.weeklyTaskPool, Task.fromJsonMap)
              ..shuffle())
            .sublist(0, maxWTasks);

    for (final task in weeklyTasks) {
      await insert(
        DbTable.weeklyTasks,
        task.toJsonMap(),
      );
    }

    const rewardPool = <Reward>[
      Reward(
        id: 0,
        label: 'reward1',
        rewardType: RewardType.noSideEffect,
      ),
      Reward(
        id: 1,
        label: 'reward2',
        rewardType: RewardType.increaseStat,
      ),
      Reward(
        id: 2,
        label: 'reward3',
        rewardType: RewardType.skipDailyTask,
      ),
      Reward(
        id: 3,
        label: 'reward4',
        rewardType: RewardType.noSideEffect,
      ),
      Reward(
        id: 4,
        label: 'reward5',
        rewardType: RewardType.skipDailyTask,
      ),
      Reward(
        id: 5,
        label: 'reward6',
        rewardType: RewardType.skipDailyTask,
      ),
      Reward(
        id: 6,
        label: 'reward7',
        rewardType: RewardType.increaseStat,
      ),
      Reward(
        id: 7,
        label: 'reward8',
        rewardType: RewardType.increaseStat,
      ),
      Reward(
        id: 8,
        label: 'reward9',
        rewardType: RewardType.skipDailyTask,
      ),
      Reward(
        id: 9,
        label: 'reward10',
        rewardType: RewardType.noSideEffect,
      ),
      Reward(
        id: 10,
        label: 'reward11',
        rewardType: RewardType.noSideEffect,
      ),
      Reward(
        id: 11,
        label: 'reward12',
        rewardType: RewardType.rerollDailyTask,
      ),
      Reward(
        id: 12,
        label: 'reward13',
        rewardType: RewardType.rerollDailyTask,
      ),
      Reward(
        id: 13,
        label: 'reward14',
        rewardType: RewardType.rerollWeeklyTask,
      ),
      Reward(
        id: 14,
        label: 'reward15',
        rewardType: RewardType.noSideEffect,
      ),
    ];

    for (final reward in rewardPool) {
      final data = reward.toJsonMap();
      await insert(DbTable.rewardPool, data);
    }

    const punishmentPool = <Punishment>[
      Punishment(id: 0, label: 'jump out of the window'),
      Punishment(id: 1, label: 'jump out of the window again'),
      Punishment(id: 2, label: 'jump out of the window 3x'),
      Punishment(id: 3, label: 'jump out of the window 4x'),
      Punishment(id: 4, label: 'jump out of the window 5x'),
      Punishment(id: 5, label: 'jump out of the window 6x'),
      Punishment(id: 6, label: 'jump out of the window 7x'),
      Punishment(id: 7, label: 'jump out of the window 8x'),
      Punishment(id: 8, label: 'jump out of the window 9x'),
      Punishment(id: 9, label: 'jump out of the window 10x'),
      Punishment(id: 10, label: 'jump out of the window 11x'),
      Punishment(id: 11, label: 'jump out of the window 12x'),
    ];

    for (final punishment in punishmentPool) {
      final data = punishment.toJsonMap(excludeRows: ['isComplete']);
      await insert(DbTable.punishmentPool, data);
    }
  }
}

// TODO: change statChanges from being text to bit mapped numbers
enum DbTable {
  dailyTasks(
    name: 'dailyTasks',
    schema: "CREATE TABLE dailyTasks ("
        "id INTEGER PRIMARY KEY,"
        "label TEXT,"
        "isComplete INTEGER,"
        "statChanges TEXT)",
  ),
  dailyTaskEndTime(
    name: 'dailyTaskEndTime',
    schema: "CREATE TABLE dailyTaskEndTime (time INTEGER)",
  ),
  weeklyTasks(
    name: 'weeklyTasks',
    schema: "CREATE TABLE weeklyTasks ("
        "id INTEGER PRIMARY KEY,"
        "label TEXT,"
        "isComplete INTEGER,"
        "statChanges TEXT)",
  ),
  weeklyTaskEndTime(
    name: 'weeklyTaskEndTime',
    schema: "CREATE TABLE weeklyTaskEndTime (time INTEGER)",
  ),
  sideQuests(
    name: 'sideQuests',
    schema: "CREATE TABLE sideQuests ("
        "id INTEGER PRIMARY KEY,"
        "label TEXT,"
        "isComplete INTEGER)",
  ),
  currentRewards(
    name: 'currentRewards',
    schema: "CREATE TABLE currentRewards ("
        "id INTEGER PRIMARY KEY,"
        "label TEXT,"
        "rewardEnumIdx INTEGER)",
  ),
  pendingPunishments(
    name: 'pendingPunishments',
    schema: "CREATE TABLE pendingPunishments ("
        "id INTEGER PRIMARY KEY,"
        "label TEXT,"
        "isComplete INTEGER)",
  ),
  dailyTaskPool(
    name: 'dailyTaskPool',
    schema: "CREATE TABLE dailyTaskPool ("
        "id INTEGER PRIMART KEY,"
        "label TEXT,"
        "statChanges TEXT)",
  ),
  weeklyTaskPool(
    name: 'weeklyTaskPool',
    schema: "CREATE TABLE weeklyTaskPool ("
        "id INTEGER PRIMART KEY,"
        "label TEXT,"
        "statChanges TEXT)",
  ),
  rewardPool(
    name: 'rewardPool',
    schema: "CREATE TABLE rewardPool ("
        "id INTEGER PRIMARY KEY,"
        "label TEXT,"
        "rewardEnumIdx INTEGER)",
  ),
  punishmentPool(
    name: 'punishmentPool',
    schema: "CREATE TABLE punishmentPool ("
        "id INTEGER PRIMARY KEY,"
        "label TEXT)",
  ),
  stats(
    name: 'stats',
    schema: "CREATE TABLE stats ("
        "name TEXT,"
        "value INTEGER)",
  ),
  level(
    name: 'level',
    schema: "CREATE TABLE level ("
        "name TEXT," // i.e., current and prev
        "value INTEGER)",
  );

  const DbTable({required this.name, required this.schema});

  final String name;
  final String schema;
}
