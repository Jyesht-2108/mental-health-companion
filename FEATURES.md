# Features Documentation

## Core Features

### 1. Daily Voice Questions
- **Purpose**: Engage users with 3-5 daily questions to track emotional state
- **Implementation**: 
  - Voice recording using device microphone
  - Speech-to-text transcription
  - Automatic emotion analysis
  - Progress tracking
- **User Flow**: 
  1. Open Daily Questions screen
  2. See current question
  3. Tap microphone to record
  4. Stop recording when done
  5. View transcribed text
  6. Submit answer
  7. Move to next question

### 2. Speech-to-Text
- **APIs Used**:
  - Primary: OpenAI Whisper API
  - Fallback: Google Cloud Speech-to-Text
- **Features**:
  - Real-time transcription
  - Multiple language support (configurable)
  - Automatic punctuation
  - Error handling and retry logic

### 3. Emotion & Mental State Analysis
- **Text Analysis**:
  - Uses OpenAI GPT for sentiment analysis
  - Extracts: stress, anxiety, mood, energy levels
  - Detects emotional keywords
  - Fallback to keyword-based analysis if API unavailable
- **Audio Analysis** (Optional with backend):
  - Pitch, tone, rhythm analysis
  - Combined with text for comprehensive analysis
- **Output**:
  - Stress level (0.0-1.0)
  - Anxiety level (0.0-1.0)
  - Mood score (0.0-1.0)
  - Energy level (0.0-1.0)
  - Emotion breakdown (happy, sad, anxious, calm, etc.)

### 4. Conversational AI Companion
- **Technology**: OpenAI GPT-3.5/GPT-4
- **Features**:
  - Context-aware responses
  - Emotion-aware conversation
  - Conversation history
  - Voice input/output
  - Empathetic tone
- **Capabilities**:
  - Listens to user concerns
  - Provides emotional support
  - Suggests coping strategies
  - Maintains conversation context

### 5. 3D Brain Visualization
- **Current Implementation**: 
  - 2D representation with color-coded regions
  - Activity indicators for brain regions
  - Real-time updates based on emotion analysis
- **Brain Regions Mapped**:
  - Prefrontal Cortex (stress indicator)
  - Amygdala (anxiety indicator)
  - Hippocampus (mood indicator)
  - Anterior Cingulate (stress/anxiety)
  - Insula (overall emotional state)
- **Visualization**:
  - Color-coded activity levels
  - Neural signal indicators
  - Activity metrics display
  - Region-specific activity bars

### 6. Therapy & Activity Suggestions
- **Activity Types**:
  - Breathing exercises
  - Mindfulness practices
  - Journaling
  - Meditation
  - Cognitive Behavioral Therapy (CBT) exercises
  - Progressive muscle relaxation
- **Personalization**:
  - Based on current emotional state
  - Considers stress, anxiety, mood, energy levels
  - Difficulty-appropriate suggestions
  - Duration-based filtering
- **Features**:
  - Activity descriptions
  - Duration information
  - Difficulty levels
  - Category organization

## Technical Features

### Data Persistence
- **Local Storage**: SQLite database for responses and history
- **Preferences**: SharedPreferences for user settings
- **Cloud Sync**: Optional Firebase integration

### Permissions
- **Microphone**: Required for voice recording
- **Storage**: Required for saving audio files
- **Internet**: Required for API calls

### Offline Support
- Basic functionality works offline
- Emotion analysis falls back to keyword matching
- Responses are queued for sync when online

## Future Enhancements

1. **True 3D Brain Model**: Integrate Three.js or Unity for immersive visualization
2. **Advanced Audio Analysis**: Real-time pitch/tone analysis
3. **Incremental Learning**: Model adapts to user over time
4. **Progress Tracking**: Long-term emotional pattern visualization
5. **Social Features**: Optional anonymous community support
6. **Wearable Integration**: Heart rate, sleep data integration
7. **Meditation Guides**: Guided meditation sessions
8. **Journaling**: Enhanced journaling with prompts

