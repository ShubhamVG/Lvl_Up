import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

final class BotmNavBar extends StatefulWidget {
  const BotmNavBar({
    super.key,
    required this.selectedIdx,
    required this.onIdxChange,
  });

  final int selectedIdx;
  final void Function(int) onIdxChange;

  @override
  State<BotmNavBar> createState() => _BotmNavBarState();
}

class _BotmNavBarState extends State<BotmNavBar> {
  static const homeIcon = Icons.home_rounded;
  static const inventoryIcon = Icons.receipt; // TODO: change
  static const poolIcon = Icons.menu_rounded;
  static const settingsIcon = Icons.settings;

  static const iconDatas = <IconData>[
    homeIcon,
    inventoryIcon,
    poolIcon,
    settingsIcon,
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIdx = widget.selectedIdx;

    const vertShift = -20.0;
    final scrnWidth = MediaQuery.of(context).size.width;
    final iconSize = IconTheme.of(context).size ?? 24.0; // 24.0 is default
    const circleRadius = 20.0; // default is 20.0

    // I did the maths
    final space = circleRadius - iconSize / 2;
    final circCoef =
        (scrnWidth - iconDatas.length * iconSize) / (iconDatas.length + 1);

    // circPos = (k+1) * circCoef + k * iconWidth - space
    final circPos =
        (selectedIdx + 1) * circCoef + selectedIdx * iconSize - space;

    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          transform: Matrix4.translation(Vector3(circPos, vertShift, 0)),
          child: CircleAvatar(
            backgroundColor: Colors.black54,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (int i = 0; i < iconDatas.length; i++)
              if (i == selectedIdx)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 320),
                  transform: Matrix4.translation(Vector3(0.0, vertShift, 0.0)),
                  child: Icon(iconDatas[i]),
                )
              else
                AnimatedContainer(
                  duration: const Duration(milliseconds: 320),
                  transform: Matrix4.translation(Vector3(0.0, 0.0, 0.0)),
                  child: InkWell(
                    onTap: () {
                      widget.onIdxChange(i);
                    },
                    child: Icon(iconDatas[i]),
                  ),
                ),
          ],
        ),
      ],
    );
  }
}
