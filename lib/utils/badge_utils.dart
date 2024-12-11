import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import 'badge_configuration.dart';

/// Adds a badge to the user if it doesn't already exist.
void addBadge(String badgeName, Box<User> userBox) {
  final user = userBox.getAt(0);
  if (user != null) {
    // Avoid duplicate badges
    if (!user.badges.any((badge) => badge['name'] == badgeName)) {
      user.badges.add({
        'name': badgeName,
        'icon': badgeIcons[badgeName]?.codePoint.toString() ?? '',
      });
      userBox.putAt(0, user);
    }
  }
}

/// Increments tanks or tasks created and checks for badge eligibility.
void incrementActivityCount({
  required String activityType,
  required Box<User> userBox,
}) {
  final user = userBox.getAt(0);
  if (user != null) {
    if (activityType == 'tank') {
      user.tanksCreated++;
      if (user.tanksCreated == 1) {
        addBadge('First Tank Created', userBox);
      } else if (user.tanksCreated == 3) {
        addBadge('Three Tanks Milestone', userBox);
      }
    } else if (activityType == 'task') {
      user.tasksCreated++;
      if (user.tasksCreated == 1) {
        addBadge('First Task Created', userBox);
      }
    }
    userBox.putAt(0, user);
  }
}
