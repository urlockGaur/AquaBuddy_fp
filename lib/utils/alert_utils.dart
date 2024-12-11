import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

void showCustomFlushbar(
    BuildContext context,
    String message, {
      Duration duration = const Duration(seconds: 2),
      FlushbarPosition position = FlushbarPosition.TOP,
      IconData? icon,
    }) {
  final theme = Theme.of(context);
  Flushbar(
    message: message,
    duration: duration,
    flushbarPosition: position,
    backgroundColor: theme.primaryColor.withOpacity(0.9),
    margin: const EdgeInsets.all(16.0),
    borderRadius: BorderRadius.circular(12.0),
    animationDuration: const Duration(milliseconds: 300),
    icon: icon != null
        ? Icon(
      icon,
      color: theme.floatingActionButtonTheme.foregroundColor,
    )
        : null,
    messageText: Text(
      message,
      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
    ),
  ).show(context);
}
