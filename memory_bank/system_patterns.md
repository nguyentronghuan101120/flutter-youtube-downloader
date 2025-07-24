# System Patterns - YouTube Downloader

## 🏗️ Architecture Patterns

### Clean Architecture

- **Domain Layer** - Business logic, entities, use cases
- **Data Layer** - External data sources, repositories
- **Presentation Layer** - UI, state management
- **Core Layer** - Shared services, DI, error handling

### Data Flow

```
UI → Cubit → UseCase → Repository → DataSource → External API/File System
```

## 📁 File Structure

### Domain Layer

- `entities/` - Business entities với Freezed
- `repositories/` - Repository interfaces
- `usecases/` - Business logic

### Data Layer

- `models/` - Data models kế thừa entities
- `datasources/` - External data access
- `repositories/` - Repository implementations

### Presentation Layer

- `bloc/` - State management với flutter_bloc
- `pages/` - Page widgets
- `widgets/` - Reusable UI components

### Core Layer

- `services/` - Shared services
- `dependency_injection/` - DI setup
- `error/` - Error handling
- `constants/` - App constants

## 🎯 Design Patterns

### Dependency Injection

- **GetIt** - Service locator
- **Injectable** - Code generation
- **@LazySingleton** - Repository implementations
- **@injectable** - Use cases và services

### State Management

- **flutter_bloc** - BLoC pattern
- **Cubit** - Simplified state management
- **Equatable** - Value equality

### Data Classes

- **Freezed** - Immutable data classes
- **JSON serialization** - Data persistence
- **Code generation** - build_runner

## 🔧 Technical Patterns

### Error Handling

- **Result type** - Functional error handling
- **Exception classes** - Custom error types
- **User-friendly messages** - Error display

### API Integration

- **Rate limiting** - YouTube API protection
- **Retry mechanism** - Network resilience
- **Caching** - Performance optimization

### File Management

- **Path provider** - Cross-platform file paths
- **Permission handling** - Storage access
- **Progress tracking** - Download monitoring

## 📊 Architecture Rules

### Domain Layer

- Không phụ thuộc framework
- Pure business logic
- Immutable entities
- Repository interfaces

### Data Layer

- Implement domain interfaces
- Handle external data sources
- Model kế thừa Entity
- Repository trả về trực tiếp từ DataSource

### Presentation Layer

- Chỉ import domain layer
- Cubit chỉ sử dụng UseCases
- UI components reusable
- State management centralized

### Core Layer

- Shared across layers
- Platform services
- Error handling utilities
- Dependency injection setup

## 🔄 State Management

### Cubit Structure

```dart
@injectable
class FeatureCubit extends Cubit<FeatureState> {
  final UseCase _useCase;
  // Implementation
}
```

### State Classes

```dart
@freezed
class FeatureState with _$FeatureState {
  const factory FeatureState.initial() = _Initial;
  const factory FeatureState.loading() = _Loading;
  const factory FeatureState.success(Data data) = _Success;
  const factory FeatureState.error(String message) = _Error;
}
```

## 🎨 UI Patterns

### Material Design 3

- Dynamic color scheme
- Responsive layout
- Accessibility support
- Dark/light theme

### Widget Structure

- **Pages** - Full screen views
- **Widgets** - Reusable components
- **BlocBuilder** - State-aware UI
- **Error handling** - User-friendly messages

## 📱 Platform Support

### Cross-platform

- **Android** - Native performance
- **iOS** - iOS guidelines compliance
- **Web** - Progressive web app
- **Desktop** - Native desktop apps

### Platform-specific

- **File paths** - path_provider
- **Permissions** - permission_handler
- **Storage** - sqflite, shared_preferences
- **Media** - ffmpeg_kit_flutter_new

## 🔒 Security

### Input Validation

- **URL validation** - Regex patterns
- **Data sanitization** - XSS prevention
- **Permission checks** - Storage access

### Network Security

- **HTTPS enforcement** - Secure connections
- **Rate limiting** - API protection
- **Error handling** - No sensitive data exposure

## 📈 Performance

### Code Generation

- **build_runner** - Freezed, Injectable
- **Compile-time optimization** - Type safety
- **Reduced boilerplate** - Maintainable code

### Memory Management

- **Lazy loading** - On-demand resources
- **Caching** - Network responses
- **Garbage collection** - Automatic cleanup

### UI Performance

- **const constructors** - Widget optimization
- **ListView.builder** - Efficient scrolling
- **Image caching** - Network images
