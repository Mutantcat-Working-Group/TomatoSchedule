import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/calendar_screen.dart';
import 'services/mcp_server.dart';
import 'services/database_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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

// Global MCP server instance
McpServer? _mcpServer;

Future<void> startMcpServer() async {
  if (_mcpServer != null) return;
  final db = DatabaseService();
  _mcpServer = McpServer(db);
  await _mcpServer!.start(port: 8080);
}

Future<void> stopMcpServer() async {
  await _mcpServer?.stop();
  _mcpServer = null;
}
