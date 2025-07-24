# System Patterns - YouTube Downloader

## 🏗️ Architecture Patterns

### Clean Architecture Implementation

- **Domain Layer** - Pure business logic, no framework dependencies
- **Data Layer** - External data sources và repository implementations
- **Presentation Layer** - UI và state management
- **Core Layer** - Shared services, DI, error handling

### Dependency Flow

```
Presentation → Domain ← Data
     ↓           ↑        ↑
   UI Components Business Logic External Data
```

## 🔧 Core Patterns

### Result Pattern

- **Result<T>** type cho error handling
- Success/Failure states
- Consistent error handling across layers

### Repository Pattern

- **Interface** trong domain layer
- **Implementation** trong data layer
- **Dependency injection** với GetIt

### Use Case Pattern

- **Single responsibility** - Mỗi use case một chức năng
- **Dependency injection** - Inject repositories
- **Result type** - Consistent error handling

## 📱 State Management

### Bloc/Cubit Pattern

- **DownloadCubit** - Download state management
- **VideoAnalysisCubit** - Video analysis state
- **PreferencesCubit** - User preferences state

### State Classes

- **Freezed** cho immutable states
- **CopyWith** cho state updates
- **Equatable** cho state comparison

## 🔄 Data Flow Patterns

### Video Analysis Flow

```
URL Input → VideoAnalysisCubit → AnalyzeVideoUseCase → VideoRepository → YouTubeService
```

### Download Flow

```
Format Selection → DownloadCubit → StartDownloadUseCase → DownloadRepository → DownloadService
```

### Audio Conversion Flow

```
Download Complete → AudioConversionService → FFmpeg → Output Files
```

## 📁 File Organization

### Layer-based Structure

```
lib/
├── core/           # Shared services, DI, utilities
├── domain/         # Business logic, entities, use cases
├── data/           # External data, repositories, models
└── presentation/   # UI, state management, widgets
```

### Feature-based Organization

- **Download** - Download-related components
- **Video Analysis** - Video analysis components
- **Audio Conversion** - Audio processing components
- **Storage** - File management components

## 🔧 Service Patterns

### YouTube Service

- **Rate limiting** - Prevent API abuse
- **Retry mechanism** - Handle transient failures
- **Stream selection** - Find appropriate video/audio streams
- **Error handling** - YouTube-specific exceptions

### Download Service

- **Progress tracking** - Real-time progress updates
- **Stream selection** - Video/audio stream matching
- **File management** - Safe file naming và paths
- **Platform adaptation** - Android/iOS specific paths

### Audio Conversion Service

- **FFmpeg integration** - Native FFmpeg support
- **Multiple formats** - MP3, AAC, OGG, WAV, FLAC
- **Quality options** - Configurable bitrates
- **Error handling** - FFmpeg error handling

### Storage Repository

- **Platform paths** - Android/iOS specific directories
- **Permission handling** - Storage permissions
- **File operations** - Create, move, delete files
- **Space management** - Available space checking

## 🎯 UI Patterns

### Material Design 3

- **Dynamic color scheme** - Theme-based colors
- **Responsive layout** - Adaptive UI
- **Accessibility** - Screen reader support

### Widget Patterns

- **Stateless widgets** - Pure UI components
- **Stateful widgets** - Local state management
- **Custom widgets** - Reusable components

### Error Handling UI

- **Error states** - User-friendly error messages
- **Retry mechanisms** - Automatic retry options
- **Loading states** - Progress indicators

## 🔧 Dependency Injection

### Injectable Pattern

- **@injectable** - Regular dependencies
- **@LazySingleton** - Singleton dependencies
- **@factoryMethod** - Factory methods

### GetIt Configuration

- **External modules** - Third-party dependencies
- **Service registration** - Core services
- **Repository binding** - Interface to implementation

## 📊 Data Patterns

### Entity Patterns

- **Freezed** - Immutable data classes
- **JSON serialization** - API data mapping
- **Value objects** - Domain-specific types

### Model Patterns

- **Entity inheritance** - Models extend entities
- **JSON mapping** - API response mapping
- **Validation** - Data validation

## 🔄 Async Patterns

### Future/Async-Await

- **Non-blocking operations** - UI responsiveness
- **Error handling** - Try-catch blocks
- **Progress tracking** - Callback functions

### Stream Patterns

- **Progress streams** - Real-time updates
- **Download progress** - Percentage updates
- **Error streams** - Error propagation

## 🔧 Error Handling

### Result Pattern

- **Success/Failure states** - Explicit error handling
- **Error messages** - User-friendly messages
- **Error propagation** - Layer-to-layer error passing

### Exception Handling

- **YouTube exceptions** - Video unavailable, private, etc.
- **Network exceptions** - Connection failures
- **File exceptions** - Storage errors

## 📱 Platform Patterns

### Android Patterns

- **Storage permissions** - External storage access
- **Download directory** - System Downloads folder
- **File paths** - Android-specific paths

### iOS Patterns

- **App documents** - App-specific storage
- **File sharing** - iTunes file sharing
- **Permission handling** - iOS file access

### Cross-platform Patterns

- **Platform detection** - Platform-specific code
- **Path handling** - Platform-specific paths
- **Permission handling** - Platform-specific permissions

## 🔧 Testing Patterns

### Unit Testing

- **Use case testing** - Business logic testing
- **Repository testing** - Data layer testing
- **Service testing** - Core services testing

### Widget Testing

- **UI component testing** - Widget behavior testing
- **State testing** - State management testing
- **Integration testing** - End-to-end testing

## 📊 Performance Patterns

### Memory Management

- **Stream disposal** - Proper resource cleanup
- **Image caching** - Network image caching
- **File cleanup** - Temporary file removal

### Network Optimization

- **Rate limiting** - API call throttling
- **Caching** - Response caching
- **Retry logic** - Automatic retry mechanisms

## 🔧 Security Patterns

### Input Validation

- **URL validation** - YouTube URL patterns
- **File validation** - Safe file naming
- **Data sanitization** - Input cleaning

### File Security

- **Safe file paths** - Path traversal prevention
- **Permission checking** - Storage permissions
- **File access control** - Secure file operations

## 🎯 Code Quality Patterns

### Naming Conventions

- **Descriptive names** - Clear variable/function names
- **Consistent naming** - Consistent naming patterns
- **Domain language** - Business terminology

### Code Organization

- **Single responsibility** - One class, one purpose
- **Dependency inversion** - Depend on abstractions
- **Interface segregation** - Small, focused interfaces

### Documentation

- **API documentation** - Function documentation
- **Code comments** - Complex logic explanation
- **README files** - Project documentation
