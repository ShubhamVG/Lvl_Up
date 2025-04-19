typedef JsonMap = Map<String, Object?>;

/// [StatsMap] is a [Map<String, int>] but with only the possible stats inside
/// it. i.e.,
/// - Intelligence
/// - Health
/// - Charisma
/// - Social
/// - Others := Kindness, ...(TBD)
///
/// Also, the same stats with the prefix [prevWeek] to denote the value of the
/// same stat last week. Helpful to calculate progress.
///
/// There can be less keys inside a [StatsMap] but more is ILLEGAL and SHOULD
/// BE IGNORED if anyhow added.
///
/// Example:
/// ```dart
/// const StatsMap stats = {
///   'intelligence': 31,
///   'social': 22,
///   'health': 26,
///   'charisma': 20,
///   'others': 50,
///   'prevWeekIntelligence': 21,
///   'prevWeekSocial': 22,
///   'prevWeekHealth': 23,
///   'prevWeekCharisma': 24,
///   'prevWeekOthers': 25,
/// };
/// ```
typedef StatsMap = Map<String, int>;

/// Class that must have methods like [.fromJson] and [.toJsonMap] which helps
/// with converting the class into db friendly forms.
abstract interface class DbAble {
  const DbAble({required this.id, required this.label});

  final int? id;
  final String label;

  DbAble copyWith();

  factory DbAble.fromJsonMap(JsonMap json) {
    throw UnimplementedError();
  }

  JsonMap toJsonMap({List<String>? excludeRows});
}
