import '../constants.dart';
import '../internal_types.dart';

final class Reward implements DbAble {
  const Reward({
    required this.id,
    required this.label,
    required this.rewardType,
  });

  @override
  final int? id;
  @override
  final String label;
  final RewardType rewardType;

  @override
  Reward copyWith({
    final int? id,
    final String? label,
    final RewardType? rewardType,
  }) {
    return Reward(
      id: id ?? this.id,
      label: label ?? this.label,
      rewardType: rewardType ?? this.rewardType,
    );
  }

  @override
  factory Reward.fromJsonMap(JsonMap jsonMap) {
    final id = jsonMap['id'] as int?;
    final label = jsonMap['label'] as String;
    final rewardType = RewardType.values[jsonMap['rewardEnumIdx'] as int];

    return Reward(id: id, label: label, rewardType: rewardType);
  }

  @override
  JsonMap toJsonMap({List<String>? excludeRows}) {
    final JsonMap jsonMap = {
      'label': label,
      'rewardEnumIdx': rewardType.index,
    };

    if (id != null) {
      jsonMap['id'] = id;
    }

    excludeRows?.forEach((key) => jsonMap.remove(key));
    return jsonMap;
  }
}
