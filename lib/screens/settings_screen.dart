import 'package:flutter/material.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20.0),
          ),
          Divider(),
          SafeArea(
            child: Container(
                child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.share,
                      size: 25.0,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    _SettingButton('Share App', () {}),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.notifications,
                      size: 25.0,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    _SettingButton('Notification', () {}),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 25.0,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    _SettingButton('Change Profile', () {}),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.bug_report,
                      size: 25.0,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    _SettingButton('Report Bug', () {}),
                  ],
                ),
              ],
            )),
          ),
        ],
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
    // TODO: Change text color to black in ThemeData (Anuj)
    return TextButton(onPressed: onPressed, child: Text(label));
  }
}
