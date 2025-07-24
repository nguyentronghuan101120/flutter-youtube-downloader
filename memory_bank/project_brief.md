# Project Brief - YouTube Downloader Flutter App

## 📋 Tổng quan dự án

**Tên dự án:** YouTube Downloader - Flutter Application  
**Mục tiêu:** Tạo ứng dụng đa nền tảng để tải video và audio từ YouTube  
**Kiến trúc:** Clean Architecture với Flutter  
**Trạng thái:** Đang phát triển - Video analysis hoàn thành, download functionality đang triển khai

## 🎯 Mục tiêu chính

### Core Features

1. **Video Analysis** - Phân tích metadata video YouTube ✅
2. **Download Management** - Tải video/audio với progress tracking 🚧
3. **Playlist Support** - Xử lý playlist với batch processing 🚧
4. **Audio Conversion** - Chuyển đổi sang MP3 với FFmpeg 🚧
5. **File Management** - Quản lý file đã tải 🚧

### Enhanced Features

6. **Multi-language Support** - EN, VI, JA, KO 🚧
7. **Theme Management** - Dark/light mode 🚧
8. **User Preferences** - Lưu cài đặt người dùng 🚧
9. **Download History** - Lịch sử tải với database 🚧

## 🏗️ Kiến trúc hệ thống

### Clean Architecture Layers

- **Domain Layer** - Business logic, entities, use cases
- **Data Layer** - External data sources, repositories implementation
- **Presentation Layer** - UI, state management
- **Core Layer** - Shared services, DI, error handling

### Technology Stack

- **Framework:** Flutter 3.8.1+
- **State Management:** flutter_bloc
- **Dependency Injection:** GetIt + Injectable
- **Data Classes:** Freezed
- **YouTube API:** youtube_explode_dart
- **Media Processing:** FFmpeg Kit Flutter
- **Database:** SQLite (sqflite)
- **Local Storage:** SharedPreferences

## 📱 Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🔧 Development Environment

- **SDK:** Dart 3.8.1+
- **IDE:** VS Code / Android Studio
- **Code Generation:** build_runner
- **Linting:** flutter_lints
- **Version Control:** Git

## 📊 Current Status

### ✅ Completed (80%)

- Clean Architecture structure
- Domain entities với Freezed
- YouTube service với rate limiting
- Video analysis functionality
- UI components với Material 3
- Dependency injection setup
- Error handling framework

### 🚧 In Progress (15%)

- Download functionality
- Storage repository
- Audio conversion
- Playlist management

### 📝 TODO (5%)

- Multi-language implementation
- Theme management
- Download history
- Performance optimization

## 🎨 Design Principles

### Clean Architecture Rules

1. **Domain layer** không phụ thuộc framework
2. **Cubit chỉ sử dụng UseCases**
3. **Model kế thừa Entity**
4. **Repository trả về trực tiếp từ DataSource**
5. **Dependency injection đã đăng ký đầy đủ**

### Code Quality

- Follow Dart conventions
- Use meaningful variable names
- Keep functions under 30 lines
- Proper error handling với Either type
- Code generation với Freezed và Injectable

## 🚀 Success Metrics

### Technical Metrics

- Response time < 3s cho video analysis
- Memory usage < 500MB
- Uptime > 99.9%
- Error rate < 1%

### User Experience

- Learning curve < 2 phút
- Accessibility compliance
- Multi-language support
- Responsive design

## 📈 Roadmap

### Phase 1: Core Features (Current)

- ✅ Video analysis
- 🚧 Download functionality
- 🚧 Audio conversion
- 🚧 Basic playlist support

### Phase 2: Enhanced Features

- 📝 Multi-language implementation
- 📝 Theme management
- 📝 Download history
- 📝 Advanced settings

### Phase 3: Advanced Features

- 📝 Performance optimization
- 📝 Advanced quality options
- 📝 Subtitle extraction
- 📝 Batch processing

## 🔒 Security & Privacy

- Input validation cho URLs
- HTTPS enforcement
- Local storage only (no cloud sync)
- Permission handling
- Rate limiting cho API calls

## 📄 License

MIT License - Open source project
