const maxDTasks = 3;
const maxWTasks = 1;
const dTaskTimeSpanMilliseconds = 1000 * 60 * 60 * 24;
const wTaskTimeSpanMilliseconds = dTaskTimeSpanMilliseconds * 7;

enum PoolType {
  daily('Daily Task'),
  weekly('Weekly Task'),
  rewards('Reward'),
  punishments('Punishment');

  const PoolType(this.name);

  final String name;
}

enum TaskType { daily, weekly, sideQuests }

enum RewardType {
  // skip singly things
  skipDailyTask,
  skipWeeklyTask,
  skipPunishment,

  // skip all of a certain category
  skipEveryTask,
  skipAllPunishments,
  skipAllDailyTasks,
  skipAllWeeklyTasks,

  // rerolls
  rerollDailyTask,
  rerollWeeklyTask,

  // extend time
  extendDTaskTime,
  extendWTaskTime,

  // stat buffs
  increaseStat,

  // no side effect like "treat yourself with your tasty meal"
  noSideEffect,
}
