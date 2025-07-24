# YouTube Downloader - Clean Architecture Structure

## 📁 Cấu trúc thư mục

```
lib/
├── core/                           # Core layer - Shared components
│   ├── constants/
│   │   └── app_constants.dart      # App constants và configuration
│   ├── error/
│   │   └── failures.dart           # Failure classes cho error handling
│   ├── services/
│   │   └── youtube_service.dart    # YouTube API service với rate limiting
│   └── dependency_injection/
│       └── injection.dart          # Dependency injection với GetIt
│
├── domain/                         # Domain layer - Business logic
│   ├── entities/                   # Business entities
│   │   ├── video_info.dart         # Video information entity với streams
│   │   ├── download_task.dart      # Download task entity với status tracking
│   │   ├── playlist_info.dart      # Playlist information entity
│   │   └── user_preferences.dart   # User preferences entity
│   ├── repositories/               # Repository interfaces
│   │   ├── video_repository.dart   # Video operations interface
│   │   ├── download_repository.dart # Download operations interface
│   │   ├── storage_repository.dart # Storage operations interface
│   │   └── preferences_repository.dart # Preferences operations interface
│   └── usecases/                   # Business use cases
│       ├── analyze_video.dart      # Analyze video use case
│       ├── analyze_playlist.dart   # Analyze playlist use case
│       ├── start_download.dart     # Start download use case
│       ├── get_downloads.dart      # Get downloads use case
│       ├── get_user_preferences.dart # Get preferences use case
│       └── save_user_preferences.dart # Save preferences use case
│
├── data/                           # Data layer - External data sources
│   ├── models/                     # Data models (kế thừa từ entities)
│   │   ├── video_info_model.dart   # Video info model
│   │   ├── playlist_info_model.dart # Playlist info model
│   │   └── user_preferences_model.dart # User preferences model
│   ├── datasources/                # Data sources
│   │   ├── youtube_datasource.dart # YouTube API data source
│   │   └── preferences_datasource.dart # Preferences data source
│   └── repositories/               # Repository implementations
│       ├── video_repository_impl.dart # Video repository implementation
│       ├── download_repository_impl.dart # Download repository implementation
│       ├── storage_repository_impl.dart # Storage repository implementation
│       └── preferences_repository_impl.dart # Preferences repository implementation
│
├── presentation/                   # Presentation layer - UI
│   ├── bloc/                       # State management
│   │   ├── video_analysis/         # Video analysis feature
│   │   │   ├── video_analysis_state.dart # State classes
│   │   │   └── video_analysis_cubit.dart # Cubit implementation
│   │   ├── playlist_analysis/      # Playlist analysis feature
│   │   │   ├── playlist_analysis_state.dart # State classes
│   │   │   └── playlist_analysis_cubit.dart # Cubit implementation
│   │   └── preferences/            # Preferences feature
│   │       ├── preferences_state.dart # State classes
│   │       └── preferences_cubit.dart # Cubit implementation
│   ├── pages/                      # Page widgets
│   │   ├── home_page.dart          # Home page với URL input
│   │   └── video_analysis_page.dart # Video analysis page
│   └── widgets/                    # Reusable widgets
│       ├── url_input_widget.dart   # URL input widget với validation
│       └── video_info_widget.dart  # Video info display widget
│
└── main.dart                       # App entry point với MultiBlocProvider
```

## 🏗️ Clean Architecture Principles

### 1. **Domain Layer** (Core Business Logic)

- **Entities**: Pure business objects với Freezed, không phụ thuộc framework
- **Repositories**: Abstract interfaces định nghĩa contracts
- **Use Cases**: Business logic, orchestration với error handling

### 2. **Data Layer** (External Data Access)

- **Models**: Data transfer objects, kế thừa từ entities
- **DataSources**: Raw data access (API, Database, etc.)
- **Repository Implementations**: Implementations của domain repositories với @LazySingleton

### 3. **Presentation Layer** (UI & State Management)

- **Cubits/Blocs**: State management với flutter_bloc, UI logic
- **Pages**: UI components với responsive design
- **Widgets**: Reusable UI components với Material 3

### 4. **Core Layer** (Shared Components)

- **Constants**: App-wide constants
- **Error Handling**: Failure classes với dartz
- **Services**: YouTube service với rate limiting và retry mechanism
- **Dependency Injection**: Service locator pattern với GetIt và Injectable

## 🔄 Data Flow

```
User Input → Presentation Layer → Use Cases → Repositories → Data Sources
                ↓
            State Updates → UI Updates
```

## 📋 Key Features Implemented

### ✅ Completed

