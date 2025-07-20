# 📋 Sprint 1.3 Checklist - Format Selection & UI (Week 3)

## 🎯 Mục tiêu Sprint

Triển khai giao diện lựa chọn định dạng và chất lượng (F3) với download state management, tạo foundation cho download management và progress tracking.

**Liên kết SRS:** F3 - Format Selection, F4 - Download Management, F6 - Progress Management

---

## 📊 Phase Breakdown

### Phase 1: Domain Layer - Stream Entities

**Mục tiêu:** Thiết lập entities cho video và audio streams với quality information

#### Task List:

- [x] **T1.3.1** - `lib/domain/entities/video_stream.dart` ✅

  - Implement video stream entity với quality info (resolution, bitrate, codec)
  - Thêm file size estimation
  - Liên kết SRS: F3 - Format Selection

- [x] **T1.3.2** - `lib/domain/entities/audio_stream.dart` ✅

  - Implement audio stream entity với audio quality (bitrate, sample rate, channels)
  - Thêm format support (MP3, AAC, OGG)
  - Liên kết SRS: F3 - Format Selection

- [x] **T1.3.3** - `lib/data/models/video_stream_model.dart` ✅
  - Implement stream data models với JSON serialization
  - Thêm factory methods cho YouTube stream mapping
  - Liên kết SRS: F3 - Format Selection

#### Deliverables:

- Video và audio stream entities hoàn chỉnh
- Stream data models với serialization
- Quality information foundation

### Phase 2: Presentation Layer - Format Selection UI

**Mục tiêu:** Triển khai UI cho format selection và quality comparison

#### Task List:

- [x] **T1.3.4** - `lib/presentation/widgets/format_selection_widget.dart` ✅

  - Create format selection UI với quality options
  - Thêm visual quality indicators
  - Liên kết SRS: F3 - Format Selection

- [x] **T1.3.5** - `lib/presentation/widgets/quality_comparison_widget.dart` ✅

  - Create quality comparison widget với side-by-side view
  - Thêm file size và quality metrics
  - Liên kết SRS: F3 - Format Selection

- [x] **T1.3.6** - `lib/presentation/pages/download_options_page.dart` ✅
  - Create download options page với format selection
  - Thêm download location và naming options
  - Liên kết SRS: F3 - Format Selection

#### Deliverables:

- Format selection UI hoàn chỉnh
- Quality comparison functionality
- Download options page với customization

### Phase 3: State Management - Download System

**Mục tiêu:** Thiết lập state management cho download system

#### Task List:

- [x] **T1.3.8** - `lib/presentation/bloc/download/download_cubit.dart` ✅

  - Implement download state management với queue support
  - Thêm pause, resume, cancel functionality
  - Liên kết SRS: F4 - Download Management

- [x] **T1.3.9** - `lib/presentation/bloc/download/download_state.dart` ✅
  - Implement download states (queued, downloading, paused, completed, failed)
  - Thêm progress tracking states
  - Liên kết SRS: F4 - Download Management

#### Deliverables:

- Download state management hoàn chỉnh
- Queue management functionality
- Progress tracking foundation

### Phase 4: Core Services & Constants

**Mục tiêu:** Thiết lập core services và constants cho format management

#### Task List:

- [x] **T1.3.7** - `lib/core/constants/app_constants.dart` ✅

  - Define quality và format constants
  - Thêm supported formats và quality presets
  - Liên kết SRS: F3 - Format Selection

- [x] **T1.3.10** - `lib/presentation/widgets/file_size_estimator.dart` ✅
  - Create file size estimation widget
  - Thêm real-time size calculation
  - Liên kết SRS: F3 - Format Selection

#### Deliverables:

- App constants với quality presets
- File size estimation functionality
- Core services foundation

---

## 📈 Progress Tracking

**Tổng tiến độ:** 10/10 tasks - 100% ✅

**Phase Progress:**

- Phase 1 (Domain Layer): 3/3 tasks - 100% ✅
- Phase 2 (Presentation Layer): 3/3 tasks - 100% ✅
- Phase 3 (State Management): 2/2 tasks - 100% ✅
- Phase 4 (Core Services): 2/2 tasks - 100% ✅

**Ưu tiên tiếp theo:** Sprint 1.3 đã hoàn thành! Chuyển sang Sprint 1.4 hoặc Sprint 2.1

---

## 🚨 Current Issues to Fix

### Critical Issues:

1. **Missing Stream Entities** - Chưa có video và audio stream entities

   - **Mức độ:** Critical
   - **Khắc phục:** Implement stream entities với quality information
   - **File:** `lib/domain/entities/video_stream.dart`, `lib/domain/entities/audio_stream.dart`

2. **No Format Selection UI** - Chưa có UI cho format selection

   - **Mức độ:** Critical
   - **Khắc phục:** Create format selection widgets và pages
   - **File:** `lib/presentation/widgets/format_selection_widget.dart`

3. **Missing Download State Management** - Chưa có download state management
   - **Mức độ:** High
   - **Khắc phục:** Implement download cubit và states
   - **File:** `lib/presentation/bloc/download/download_cubit.dart`

### Next Priority Issues:

4. **No Quality Comparison** - Chưa có quality comparison functionality

   - **Mức độ:** High
   - **Khắc phục:** Create quality comparison widget
   - **File:** `lib/presentation/widgets/quality_comparison_widget.dart`

5. **Missing Download Options Page** - Chưa có download options UI

   - **Mức độ:** Medium
   - **Khắc phục:** Create download options page
   - **File:** `lib/presentation/pages/download_options_page.dart`

6. **No File Size Estimation** - Chưa có file size calculation
   - **Mức độ:** Medium
   - **Khắc phục:** Implement file size estimator
   - **File:** `lib/presentation/widgets/file_size_estimator.dart`

---

## 📝 Ghi chú

### Kiến trúc và Công nghệ:

- **Stream Management:** Video và audio stream entities với quality info
- **State Management:** Download state management với queue support
- **UI Components:** Reusable format selection components
- **Quality Metrics:** File size và quality comparison

### Công nghệ sử dụng:

- **flutter_bloc:** Download state management
- **equatable:** Immutable stream entities
- **Material 3:** Modern UI components
- **dart:convert:** JSON serialization cho stream models

### UI/UX Considerations:

- **Quality Indicators:** Visual quality indicators cho different formats
- **File Size Display:** Real-time file size estimation
- **Format Comparison:** Side-by-side quality comparison
- **Download Options:** Customizable download settings

### Performance Considerations:

- **Stream Caching:** Cache stream information để tránh re-fetching
- **Size Calculation:** Efficient file size calculation
- **UI Responsiveness:** Smooth format selection experience
- **Memory Management:** Efficient stream data handling

### Các bước tiếp theo:

1. Hoàn thành Domain Layer Stream Entities (Phase 1)
2. Implement Presentation Layer UI (Phase 2)
3. Thiết lập State Management (Phase 3)
4. Triển khai Core Services (Phase 4)
5. Integration testing với Sprint 1.2

### Ràng buộc kỹ thuật:

- Support multiple video và audio formats
- Implement accurate file size estimation
- Handle quality comparison efficiently
- Provide intuitive format selection UI
