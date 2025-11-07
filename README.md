# Mental Health Companion App

A Flutter mobile app that engages users with daily voice questions, analyzes emotional and mental states using neural networks, and provides conversational therapy support with 3D brain visualization.

## Features

- **Daily Voice Questions**: 3-5 voice questions per day with audio recording
- **Speech-to-Text**: Real-time transcription using Google Cloud Speech-to-Text or OpenAI Whisper
- **Emotional Analysis**: Neural network-based analysis of voice and text for emotional/mental state detection
- **Conversational AI**: Voice companion with empathetic responses using GPT-based models
- **3D Brain Visualization**: Dynamic neural activity representation on a 3D brain model
- **Therapy Suggestions**: Personalized therapy and activity recommendations

## Setup

1. Install Flutter dependencies:
```bash
flutter pub get
```

2. Configure API keys in `lib/config/app_config.dart`:
   - OpenAI API key (for GPT and Whisper) - **Required**
   - Google Cloud Speech-to-Text API key (optional, fallback)

3. Run the app:
```bash
flutter run
```

For detailed setup instructions, see [SETUP.md](SETUP.md)

## Architecture

- **Frontend**: Flutter with Provider/Riverpod for state management
- **Backend**: Firebase or custom Node.js server for data storage and ML processing
- **APIs**: OpenAI GPT/Whisper (primary), Google Cloud Speech-to-Text (optional fallback)
- **TTS**: flutter_tts (free, open-source, uses device-native TTS engines)

## License

MIT

