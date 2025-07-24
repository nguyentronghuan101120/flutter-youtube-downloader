# Tech Context - YouTube Downloader

## 🛠️ Technology Stack

### Core Framework

- **Flutter 3.8.1+** - Cross-platform UI framework
- **Dart 3.8.1+** - Programming language
- **Material Design 3** - UI/UX design system

### State Management

- **flutter_bloc 9.1.1** - BLoC pattern implementation
- **equatable 2.0.5** - Value equality
- **dartz 0.10.1** - Functional programming utilities

### Dependency Injection

- **get_it 8.0.3** - Service locator
- **injectable 2.5.0** - Code generation cho DI
- **injectable_generator 2.7.0** - DI code generation

### Data Classes & Serialization

- **freezed 2.5.8** - Immutable data classes
- **freezed_annotation 2.4.4** - Freezed annotations
- **json_annotation 4.9.0** - JSON serialization
- **json_serializable 6.9.0** - JSON code generation

### YouTube & Media

- **youtube_explode_dart 2.5.1** - YouTube API client
- **ffmpeg_kit_flutter_new 2.0.0** - Media processing
- **dio 5.8.0+1** - HTTP client

### File System & Storage

- **path_provider 2.1.5** - Cross-platform file paths
- **permission_handler 12.0.1** - Platform permissions
- **file_picker 10.2.0** - File selection
- **sqflite 2.4.2** - SQLite database
- **shared_preferences 2.5.3** - Local storage

### UI Components

- **flutter_svg 2.0.10+1** - SVG support
- **cached_network_image 3.4.1** - Image caching
- **cupertino_icons 1.0.8** - iOS-style icons

### Internationalization

- **intl 0.20.2** - Localization utilities
- **flutter_localizations** - Flutter i18n

### Development Tools

- **build_runner 2.4.0** - Code generation
- **flutter_lints 5.0.0** - Code linting
- **analysis_options.yaml** - Lint configuration

## 📱 Platform Support

### Mobile Platforms

- **Android** - Native Android app
- **iOS** - Native iOS app

### Desktop Platforms

- **Windows** - Windows desktop app
- **macOS** - macOS desktop app
- **Linux** - Linux desktop app

### Web Platform

- **Web** - Progressive web app

## 🔧 Development Environment

### IDE & Tools

- **VS Code** / **Android Studio** - Development IDE
- **Flutter SDK** - Framework SDK
- **Dart SDK** - Language SDK
- **Git** - Version control

### Code Generation

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Build Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run development app
flutter build apk        # Build Android APK
flutter build ios        # Build iOS app
flutter build web        # Build web app
```

## 📁 Project Structure

### Core Directories

- `lib/` - Main source code
- `android/` - Android-specific code
- `ios/` - iOS-specific code
- `web/` - Web-specific code
- `windows/` - Windows-specific code
- `macos/` - macOS-specific code
- `linux/` - Linux-specific code

### Configuration Files

- `pubspec.yaml` - Dependencies và project config
- `analysis_options.yaml` - Lint rules
- `devtools_options.yaml` - DevTools config
- `.gitignore` - Git ignore rules

## 🔄 Build Process

### Development Build

1. **Install dependencies** - `flutter pub get`
2. **Generate code** - `build_runner`
3. **Run app** - `flutter run`

### Production Build

1. **Clean build** - `flutter clean`
2. **Get dependencies** - `flutter pub get`
3. **Generate code** - `build_runner`
4. **Build platform** - `flutter build [platform]`

## 📊 Performance Considerations

### Memory Management

- **Lazy loading** - Load resources on demand
- **Image caching** - Cache network images
- **Garbage collection** - Automatic memory cleanup

### Network Optimization

- **Rate limiting** - YouTube API protection
- **Retry mechanism** - Network resilience
- **Caching** - Response caching

### UI Performance

- **const constructors** - Widget optimization
- **ListView.builder** - Efficient scrolling
- **Image optimization** - Compressed images

## 🔒 Security Measures

### Input Validation

- **URL validation** - Regex patterns
- **Data sanitization** - XSS prevention
- **Permission checks** - Storage access

### Network Security

- **HTTPS enforcement** - Secure connections
- **API rate limiting** - Protection against abuse
- **Error handling** - No sensitive data exposure

## 📈 Scalability

### Code Organization

- **Clean Architecture** - Maintainable structure
- **Dependency Injection** - Loose coupling
- **Code generation** - Reduced boilerplate

### Platform Abstraction

- **Cross-platform APIs** - Unified interface
- **Platform channels** - Native functionality
- **Plugin system** - Extensible architecture

## 🧪 Testing Strategy

### Unit Testing

- **Use case testing** - Business logic
- **Repository testing** - Data layer
- **Service testing** - Core services

### Widget Testing

- **UI component testing** - Widget behavior
- **Integration testing** - Full app flow
- **Platform testing** - Cross-platform compatibility

## 📚 Documentation

### Code Documentation

- **Dart docs** - API documentation
- **README.md** - Project overview
- **Inline comments** - Code explanation

### Architecture Documentation

- **Clean Architecture** - Layer separation
- **Design patterns** - Implementation patterns
- **File structure** - Organization guide

## 🔄 Version Control

### Git Workflow

- **Feature branches** - Development isolation
- **Pull requests** - Code review
- **Semantic versioning** - Release management

### Dependencies Management

- **pubspec.yaml** - Dependency versions
- **pubspec.lock** - Locked versions
- **Dependency updates** - Security patches
