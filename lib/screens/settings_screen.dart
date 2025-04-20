import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/profile.dart';
import 'screen.dart';

final class SettingsScreen extends Screen {
  const SettingsScreen(super.profile, {super.key}) : super(title: 'Settings');

  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

final class _SettingsScreenState extends State<SettingsScreen> {
  late final Profile profile;

  @override
  void initState() {
    profile = widget.profile;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Utilities',
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20.0),
            ),
            Divider(),
            Expanded(
              child: ListView(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.share,
                        size: 25.0,
                        color: Colors.black,
                      ),
                      _SettingButton('Share App', () {
                        Share.share(
                          "Do you wanna level up your life? "
                          "Then try out Lvl Up: "
                          "https://github.com/shubhamvg/Lvl_UP",
                        );
                      }),
                    ],
                  ),
                  // Row(
                  //   children: [
                  //     Icon(
                  //       Icons.notifications,
                  //       size: 25.0,
                  //       color: Colors.black,
                  //     ),
                  //     _SettingButton('Notification', () {}),
                  //   ],
                  // ),
                  // Row(
                  //   children: [
                  //     Icon(
                  //       Icons.person,
                  //       size: 25.0,
                  //       color: Colors.black,
                  //     ),
                  //     _SettingButton('Change Profile', () {}),
                  //   ],
                  // ),
                  Row(
                    children: [
                      Icon(
                        Icons.bug_report,
                        size: 25.0,
                        color: Colors.black,
                      ),
                      _SettingButton('Report Bug', () {
                        final uri = Uri.parse(
                          'https://github.com/ShubhamVG/Lvl_Up/issues',
                        );
                        supportsLaunchMode(LaunchMode.externalApplication)
                            .then(print);
                        launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingButton extends StatelessWidget {
  const _SettingButton(this.label, this.onPressed);

  final String label;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}
