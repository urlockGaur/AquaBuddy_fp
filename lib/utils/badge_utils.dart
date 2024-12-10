import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import 'badge_configuration.dart';

addBadge(String badgeName, Box<User> userBox) {
  final user = userBox.getAt(0);
  if (user != null) {
    if (!user.badges.any((badge) => badge['name'] == badgeName)) {
      user.badges.add({
        'name': badgeName,
        'icon': badgeName, // Store the badgeName instead of the icon code
      });
      userBox.putAt(0, user);
    }
  }
}

