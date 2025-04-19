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
            'Utitilies',
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12.0),
          ),
          Divider(),
          _SettingButton('Share App', () {}),
          _SettingButton('About Us & Mission', () {}),
          _SettingButton('Terms of Service', () {}),
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
