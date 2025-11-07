# Quick Start Guide

## Prerequisites

- Flutter SDK 3.0.0 or higher
- Android Studio / Xcode (for mobile development)
- API keys for:
  - OpenAI (for GPT and Whisper) - **Required**
  - Google Cloud (optional, for Speech-to-Text fallback)

**Note**: Text-to-Speech is free and open-source using `flutter_tts` (device-native TTS). No API keys needed!

## Installation Steps

### 1. Clone/Download the Project

```bash
cd mental_health_companion
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure API Keys

Edit `lib/config/app_config.dart`:

```dart
static const String openAiApiKey = 'sk-your-actual-key-here'; // Required
static const String googleCloudApiKey = 'your-google-key'; // Optional fallback
```

### 4. Run on Device/Emulator

**Android:**
```bash
flutter run
```

**iOS:**
```bash
flutter run
```

**Specific Device:**
```bash
flutter devices  # List available devices
flutter run -d <device-id>
```

## First Run

1. **Grant Permissions**: The app will request microphone permission on first launch
2. **Home Screen**: You'll see the main dashboard
3. **Try Daily Questions**: Navigate to Daily Questions and record a response
4. **View Brain Activity**: After answering questions, check the Brain Activity screen
5. **Chat with Companion**: Try the Companion Chat feature

## Testing Without API Keys

The app includes fallback mechanisms:
- **Speech-to-Text**: Will show error but won't crash
- **Emotion Analysis**: Falls back to keyword-based analysis
- **Companion**: Uses simple rule-based responses

## Common Issues

### Permission Denied
- **Android**: Go to Settings > Apps > Mental Health Companion > Permissions
- **iOS**: Go to Settings > Mental Health Companion > Microphone

### API Errors
- Check your API keys are correct
- Verify you have API credits/quota
- Check internet connection

### Build Errors
```bash
flutter clean
flutter pub get
flutter run
```

## Next Steps

- Read [SETUP.md](SETUP.md) for detailed configuration
- Check [ARCHITECTURE.md](ARCHITECTURE.md) for technical details
- See [FEATURES.md](FEATURES.md) for feature documentation

