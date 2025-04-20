import 'package:flutter/material.dart';

import '../core/internal_types.dart';

class StatCount extends StatelessWidget {
  const StatCount({super.key, required this.statMap, this.color});

  final StatsMap statMap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        for (final entry in statMap.entries)
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Container(
              decoration: BoxDecoration(
                color: color ?? Colors.orange.shade200,
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 2.0,
                  horizontal: 8.0,
                ),
                child: Text(
                  '${entry.key}:${entry.value}',
                  style: TextStyle(fontSize: 10.0),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
