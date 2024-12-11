import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

/// Centralized badge configuration
final Map<String, IconData> badgeIcons = {
  'Account Created': FontAwesomeIcons.user,
  'First Tank Created': FontAwesomeIcons.water,
  'Three Tanks Milestone': FontAwesomeIcons.crown,
  'First Task Created': FontAwesomeIcons.clipboard,
};

final Map<String, Color> badgeColors = {
  'Account Created': Colors.blueAccent,
  'First Tank Created': Colors.greenAccent,
  'Three Tanks Milestone': Colors.amber,
  'First Task Created': Colors.deepOrangeAccent,
};
