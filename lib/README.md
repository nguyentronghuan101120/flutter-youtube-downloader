# YouTube Downloader - Clean Architecture Structure

## 📁 Cấu trúc thư mục

```
lib/
├── core/                           # Core layer - Shared components
│   ├── constants/
│   │   └── app_constants.dart      # App constants và configuration
│   ├── error/
│   │   └── failures.dart           # Failure classes cho error handling
│   └── dependency_injection/
│       └── injection_container.dart # Dependency injection với GetIt
│
├── domain/                         # Domain layer - Business logic
│   ├── entities/                   # Business entities
│   │   ├── video_info.dart         # Video information entity
│   │   ├── download_task.dart      # Download task entity
│   │   └── playlist_info.dart      # Playlist information entity
│   ├── repositories/               # Repository interfaces
│   │   ├── video_repository.dart   # Video operations interface
│   │   ├── download_repository.dart # Download operations interface
│   │   └── storage_repository.dart # Storage operations interface
│   └── usecases/                   # Business use cases
│       ├── analyze_video.dart      # Analyze video use case
│       ├── analyze_playlist.dart   # Analyze playlist use case
│       ├── start_download.dart     # Start download use case
│       └── get_downloads.dart      # Get downloads use cases
│
├── data/                           # Data layer - External data sources
│   ├── models/                     # Data models (kế thừa từ entities)
│   │   ├── video_info_model.dart   # Video info model
│   │   └── playlist_info_model.dart # Playlist info model
│   ├── datasources/                # Data sources
│   │   └── youtube_datasource.dart # YouTube API data source
│   └── repositories/               # Repository implementations
│       └── video_repository_impl.dart # Video repository implementation
│
├── presentation/                   # Presentation layer - UI
│   ├── bloc/                       # State management
│   │   └── video_analysis/         # Video analysis feature
│   │       ├── video_analysis_state.dart # State classes
│   │       └── video_analysis_cubit.dart # Cubit implementation
│   ├── pages/                      # Page widgets
│   │   └── home_page.dart          # Home page
│   └── widgets/                    # Reusable widgets
│       ├── url_input_widget.dart   # URL input widget
│       └── video_info_widget.dart  # Video info display widget
│
└── main.dart                       # App entry point
```

## 🏗️ Clean Architecture Principles

### 1. **Domain Layer** (Core Business Logic)

- **Entities**: Pure business objects, không phụ thuộc framework
- **Repositories**: Abstract interfaces định nghĩa contracts
- **Use Cases**: Business logic, orchestration

### 2. **Data Layer** (External Data Access)

- **Models**: Data transfer objects, kế thừa từ entities
- **DataSources**: Raw data access (API, Database, etc.)
- **Repository Implementations**: Implementations của domain repositories

### 3. **Presentation Layer** (UI & State Management)

- **Cubits/Blocs**: State management, UI logic
- **Pages**: UI components
- **Widgets**: Reusable UI components

### 4. **Core Layer** (Shared Components)

- **Constants**: App-wide constants
- **Error Handling**: Failure classes
- **Dependency Injection**: Service locator pattern

## 🔄 Data Flow

```
User Input → Presentation Layer → Use Cases → Repositories → Data Sources
                ↓
            State Updates → UI Updates
```

## 📋 Key Features Implemented

### ✅ Completed

- [x] Clean Architecture structure
- [x] Domain entities (VideoInfo, DownloadTask, PlaylistInfo)
- [x] Repository interfaces
- [x] Use cases với error handling
- [x] Data models kế thừa từ entities
- [x] YouTube data source với youtube_explode_dart
- [x] Dependency injection với GetIt
- [x] State management với flutter_bloc
- [x] Basic UI components
- [x] Video analysis functionality

### 🚧 In Progress

- [ ] Download functionality
- [ ] Storage repository implementation
- [ ] Download repository implementation
- [ ] Audio conversion với FFmpeg
- [ ] Playlist management
- [ ] Download progress tracking

### 📝 TODO

- [ ] Localization (EN, VI, JA, KO)
- [ ] Theme management
- [ ] Settings page
- [ ] Download history
- [ ] File management
- [ ] Error handling improvements
- [ ] Unit tests
- [ ] Integration tests

## 🛠️ Dependencies

### Core Dependencies

- `flutter_bloc: ^9.1.1` - State management
- `equatable: ^2.0.5` - Value equality
- `dartz: ^0.10.1` - Functional programming
- `get_it: ^8.0.3` - Dependency injection

### YouTube & Media

- `youtube_explode_dart: ^2.5.1` - YouTube API
- `ffmpeg_kit_flutter_new: ^2.0.0` - Media processing
- `dio: ^5.8.0+1` - HTTP client

### File System

- `path_provider: ^2.1.5` - File paths
- `permission_handler: ^12.0.1` - Permissions
- `file_picker: ^10.2.0` - File picking

### Database

- `sqflite: ^2.4.2` - Local database

### Internationalization

- `intl: ^0.20.2` - Localization
- `flutter_localizations` - Flutter i18n

## 🚀 Getting Started

1. **Install dependencies**:

   ```bash
   flutter pub get
   ```

2. **Run the app**:

   ```bash
   flutter run
   ```

3. **Test the app**:
   - Enter a YouTube URL
   - Click "Analyze Video"
   - View video information and available formats

## 📱 Current Features

### Video Analysis

- ✅ URL validation
- ✅ Video metadata extraction
- ✅ Available formats display
- ✅ Thumbnail display
- ✅ Channel information
- ✅ Duration and view count

### UI/UX

- ✅ Material Design 3
- ✅ Responsive layout
- ✅ Error handling
- ✅ Loading states
- ✅ Clipboard integration

## 🔧 Development Guidelines

### Code Style

- Follow Dart conventions
- Use meaningful variable names
- Keep functions under 30 lines
- Use proper error handling

### Architecture Rules

- ✅ Domain layer không phụ thuộc framework
- ✅ Data layer implement domain interfaces
- ✅ Presentation layer chỉ import domain
- ✅ Use cases chứa business logic
- ✅ Cubits chỉ quản lý state

### Testing Strategy

- Unit tests cho use cases
- Repository tests với mocks
- Widget tests cho UI components
- Integration tests cho full flow

## 📄 License

This project follows the MIT License. See LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Follow Clean Architecture principles
4. Add tests
5. Submit pull request

---

**Note**: This is a work in progress. The basic structure is complete, but download functionality and other features are still being implemented.
