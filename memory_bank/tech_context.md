# Tech Context - YouTube Downloader

## 🛠️ Technology Stack

### Core Framework

- **Flutter 3.8.1+** - Cross-platform UI framework
- **Dart 3.8.1+** - Programming language
- **Material Design 3** - UI design system

### State Management

- **flutter_bloc** - State management library
- **Cubit pattern** - Lightweight state management
- **Freezed** - Immutable data classes

### Dependency Injection

- **GetIt** - Service locator
- **Injectable** - Code generation for DI
- **build_runner** - Code generation tool

### Data Management

- **youtube_explode_dart** - YouTube API client
- **path_provider** - Platform-specific paths
- **sqflite** - SQLite database (planned)

### Media Processing

- **ffmpeg_kit_flutter_new** - FFmpeg integration
- **Audio conversion** - Multiple format support
- **Video processing** - Stream extraction

### File Management

- **dart:io** - File system operations
- **Platform-specific paths** - Android/iOS directories
- **Permission handling** - Storage permissions

## 📱 Platform Support

### Android

- **API Level 21+** - Android 5.0+
- **Storage permissions** - External storage access
- **Download directory** - System Downloads folder
- **File paths** - `/storage/emulated/0/Download/`

### iOS

- **iOS 12.0+** - Minimum iOS version
- **App documents** - App-specific storage
- **File sharing** - iTunes file sharing
- **Permission handling** - iOS file access

### Web

- **Browser APIs** - File download API
- **Local storage** - Browser storage
- **Cross-origin** - CORS handling

### Desktop

- **Windows/macOS/Linux** - Desktop platforms
- **File system** - Native file operations
- **Audio conversion** - FFmpeg support

## 🔧 Development Tools

### IDE Support

- **VS Code** - Primary development IDE
- **Android Studio** - Alternative IDE
- **Flutter Inspector** - UI debugging
- **Dart DevTools** - Performance analysis

### Code Generation

- **build_runner** - Code generation tool
- **Freezed** - Data class generation
- **Injectable** - DI code generation
- **JSON serialization** - API response mapping

### Testing Framework

- **flutter_test** - Unit testing
- **mockito** - Mocking framework
- **integration_test** - Integration testing
- **widget_test** - Widget testing

## 📊 Architecture Components

### Core Services

#### YouTube Service

- **youtube_explode_dart** - YouTube API client
- **Rate limiting** - API abuse prevention
- **Error handling** - YouTube-specific exceptions
- **Stream selection** - Video/audio stream matching
- **Metadata extraction** - Video information

#### Download Service

- **Progress tracking** - Real-time updates
- **Stream selection** - Format/quality matching
- **File management** - Safe file naming
- **Platform adaptation** - Cross-platform paths
- **Error handling** - Download failures

#### Audio Conversion Service

- **ffmpeg_kit_flutter_new** - FFmpeg integration
- **Multiple formats** - MP3, AAC, OGG, WAV, FLAC
- **Quality options** - Configurable bitrates
- **Error handling** - Conversion failures
- **File management** - Output directory handling

#### Storage Repository

- **path_provider** - Platform-specific paths
- **Permission handling** - Storage permissions
- **File operations** - Create, move, delete
- **Space management** - Available space checking
- **Directory management** - Path creation

### Data Layer

#### Repository Pattern

- **Interface** - Domain layer contracts
- **Implementation** - Data layer implementations
- **Dependency injection** - GetIt registration
- **Error handling** - Result type usage

#### Data Sources

- **YouTube DataSource** - YouTube API access
- **Download DataSource** - Download management
- **Storage DataSource** - File system access
- **Preferences DataSource** - User settings

### Presentation Layer

#### State Management

- **DownloadCubit** - Download state management
- **VideoAnalysisCubit** - Video analysis state
- **PreferencesCubit** - User preferences state
- **PlaylistAnalysisCubit** - Playlist analysis state

#### UI Components

- **Material Design 3** - Modern UI design
- **Responsive layout** - Adaptive UI
- **Accessibility** - Screen reader support
- **Error handling** - User-friendly errors

## 🔄 Data Flow Architecture

### Video Analysis Flow

```
URL Input → VideoAnalysisCubit → AnalyzeVideoUseCase → VideoRepository → YouTubeService → Video Info Display
```

### Download Flow

```
Format Selection → DownloadCubit → StartDownloadUseCase → DownloadRepository → DownloadService → Progress Updates
```

