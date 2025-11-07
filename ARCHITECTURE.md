# Architecture Overview

## Project Structure

```
lib/
├── config/           # Configuration files (API keys, app settings)
├── models/          # Data models (UserState, BrainActivity, etc.)
├── providers/       # State management (Provider pattern)
├── routes/          # Navigation/routing configuration
├── screens/         # UI screens
└── services/        # Business logic and API integrations
```

## Key Components

### 1. State Management (Providers)

- **AppStateProvider**: Manages app-wide state, daily questions, user state
- **VoiceProvider**: Handles voice recording, transcription, and emotion analysis
- **BrainVisualizationProvider**: Manages brain activity data and neural signals
- **CompanionProvider**: Manages conversational AI interactions

### 2. Services

- **SpeechService**: Handles speech-to-text using OpenAI Whisper or Google Cloud
- **EmotionAnalysisService**: Analyzes emotions from text and audio
- **CompanionService**: Generates conversational responses using GPT
- **TherapySuggestionService**: Provides personalized therapy activity suggestions
- **DatabaseService**: Local data persistence using SQLite and SharedPreferences

### 3. Screens

- **HomeScreen**: Main dashboard with quick actions
- **DailyQuestionsScreen**: Voice question interface with recording
- **BrainVisualizationScreen**: 3D brain model with neural activity visualization
- **CompanionChatScreen**: Conversational AI interface
- **SuggestionsScreen**: Therapy and activity recommendations

## Data Flow

### Daily Questions Flow

1. User opens Daily Questions screen
2. App loads questions from database or generates new ones
3. User records voice response
4. Audio is transcribed using SpeechService
5. EmotionAnalysisService analyzes transcribed text and audio
6. Results update BrainVisualizationProvider
7. Data is saved to local database

### Companion Chat Flow

1. User types or speaks a message
2. VoiceProvider transcribes if audio
3. EmotionAnalysisService extracts emotion context
4. CompanionService generates response using GPT
5. Response is spoken using TTS
6. Conversation history is maintained

### Brain Visualization Flow

1. Emotion analysis results are passed to BrainVisualizationProvider
2. Provider maps emotions to brain regions
3. Neural signals are generated based on activity levels
4. UI renders visual representation with color-coded regions

## API Integrations

### Speech-to-Text
- **Primary**: OpenAI Whisper API
- **Fallback**: Google Cloud Speech-to-Text

### Text-to-Speech
- **Primary**: flutter_tts (free, open-source, device-native TTS)
  - Uses device's built-in TTS engines (no API keys needed)
  - Supports multiple languages and voices
  - Completely free and offline-capable

### Conversational AI
- **Primary**: OpenAI GPT-3.5/GPT-4
- **Fallback**: Simple rule-based responses

### Emotion Analysis
- **Primary**: OpenAI GPT for text analysis
- **Backend**: Custom audio analysis (optional)

## Backend Integration (Optional)

The app can work standalone, but a backend server enables:
- Advanced audio emotion analysis
- Incremental model learning
- Cloud data synchronization
- Advanced recommendation algorithms

See `backend_example/` for a sample Node.js server implementation.

## Future Enhancements

1. **3D Brain Rendering**: Integrate Three.js or Unity for true 3D visualization
2. **Advanced ML**: On-device emotion recognition models
3. **Real-time Analysis**: WebSocket connections for live emotion tracking
4. **Social Features**: Anonymous community support (optional)
5. **Progress Tracking**: Long-term emotional pattern visualization

