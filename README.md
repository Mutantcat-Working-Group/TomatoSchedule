# TomatoSchedule

AI-powered cross-platform schedule planner built with Flutter.

## Features

- Calendar view (month/week/day)
- Natural language event creation
- AI-powered schedule generation
- Local SQLite storage
- Cross-platform: Android, iOS, Windows, macOS, Linux

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
