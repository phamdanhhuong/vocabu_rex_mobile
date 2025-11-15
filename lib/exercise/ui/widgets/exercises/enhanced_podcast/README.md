# Enhanced Podcast Widget - Refactored Structure

## 📁 File Structure

```
enhanced_podcast/
├── enhanced_podcast.dart          # Main UI widget (presentation layer)
├── podcast_controller.dart        # Business logic + TTS control
├── podcast_state.dart            # State management (immutable state class)
└── widgets/
    ├── podcast_media_section.dart     # Media display (top section)
    ├── podcast_controls.dart          # Playback controls (Replay | Play/Pause | Next)
    └── podcast_transcript.dart        # Transcript with active segment highlighting
```

## 🎯 Architecture Overview

### Separation of Concerns

1. **UI Layer** (`enhanced_podcast.dart`)
   - Pure presentation logic
   - Listens to controller changes via `notifyListeners()`
   - Renders UI based on current state
   - Delegates all actions to controller

2. **Business Logic** (`podcast_controller.dart`)
   - TTS setup and management
   - Playback control (play, pause, seek)
   - Segment progression logic
   - Question flow management
   - State updates via immutable `PodcastState`

3. **State Management** (`podcast_state.dart`)
   - Immutable state class
   - `copyWith()` for state updates
   - Type-safe state representation
   - Easy to test and debug

4. **UI Components** (`widgets/`)
   - Reusable, focused widgets
   - Each widget handles one responsibility
   - Easy to modify and maintain

## 🔧 How It Works

### State Flow

```
User Action
    ↓
Controller Method (e.g., togglePlayPause())
    ↓
Update State (via copyWith())
    ↓
notifyListeners()
    ↓
Widget rebuild with new state
```

### Example: Play/Pause Flow

```dart
// 1. User taps play button (in enhanced_podcast.dart)
PodcastControls(
  onPlayPause: _controller.togglePlayPause,  // Delegate to controller
)

// 2. Controller handles logic (in podcast_controller.dart)
Future<void> togglePlayPause() async {
  if (_state.isPlaying) {
    await tts.stop();
    _updateState(_state.copyWith(isPlaying: false, isPaused: true));
  } else {
    startPlayback();
  }
}

// 3. State update triggers rebuild (in enhanced_podcast.dart)
@override
Widget build(BuildContext context) {
  final podcastState = _controller.state;  // Get current state
  return PodcastControls(
    isPlaying: podcastState.isPlaying,  // Use state for UI
    ...
  );
}
```

## 🚀 Benefits

### 1. **Testability**
- Test controller logic without UI
- Mock TTS easily
- Verify state transitions

### 2. **Maintainability**
- Clear separation: UI vs Logic
- Easy to locate bugs (which layer?)
- Smaller files, focused responsibilities

### 3. **Reusability**
- UI components can be reused
- Controller logic portable
- State class can be serialized

### 4. **Debugging**
- State transitions are explicit
- Print current state easily: `print(_controller.state)`
- No hidden setState() scattered everywhere

## 📝 Usage Example

```dart
// In parent widget (e.g., exercise_screen.dart)
EnhancedPodcast(
  meta: podcastMeta,
  exerciseId: 'abc123',
)

// That's it! All logic is self-contained in the widget hierarchy.
```

## 🛠️ Extending

### Control Buttons Behavior

**Replay (⏪)**: Dừng và phát lại segment hiện tại từ đầu
```dart
Future<void> seekBackward() async {
  await tts.stop();
  await _playCurrentSegment(); // Replay current segment
}
```

**Next (⏭️)**: Dừng và chuyển sang segment tiếp theo
```dart
Future<void> seekForward() async {
  await tts.stop();
  final nextIndex = _state.currentSegmentIndex + 1;
  if (nextIndex < meta.segments.length) {
    _updateState(_state.copyWith(currentSegmentIndex: nextIndex));
    await _playCurrentSegment();
  }
}
```

### Adding a New Feature

1. **Add state field** in `podcast_state.dart`
   ```dart
   final bool newFeature;
   ```

2. **Add controller method** in `podcast_controller.dart`
   ```dart
   void handleNewFeature() {
     _updateState(_state.copyWith(newFeature: true));
   }
   ```

3. **Use in UI** in `enhanced_podcast.dart`
   ```dart
   if (podcastState.newFeature) {
     // Show new UI
   }
   ```

### Creating a New Widget Component

1. Create file in `widgets/` folder
2. Accept only presentation props (no business logic)
3. Use callbacks for user actions
4. Keep it focused on one responsibility

## 🔍 Troubleshooting

### State not updating?
- Check if `_updateState()` is called in controller
- Verify `notifyListeners()` in `_updateState()`
- Ensure widget rebuilds on controller changes

### TTS issues?
- All TTS logic in `podcast_controller.dart`
- Check completion handler setup
- Verify voice change logic

### UI not responsive?
- Check if state is passed correctly to components
- Verify callbacks are wired up
- Ensure widgets are stateless where possible

## 📚 Related Files

- `podcast_question_widgets.dart` - Question UI components (Match, TrueFalse, etc.)
- `enhanced_podcast_meta_entity.dart` - Data models for podcast metadata
- `exercise_bloc.dart` - Exercise state management (completion tracking)

## ✅ TODO

- [ ] Remove old commented code in `enhanced_podcast.dart` after testing
- [ ] Add unit tests for `PodcastController`
- [ ] Add widget tests for UI components
- [ ] Implement media player for GIF/Video/Lottie
- [ ] Add seek functionality for progress bar (currently read-only)
- [ ] Optimize TTS completion handler for better reliability

---

**Last Updated**: 2025-11-13  
**Author**: Refactored for better maintainability
