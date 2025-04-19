import '../internal_types.dart';

final class SideQuest implements DbAble {
  const SideQuest({
    required this.id,
    required this.label,
    this.isComplete = false,
  });

  @override
  final int? id;
  @override
  final String label;
  final bool isComplete;

  @override
  SideQuest copyWith({
    final int? id,
    final String? label,
    final bool? isComplete,
  }) {
    return SideQuest(
      id: id ?? this.id,
      label: label ?? this.label,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  @override
  factory SideQuest.fromJsonMap(final JsonMap jsonMap) {
    final id = jsonMap['id'] as int?;
    final label = jsonMap['label'] as String;

    final int? isCompleteAsInt = jsonMap['isComplete'] as int?;
    late final bool isComplete;

    if (isCompleteAsInt == null) {
      isComplete = false;
    } else {
      isComplete = isCompleteAsInt == 1 ? true : false;
    }

    return SideQuest(id: id, label: label, isComplete: isComplete);
  }

  @override
  JsonMap toJsonMap({List<String>? excludeRows}) {
    final JsonMap jsonMap = {
      'label': label,
      'isComplete': isComplete ? 1 : 0,
    };

    if (id != null) {
      jsonMap['id'] = id;
    }

    excludeRows?.forEach((key) => jsonMap.remove(key));
    return jsonMap;
  }
}