### Audio Conversion Flow

```
Download Complete → AudioConversionService → FFmpeg → Output Files
```

### Storage Flow

```
File Operation → StorageRepository → Platform File System → Result
```

## 📱 Platform-Specific Implementation

### Android Implementation

- **Storage permissions** - `WRITE_EXTERNAL_STORAGE`, `READ_EXTERNAL_STORAGE`, `MANAGE_EXTERNAL_STORAGE`
- **Download directory** - `/storage/emulated/0/Download/`
- **File paths** - Android-specific path handling
- **Permission handling** - Runtime permissions

### iOS Implementation

- **App documents** - App-specific storage directory
- **File sharing** - iTunes file sharing support
- **Permission handling** - iOS file access permissions
- **Sandbox** - App sandbox restrictions

### Web Implementation

- **Browser APIs** - File download API
- **Local storage** - Browser storage limitations
- **Cross-origin** - CORS policy handling
- **File system** - Browser file system API

### Desktop Implementation

- **Native file system** - Platform file operations
- **Audio conversion** - FFmpeg native support
- **File dialogs** - Native file dialogs
- **System integration** - Platform-specific features

## 🔧 Error Handling Strategy

### Result Pattern

- **Success/Failure states** - Explicit error handling
- **Error messages** - User-friendly messages
- **Error propagation** - Layer-to-layer error passing
- **Type safety** - Compile-time error checking

### Exception Types

- **YouTube exceptions** - Video unavailable, private, etc.
- **Network exceptions** - Connection failures, timeouts
- **File exceptions** - Storage errors, permission denied
- **FFmpeg exceptions** - Conversion failures

### Error Recovery

- **Retry mechanisms** - Automatic retry for transient failures
- **Fallback options** - Alternative approaches
- **User feedback** - Clear error messages
- **Graceful degradation** - Partial functionality

## 📊 Performance Considerations

### Memory Management

- **Stream disposal** - Proper resource cleanup
- **Image caching** - Network image caching
- **File cleanup** - Temporary file removal
- **Memory leaks** - Prevent memory leaks

### Network Optimization

- **Rate limiting** - API call throttling
- **Caching** - Response caching
- **Retry logic** - Automatic retry mechanisms
- **Connection pooling** - Efficient network usage

### UI Performance

- **Minimal rebuilds** - Efficient widget updates
- **Lazy loading** - Load data on demand
- **Image optimization** - Compressed images
- **Smooth animations** - 60fps animations

## 🔒 Security Implementation

### Input Validation

- **URL validation** - YouTube URL patterns
- **File validation** - Safe file naming
- **Data sanitization** - Input cleaning
- **Permission checking** - Access control

### File Security

- **Safe file paths** - Path traversal prevention
- **Permission checking** - Storage permissions
- **File access control** - Secure file operations
- **Sandbox restrictions** - Platform security

### Data Protection

- **Local storage only** - No cloud sync
- **No sensitive data** - Minimal data collection
- **Secure error messages** - No sensitive data exposure
- **Permission management** - Minimal permissions

## 🎯 Development Workflow

### Code Generation

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Testing

```bash
flutter test
flutter test integration_test/
```

### Analysis

```bash
flutter analyze
dart format .
```

### Building

```bash
flutter build apk
flutter build ios
flutter build web
```

## 📱 Dependencies

### Core Dependencies

```yaml
flutter_bloc: ^8.1.3
get_it: ^7.6.4
injectable: ^2.3.2
freezed_annotation: ^2.4.1
youtube_explode_dart: ^2.1.0
ffmpeg_kit_flutter_new: ^6.0.3
path_provider: ^2.1.1
```

### Development Dependencies

```yaml
build_runner: ^2.4.7
freezed: ^2.4.6
injectable_generator: ^2.4.1
json_annotation: ^4.8.1
```

## 🔧 Configuration Files

### Android Configuration

- **android/app/src/main/AndroidManifest.xml** - Permissions và app config
- **android/app/build.gradle.kts** - Build configuration
- **android/gradle.properties** - Gradle properties

### iOS Configuration

- **ios/Runner/Info.plist** - App configuration
- **ios/Podfile** - CocoaPods dependencies
- **ios/Runner.xcodeproj** - Xcode project

### Flutter Configuration

- **pubspec.yaml** - Dependencies và app config
- **analysis_options.yaml** - Code analysis rules
- **lib/main.dart** - App entry point
