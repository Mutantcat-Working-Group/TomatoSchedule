import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/calendar_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: TomatoScheduleApp(),
    ),
  );
}

class TomatoScheduleApp extends StatelessWidget {
  const TomatoScheduleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TomatoSchedule',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE74C3C),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE74C3C),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const CalendarScreen(),
    );
  }
}
