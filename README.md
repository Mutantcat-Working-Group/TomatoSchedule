# TomatoSchedule

AI-powered cross-platform schedule planner built with Flutter.

## Features

- Calendar view (month/week/day)
- Natural language event creation
- AI-powered schedule generation
- MCP (Model Context Protocol) server for direct AI integration
- Local SQLite storage
- Cross-platform: Android, iOS, Windows, macOS, Linux

## MCP Server

TomatoSchedule includes a built-in MCP server that allows AI assistants to directly manage your calendar.

### Quick Start

1. Open the app and go to Settings (gear icon)
2. Start the MCP Server
3. Configure your AI assistant to connect to `http://<device-ip>:8080/mcp`

### Available Tools

| Tool | Description |
|------|-------------|
| `create_event` | Create a new calendar event |
| `update_event` | Update an existing event |
| `delete_event` | Delete an event |
| `query_events` | Query events in a date range |
| `get_event` | Get a single event by ID |

### Example: Claude Desktop Configuration

Add to your Claude Desktop config:

```json
{
  "mcpServers": {
    "tomato-schedule": {
      "url": "http://localhost:8080/mcp"
    }
  }
}
```

### Tool Parameters

#### create_event
```json
{
  "title": "Team Meeting",
  "description": "Weekly sync",
  "startTime": "2026-10-05T10:00:00Z",
  "endTime": "2026-10-05T11:00:00Z",
  "location": "Conference Room A",
  "priority": "high"
}
```

#### query_events
```json
{
  "startTime": "2026-10-01T00:00:00Z",
  "endTime": "2026-10-31T23:59:59Z"
}
```

## Getting Started

### Prerequisites

- Flutter SDK 3.24.0+
- Dart SDK 3.5.0+

### Installation

```bash
git clone https://github.com/yourusername/TomatoSchedule.git
cd TomatoSchedule
flutter pub get
flutter run
```

### Configuration

1. Get an OpenAI API key from [platform.openai.com](https://platform.openai.com)
2. Update `lib/services/ai_service.dart` with your API key

## Building

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Desktop
```bash
flutter build windows --release
flutter build macos --release
flutter build linux --release
```

## CI/CD

GitHub Actions workflows are included for:
- Code analysis and formatting checks
- Building for all platforms (triggered by tags)

## Project Structure

```
lib/
+ main.dart                 # App entry point
+ models/                   # Data models
++ event.dart
++ task.dart
+ services/                 # Business logic
++ ai_service.dart
++ database_service.dart
+ providers/                # State management
++ calendar_provider.dart
+ screens/                  # UI screens
++ calendar_screen.dart
++ chat_screen.dart
```

## License

MIT
