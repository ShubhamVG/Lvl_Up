import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../components/xp_bar.dart';
import '../core/internal_types.dart';
import '../core/profile.dart';

final class ProfileScreen extends StatelessWidget {
  const ProfileScreen(this.profile, {super.key});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.monda(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: _Profile(level: profile.currentLevel)),
              const SizedBox(height: 20.0),
              Text(
                'LEVEL ${profile.currentLevel}',
                style: GoogleFonts.monda(
                  fontWeight: FontWeight.bold,
                ),
              ),
              _Stats(profile.stats),
              Text(
                'PROGRESS',
                style: GoogleFonts.monda(
                  fontWeight: FontWeight.bold,
                ),
              ),
              _Progress(profile.stats),
            ],
          ),
        ),
      ),
    );
  }
}

class _Profile extends StatelessWidget {
  const _Profile({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 40.0,
          child: ClipOval(child: Image.asset('assets/face.jpg')),
        ),
        SizedBox(height: 10.0),
        const Text(
          'Insert Name Here', // TODO
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        SizedBox(height: 10.0),
        XpBar(percentage: 0.7, level: level),
      ],
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress(this.stats);

  final StatsMap stats;

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: const CategoryAxis(),
      series: [
        StackedColumnSeries(
          animationDuration: 700,
          dataSource: stats.entries
              .where((e) => e.key.startsWith('prev') == false)
              .toList(growable: false),
          xValueMapper: (x, _) => x.key,
          yValueMapper: (x, _) => x.value,
          legendItemText: 'Last Week',
        ),
        StackedColumnSeries(
          animationDuration: 700,
          dataSource: stats.entries
              .where((e) => e.key.startsWith('prev'))
              .toList(growable: false),
          xValueMapper: (x, _) => (x.key as String).substring(8).toLowerCase(),
          yValueMapper: (x, _) {
            // TODO: refactor
            final key = (x.key as String).substring(8).toLowerCase();
            final diff = (stats[key] as int) - (stats[x.key] as int) + 5;

            return diff > 0 ? diff : 0;
          },
          legendItemText: 'Progress',
        )
      ],
      legend: const Legend(isVisible: true, position: LegendPosition.bottom),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats(this.stats);

  final StatsMap stats;

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      legend: const Legend(isVisible: true),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CircularSeries>[
        RadialBarSeries<MapEntry<String, int>, String>(
          animationDuration: 700,
          radius: '90%',
          gap: '4%',
          cornerStyle: CornerStyle.bothCurve,
          enableTooltip: true,
          dataSource: stats.entries
              .where((e) => e.key.startsWith('prev') == false)
              .toList(growable: false),
          xValueMapper: (x, _) => x.key,
          yValueMapper: (y, _) => y.value,
          legendIconType: LegendIconType.diamond,
        )
      ],
    );
  }
}
