import 'package:flutter/material.dart';

import '../core/profile.dart';

abstract class Screen extends StatefulWidget {
  const Screen(
    this.profile, {
    required this.title,
    super.key,
  });

  final Profile profile;
  final String title;
}
