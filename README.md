# Dhikr Reminder

A Flutter application that displays spiritual reminders (Dhikr) every time you unlock your phone.

## Features

- 📱 **Screen Unlock Trigger**: Shows a Dhikr quote when you unlock your phone
- ⚙️ **Frequency Control**: Choose between "Every Unlock" or limited times per day
- 📚 **Content Management**: Browse default quotes or add your own custom Dhikr
- 🏷️ **Categories**: Filter by Morning, Evening, General, Forgiveness, Gratitude, Protection
- 🔐 **Authentication**: Secure login with Supabase Auth
- ☁️ **Cloud Sync**: All settings and custom quotes synced via Supabase

## Architecture

Built with **Clean Architecture** and **DDD** principles:

```
lib/
├── core/               # Common utilities, errors, constants
├── data/               # Data layer (repositories, models, datasources)
├── domain/             # Domain layer (entities, use cases, repository interfaces)
├── presentation/       # UI layer (blocs, screens, widgets)
└── services/           # Platform-specific services
```

## Tech Stack

- **State Management**: flutter_bloc
- **Dependency Injection**: get_it + injectable
- **Backend**: Supabase (PostgreSQL + Realtime)
- **Authentication**: Supabase Auth
- **Background Execution**: Android BroadcastReceiver + Foreground Service

## Setup

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Configure Supabase

Create a `.env` file or set environment variables:

```bash
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

Then run the SQL schema in `supabase/schema.sql` in your Supabase SQL Editor.

### 3. Run Build Runner (for DI)

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Run the App

```bash
flutter run
```

## Android Permissions

The app requires the following permissions for screen unlock detection:

- `SYSTEM_ALERT_WINDOW` - To show overlay above lock screen
- `FOREGROUND_SERVICE` - To keep service running
- `RECEIVE_BOOT_COMPLETED` - To start service on boot

## Background Execution Strategy

### Android

Uses a `BroadcastReceiver` to detect `ACTION_USER_PRESENT` (screen unlock) and triggers a foreground service that displays a system overlay with the Dhikr.

### iOS

Due to iOS restrictions on background execution, the app uses:
- Local notifications as an alternative
- Widget integration for quick access

## Project Structure

```
dhikr_reminder/
├── android/                    # Android-specific code
│   └── app/src/main/kotlin/  # BroadcastReceiver & Service
├── lib/                        # Flutter code
│   ├── data/                   # Repositories, models, datasources
│   ├── domain/                 # Entities, use cases
│   ├── presentation/           # UI, BLoCs, widgets
│   └── main.dart              # Entry point
├── supabase/                   # Database schema
│   └── schema.sql             # SQL setup
└── pubspec.yaml               # Dependencies
```

## License

MIT
