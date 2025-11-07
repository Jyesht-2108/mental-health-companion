# Setup Instructions

## Prerequisites

1. Install Flutter SDK (3.0.0 or higher)
2. Install Android Studio / Xcode for mobile development
3. Set up your development environment

## Configuration

### 1. API Keys Setup

Edit `lib/config/app_config.dart` and add your API keys:

```dart
static const String openAiApiKey = 'YOUR_ACTUAL_OPENAI_API_KEY'; // Required
static const String googleCloudApiKey = 'YOUR_ACTUAL_GOOGLE_CLOUD_API_KEY'; // Optional fallback
```

**Note**: Text-to-Speech uses `flutter_tts` which is free and open-source, using your device's built-in TTS engine. No API keys needed for TTS!

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Platform-Specific Setup

#### Android

1. Ensure `minSdkVersion` is set to 21 or higher in `android/app/build.gradle`
2. Permissions are already configured in `AndroidManifest.xml`

#### iOS

1. Open `ios/Runner.xcworkspace` in Xcode
2. Ensure deployment target is iOS 12.0 or higher
3. Permissions are already configured in `Info.plist`

### 4. Firebase Setup (Optional)

If using Firebase:

1. Create a Firebase project
2. Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
3. Place them in the appropriate directories

### 5. Run the App

```bash
flutter run
```

## Features

- **Daily Voice Questions**: Record responses to 3-5 daily questions
- **Speech-to-Text**: Uses OpenAI Whisper or Google Cloud Speech-to-Text
- **Emotion Analysis**: Neural network-based analysis of voice and text
- **Conversational AI**: GPT-based companion with voice synthesis
- **3D Brain Visualization**: Dynamic neural activity representation
- **Therapy Suggestions**: Personalized activity recommendations

## Backend Setup (Optional)

For advanced features like audio emotion analysis:

1. Set up a Node.js backend server
2. Update `backendBaseUrl` in `app_config.dart`
3. Implement endpoints:
   - `/analyze-audio` - Audio emotion analysis
   - `/train-model` - Incremental learning
   - `/get-suggestions` - Advanced therapy suggestions

## Troubleshooting

- **Microphone Permission**: Ensure permissions are granted in device settings
- **API Errors**: Check your API keys and quotas
- **Build Errors**: Run `flutter clean` and `flutter pub get`

