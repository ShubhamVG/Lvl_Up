import 'package:flutter/material.dart';

import '../core/internal_types.dart';
import 'task_container.dart';

/// This widget's [name] is basically the title to be displayed on top of the
/// container group thing.
class TaskGroup extends StatelessWidget {
  const TaskGroup(
    this.name, {
    super.key,
    this.subtitle,
    this.subtitleColor,
    required this.tasks,
    required this.onDone,
  });

  final String name;
  final String? subtitle;
  final Color? subtitleColor;
  final List<DbAble> tasks;
  final void Function(DbAble) onDone;

  @override
  Widget build(BuildContext context) {
    late final Widget titleWidget;

    // If no subtitle, then only show the title/name otherwise show both in a
    // row
    if (subtitle == null) {
      titleWidget = Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
      );
    } else {
      titleWidget = Row(
        children: [
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
          ),
          const SizedBox(width: 10.0),
          Text(
            subtitle!,
            style: TextStyle(
              color: subtitleColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title thing on top of the tasks container
        titleWidget,
        const SizedBox(height: 2.0),
        for (final task in tasks)
          TaskContainer(
            task,
            onDone: () => onDone(task),
          )
      ],
    );
  }
}
