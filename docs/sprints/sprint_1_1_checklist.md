# 📋 Sprint 1.1 Checklist - Foundation & URL Input (Week 1)

## 🎯 Mục tiêu Sprint

Thiết lập foundation và triển khai chức năng nhập URL (F1) với validation hoàn chỉnh, tạo nền tảng cho video analysis và download management.

**Liên kết SRS:** F1 - URL Input, F2 - Video Analysis, F4 - Download Management

---

## 📊 Phase Breakdown

### Phase 1: Domain Layer Foundation

**Mục tiêu:** Thiết lập entities và repository interfaces cho video analysis và download management

#### Task List:

- [ ] **T1.1.1** - `lib/domain/entities/video_info.dart`

  - Implement VideoInfo entity với metadata fields (title, duration, thumbnail, formats)
  - Thêm validation cho video URL format
  - Liên kết SRS: F2 - Video Analysis

- [ ] **T1.1.2** - `lib/domain/entities/download_task.dart`

  - Implement DownloadTask entity với status tracking (pending, downloading, completed, failed)
  - Thêm progress tracking fields (bytesDownloaded, totalBytes)
  - Liên kết SRS: F4 - Download Management

- [ ] **T1.1.3** - `lib/domain/repositories/video_repository.dart`

  - Define VideoRepository interface với analyzeVideo method
  - Thêm error handling cho network failures
  - Liên kết SRS: F2 - Video Analysis

- [ ] **T1.1.4** - `lib/domain/repositories/download_repository.dart`
  - Define DownloadRepository interface với startDownload, pauseDownload, resumeDownload methods
  - Thêm queue management methods
  - Liên kết SRS: F4 - Download Management

#### Deliverables:

- VideoInfo và DownloadTask entities hoàn chỉnh
- Repository interfaces với proper error handling
- Domain layer foundation sẵn sàng cho implementation

### Phase 2: Use Cases Implementation

**Mục tiêu:** Triển khai business logic cho video analysis và download management

#### Task List:

- [ ] **T1.1.5** - `lib/domain/usecases/analyze_video.dart`

  - Implement AnalyzeVideoUseCase với URL validation
  - Thêm error handling cho invalid URLs
  - Liên kết SRS: F2 - Video Analysis

- [ ] **T1.1.6** - `lib/domain/usecases/start_download.dart`
  - Implement StartDownloadUseCase với format selection
  - Thêm validation cho download parameters
  - Liên kết SRS: F4 - Download Management

#### Deliverables:

- AnalyzeVideoUseCase hoàn chỉnh với validation
- StartDownloadUseCase với parameter validation
- Business logic foundation cho core features

### Phase 3: Data Layer Foundation

**Mục tiêu:** Thiết lập data sources và models cho YouTube API integration

#### Task List:

- [ ] **T1.1.7** - `lib/data/datasources/youtube_datasource.dart`

  - Implement YouTube API integration với youtube_explode_dart
  - Thêm error handling cho API failures
  - Liên kết SRS: F2 - Video Analysis

- [ ] **T1.1.8** - `lib/data/models/video_info_model.dart`
  - Implement VideoInfo data model với JSON serialization
  - Thêm factory methods cho API response mapping
  - Liên kết SRS: F2 - Video Analysis

#### Deliverables:

- YouTube API integration foundation
- VideoInfo data model với serialization
- Data layer sẵn sàng cho repository implementation

### Phase 4: Presentation Layer - URL Input

**Mục tiêu:** Triển khai UI cho URL input với validation

#### Task List:

- [ ] **T1.1.9** - `lib/presentation/widgets/url_input_widget.dart`

  - Create URL input widget với validation
  - Thêm real-time URL format checking
  - Liên kết SRS: F1 - URL Input

- [ ] **T1.1.10** - `lib/presentation/bloc/video_analysis/video_analysis_cubit.dart`
  - Implement video analysis state management
  - Thêm loading states và error handling
  - Liên kết SRS: F2 - Video Analysis

#### Deliverables:

- URL input widget với validation hoàn chỉnh
- Video analysis state management
- UI foundation cho video analysis flow

---

## 📈 Progress Tracking

**Tổng tiến độ:** 0/10 tasks - 0%

**Phase Progress:**

- Phase 1 (Domain Layer): 0/4 tasks - 0%
- Phase 2 (Use Cases): 0/2 tasks - 0%
- Phase 3 (Data Layer): 0/2 tasks - 0%
- Phase 4 (Presentation Layer): 0/2 tasks - 0%

**Ưu tiên tiếp theo:** Bắt đầu với Phase 1 - Domain Layer Foundation

---

## 🚨 Current Issues to Fix

### Critical Issues:

1. **Missing Domain Entities** - Chưa có VideoInfo và DownloadTask entities

   - **Mức độ:** Critical
   - **Khắc phục:** Implement entities theo Clean Architecture pattern
   - **File:** `lib/domain/entities/`

2. **No Repository Interfaces** - Chưa có repository contracts
   - **Mức độ:** Critical
   - **Khắc phục:** Define interfaces cho video và download repositories
   - **File:** `lib/domain/repositories/`

### Next Priority Issues:

3. **Missing Use Cases** - Chưa có business logic implementation

   - **Mức độ:** High
   - **Khắc phục:** Implement AnalyzeVideoUseCase và StartDownloadUseCase
   - **File:** `lib/domain/usecases/`

4. **No YouTube API Integration** - Chưa có data source implementation

   - **Mức độ:** High
   - **Khắc phục:** Implement YouTube datasource với youtube_explode_dart
   - **File:** `lib/data/datasources/`

5. **Missing URL Input UI** - Chưa có presentation layer
   - **Mức độ:** Medium
   - **Khắc phục:** Create URL input widget với validation
   - **File:** `lib/presentation/widgets/`

---

## 📝 Ghi chú

### Kiến trúc và Công nghệ:

- **Clean Architecture:** Tuân thủ strict separation giữa Domain, Data, và Presentation layers
- **Dependency Injection:** Sử dụng get_it và injectable cho loose coupling
- **State Management:** flutter_bloc cho video analysis state management
- **Validation:** URL format validation với regex patterns

### Công nghệ sử dụng:

- **youtube_explode_dart:** YouTube API integration
- **equatable:** Immutable entities
- **dio:** HTTP client cho network requests
- **flutter_bloc:** State management

### Các bước tiếp theo:

1. Hoàn thành Domain Layer Foundation (Phase 1)
2. Implement Use Cases (Phase 2)
3. Thiết lập Data Layer (Phase 3)
4. Triển khai Presentation Layer (Phase 4)
5. Integration testing giữa các layers

### Ràng buộc pháp lý:

- Tuân thủ YouTube Terms of Service
- Chỉ sử dụng cho mục đích cá nhân
- Không vi phạm DMCA hoặc copyright laws
