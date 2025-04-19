import 'dart:convert' show jsonDecode;

import '../internal_types.dart';

class Task implements DbAble {
  const Task({
    required this.id,
    required this.label,
    required this.stats,
    this.isComplete = false,
  });

  @override
  final int? id;
  @override
  final String label;

  final StatsMap stats;
  final bool isComplete;

  @override
  Task copyWith({
    final int? id,
    final String? label,
    final StatsMap? stats,
    final bool? isComplete,
  }) {
    return Task(
      id: id ?? this.id, // CAUTION: [id] may be null but [this.id] may not be
      label: label ?? this.label,
      stats: stats ?? this.stats,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  @override
  factory Task.fromJsonMap(final JsonMap jsonMap) {
    final id = jsonMap['id'] as int?;
    final label = jsonMap['label'] as String;

    final statsAsStr = jsonMap['statChanges'] as String? ?? "";
    late final StatsMap stats;

    if (statsAsStr == "") {
      stats = {};
    } else {
      stats = (jsonDecode(statsAsStr) as Map).cast<String, int>();
    }

    final int? isCompleteAsInt = jsonMap['isComplete'] as int?;
    late final bool isComplete;

    // If task was fetched from Task Pool where isComplete does not exist.
    if (isCompleteAsInt == null) {
      isComplete = false;
    } else {
      isComplete = isCompleteAsInt == 1 ? true : false;
    }

    return Task(id: id, label: label, stats: stats, isComplete: isComplete);
  }

  @override
  JsonMap toJsonMap({List<String>? excludeRows}) {
    String statsAsStr = "{";

    for (final MapEntry<String, int> entry in stats.entries) {
      statsAsStr += '''"${entry.key}": ${entry.value},''';
    }

    statsAsStr = statsAsStr.substring(0, statsAsStr.length - 1);
    statsAsStr += "}";

    final JsonMap jsonMap = {
      'label': label,
      'statChanges': statsAsStr,
      'isComplete': isComplete ? 1 : 0,
    };

    if (id != null) {
      jsonMap['id'] = id;
    }

    excludeRows?.forEach((key) => jsonMap.remove(key));
    return jsonMap;
  }
}
