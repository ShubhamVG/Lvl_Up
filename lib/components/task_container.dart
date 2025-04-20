import 'package:flutter/material.dart';

import '../core/internal_types.dart';
import '../core/modals.dart';
import 'stat_count.dart';

final class TaskContainer extends StatelessWidget {
  const TaskContainer(this.task, {super.key, required this.onDone});

  final DbAble task;
  final void Function() onDone;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      color: Colors.white, // TODO
      margin: EdgeInsets.all(3.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // dot
            const Text('• '),
            // task label & stat
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.label),
                  if (task is Task && (task as Task).stats.isNotEmpty)
                    StatCount(
                      statMap: (task as Task).stats,
                      color: Colors.green.shade100,
                    ),
                ],
              ),
            ),
            Checkbox.adaptive(
              side: BorderSide.none,
              fillColor: WidgetStateProperty.resolveWith<Color>(
                (_) => Colors.green.shade300,
              ),
              value: (task as dynamic).isComplete,
              onChanged: (_) => onDone(),
            ),
          ],
        ),
      ),
    );
  }
}