- [x] **Clean Architecture structure** với 3 layer rõ ràng
- [x] **Domain entities** với Freezed (VideoInfo, DownloadTask, PlaylistInfo, UserPreferences)
- [x] **Repository interfaces** cho tất cả operations
- [x] **Use cases** với error handling và validation
- [x] **Data models** kế thừa từ entities
- [x] **YouTube service** với rate limiting và retry mechanism
- [x] **Dependency injection** với GetIt và Injectable
- [x] **State management** với flutter_bloc
- [x] **UI components** với Material 3 design
- [x] **Video analysis functionality** hoàn chỉnh
- [x] **URL validation** với regex patterns
- [x] **Multi-language support** (EN, VI, JA, KO)
- [x] **Error handling** với user-friendly messages
- [x] **Loading states** và retry functionality

### 🚧 In Progress

- [ ] **Download functionality** với progress tracking
- [ ] **Storage repository implementation** cho file management
- [ ] **Download repository implementation** cho download management
- [ ] **Audio conversion** với FFmpeg
- [ ] **Playlist management** với batch processing
- [ ] **User preferences** persistence

### 📝 TODO

- [ ] **Localization** implementation (EN, VI, JA, KO)
- [ ] **Theme management** với dark/light mode
- [ ] **Settings page** với advanced options
- [ ] **Download history** với database storage
- [ ] **File management** với permission handling
- [ ] **Advanced error handling** với retry strategies
- [ ] **Performance optimization** cho large playlists

## 🛠️ Dependencies

### Core Dependencies

- `flutter_bloc: ^9.1.1` - State management
- `equatable: ^2.0.5` - Value equality
- `dartz: ^0.10.1` - Functional programming
- `get_it: ^8.0.3` - Dependency injection
- `injectable: ^2.5.0` - Code generation cho DI

### Data Classes & Serialization

- `freezed: ^2.5.8` - Immutable data classes
- `freezed_annotation: ^2.4.4` - Freezed annotations
- `json_annotation: ^4.9.0` - JSON serialization

### YouTube & Media

- `youtube_explode_dart: ^2.5.1` - YouTube API với rate limiting
- `ffmpeg_kit_flutter_new: ^2.0.0` - Media processing
- `dio: ^5.8.0+1` - HTTP client

### File System & Storage

- `path_provider: ^2.1.5` - File paths
- `permission_handler: ^12.0.1` - Permissions
- `file_picker: ^10.2.0` - File picking
- `sqflite: ^2.4.2` - Local database
- `shared_preferences: ^2.5.3` - Local storage

### Internationalization

- `intl: ^0.20.2` - Localization
- `flutter_localizations` - Flutter i18n

### UI Components

- `flutter_svg: ^2.0.10+1` - SVG support
- `cached_network_image: ^3.4.1` - Image caching

## 🚀 Getting Started

1. **Install dependencies**:

   ```bash
   flutter pub get
   ```

2. **Generate code** (for Freezed and Injectable):

   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. **Run the app**:

   ```bash
   flutter run
   ```

4. **Test the app**:
   - Enter a YouTube URL
   - Click "Analyze Video"
   - View video information and available formats

## 📱 Current Features

### Video Analysis

- ✅ **URL validation** với regex patterns
- ✅ **Video metadata extraction** với youtube_explode_dart
- ✅ **Available formats display** (video và audio streams)
- ✅ **Thumbnail display** với cached network images
- ✅ **Channel information** và video details
- ✅ **Duration và view count** display
- ✅ **Error handling** với retry functionality
- ✅ **Rate limiting** để tránh API abuse

### UI/UX

- ✅ **Material Design 3** với dynamic color scheme
- ✅ **Responsive layout** cho different screen sizes
- ✅ **Error handling** với user-friendly messages
- ✅ **Loading states** với progress indicators
- ✅ **Clipboard integration** cho URL input
- ✅ **Multi-language support** framework
- ✅ **Accessibility** với proper labels và tooltips

### Architecture

- ✅ **Clean Architecture** với clear separation of concerns
- ✅ **Dependency Injection** với GetIt và Injectable
- ✅ **State Management** với flutter_bloc
- ✅ **Error Handling** với dartz Either type
- ✅ **Code Generation** với Freezed và build_runner

## 🔧 Development Guidelines

### Code Style

- Follow Dart conventions và flutter_lints
- Use meaningful variable names
- Keep functions under 30 lines
- Use proper error handling với Either type

### Architecture Rules

- ✅ **Domain layer** không phụ thuộc framework
- ✅ **Data layer** implement domain interfaces
- ✅ **Presentation layer** chỉ import domain
- ✅ **Use cases** chứa business logic
- ✅ **Cubits** chỉ quản lý state
- ✅ **Repository implementations** sử dụng @LazySingleton
- ✅ **Models** kế thừa từ entities

### Code Generation

- Sử dụng Freezed cho immutable data classes
- Sử dụng Injectable cho dependency injection
- Chạy `build_runner` sau khi thay đổi annotations

## 📄 License

This project follows the MIT License. See LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Follow Clean Architecture principles
4. Add proper error handling
5. Submit pull request

---

**Note**: This is a work in progress. The basic structure và video analysis functionality are complete, but download functionality và other features are still being implemented.
