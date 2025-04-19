import '../internal_types.dart';

final class Punishment implements DbAble {
  const Punishment({
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
  Punishment copyWith({
    final int? id,
    final String? label,
    final bool? isComplete,
  }) {
    return Punishment(
      id: id ?? this.id,
      label: label ?? this.label,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  @override
  factory Punishment.fromJsonMap(final JsonMap jsonMap) {
    final int? isCompleteAsInt = jsonMap['isComplete'] as int?;
    late final bool isComplete;

    if (isCompleteAsInt == null) {
      isComplete = false;
    } else {
      isComplete = isCompleteAsInt == 1 ? true : false;
    }

    return Punishment(
      id: jsonMap['id'] as int?,
      label: jsonMap['label'] as String,
      isComplete: isComplete,
    );
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
