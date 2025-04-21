import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';

class XpBar extends StatelessWidget {
  const XpBar({
    super.key,
    required this.percentage,
    this.width,
    required this.level,
  });

  final double percentage;
  final double? width;
  final int level;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: LinearPercentIndicator(
            percent: percentage,
            width: width,
            animation: true,
            barRadius: Radius.circular(500),
            leading: Text(
              'Lvl $level',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              'Lvl ${level + 1}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            linearGradient: LinearGradient(colors: [
              Color(0xff2bff00),
              Color(0xff1a9900),
            ]),
          ),
        ),
        Text(
          '${100 - (percentage * 100).toInt()} XP TO LEVEL ${level + 1}',
          style: GoogleFonts.robotoFlex(
            fontWeight: FontWeight.w200,
            fontSize: 13.0,
          ),
        )
      ],
    );
  }
}
