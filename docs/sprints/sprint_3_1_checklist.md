# 📋 Sprint 3.1 Checklist - Subtitle Extraction (Week 10)

## 🎯 Mục tiêu Sprint

Triển khai trích xuất subtitle (F10) với format conversion, preview functionality, và subtitle embedding vào video.

**Liên kết SRS:** F10 - Subtitle Extraction, F5 - Audio Conversion, F3 - Format Selection

---

## 📊 Phase Breakdown

### Phase 1: Domain Layer - Subtitle Entities

**Mục tiêu:** Thiết lập subtitle entities và domain logic

#### Task List:

- [ ] **T3.1.1** - `lib/domain/entities/subtitle_info.dart`

  - Implement subtitle entity với language và format info
  - Thêm subtitle metadata và timing information
  - Liên kết SRS: F10 - Subtitle Extraction

- [ ] **T3.1.4** - `lib/domain/usecases/extract_subtitle.dart`
  - Implement subtitle extraction use case
  - Thêm language selection và format options
  - Liên kết SRS: F10 - Subtitle Extraction

#### Deliverables:

- Subtitle entity với metadata
- Subtitle extraction use case
- Language và format support

### Phase 2: Core Services - Subtitle Processing

**Mục tiêu:** Thiết lập subtitle extraction và conversion services

#### Task List:

- [ ] **T3.1.2** - `lib/core/services/subtitle_service.dart`

  - Implement subtitle extraction service
  - Thêm subtitle parsing và language detection
  - Liên kết SRS: F10 - Subtitle Extraction

- [ ] **T3.1.6** - `lib/core/services/subtitle_converter.dart`

  - Implement subtitle format conversion
  - Thêm SRT, VTT, ASS format support
  - Liên kết SRS: F10 - Subtitle Extraction

- [ ] **T3.1.9** - `lib/core/services/subtitle_embedder.dart`
  - Implement subtitle embedding service
  - Thêm subtitle embedding vào video files
  - Liên kết SRS: F10 - Subtitle Extraction

#### Deliverables:

- Subtitle extraction service
- Subtitle format conversion
- Subtitle embedding functionality

### Phase 3: Presentation Layer - Subtitle UI

**Mục tiêu:** Triển khai UI cho subtitle selection và preview

#### Task List:

- [ ] **T3.1.3** - `lib/presentation/widgets/subtitle_selection_widget.dart`

  - Create subtitle selection UI
  - Thêm language selection và format options
  - Liên kết SRS: F10 - Subtitle Extraction

- [ ] **T3.1.5** - `lib/presentation/widgets/subtitle_preview_widget.dart`

  - Create subtitle preview widget
  - Thêm subtitle preview với timing display
  - Liên kết SRS: F10 - Subtitle Extraction

- [ ] **T3.1.8** - `lib/presentation/widgets/subtitle_download_widget.dart`
  - Create subtitle download UI
  - Thêm download options và format selection
  - Liên kết SRS: F10 - Subtitle Extraction

#### Deliverables:

- Subtitle selection UI
- Subtitle preview functionality
- Subtitle download interface

### Phase 4: State Management - Subtitle System

**Mục tiêu:** Thiết lập state management cho subtitle operations

#### Task List:

- [ ] **T3.1.7** - `lib/presentation/bloc/subtitle/subtitle_cubit.dart`
  - Implement subtitle state management
  - Thêm subtitle loading và extraction states
  - Liên kết SRS: F10 - Subtitle Extraction

#### Deliverables:

- Subtitle state management hoàn chỉnh
- Subtitle extraction states
- Language selection states

---

## 📈 Progress Tracking

**Tổng tiến độ:** 0/9 tasks - 0%

**Phase Progress:**

- Phase 1 (Domain Layer): 0/2 tasks - 0%
- Phase 2 (Core Services): 0/3 tasks - 0%
- Phase 3 (Presentation Layer): 0/3 tasks - 0%
- Phase 4 (State Management): 0/1 tasks - 0%

**Ưu tiên tiếp theo:** Bắt đầu với Phase 1 - Domain Layer Subtitle Entities

---

## 🚨 Current Issues to Fix

### Critical Issues:

1. **Missing Subtitle Entity** - Chưa có subtitle entity với metadata

   - **Mức độ:** Critical
   - **Khắc phục:** Implement subtitle entity với language và format info
   - **File:** `lib/domain/entities/subtitle_info.dart`

2. **No Subtitle Extraction Service** - Chưa có subtitle extraction functionality

   - **Mức độ:** Critical
   - **Khắc phục:** Implement subtitle service với parsing
   - **File:** `lib/core/services/subtitle_service.dart`

3. **Missing Subtitle Use Case** - Chưa có subtitle extraction business logic
   - **Mức độ:** High
   - **Khắc phục:** Implement subtitle extraction use case
   - **File:** `lib/domain/usecases/extract_subtitle.dart`

### Next Priority Issues:

4. **No Subtitle UI** - Chưa có subtitle selection và preview UI

   - **Mức độ:** High
   - **Khắc phục:** Create subtitle selection và preview widgets
   - **File:** `lib/presentation/widgets/subtitle_selection_widget.dart`

5. **Missing Subtitle State Management** - Chưa có subtitle state management

   - **Mức độ:** Medium
   - **Khắc phục:** Implement subtitle cubit và states
   - **File:** `lib/presentation/bloc/subtitle/subtitle_cubit.dart`

6. **No Subtitle Format Conversion** - Chưa có subtitle format conversion
   - **Mức độ:** Medium
   - **Khắc phục:** Implement subtitle converter service
   - **File:** `lib/core/services/subtitle_converter.dart`

---

## 📝 Ghi chú

### Kiến trúc và Công nghệ:

- **Subtitle Extraction:** YouTube subtitle extraction và parsing
- **Format Conversion:** SRT, VTT, ASS format support
- **Subtitle Embedding:** Embed subtitles vào video files
- **Language Support:** Multiple language subtitle support

### Công nghệ sử dụng:

- **youtube_explode_dart:** Subtitle extraction từ YouTube
- **ffmpeg_kit_flutter_new:** Subtitle embedding và conversion
- **flutter_bloc:** Subtitle state management
- **dart:convert:** Subtitle format parsing

### Subtitle Features:

- **Language Detection:** Automatic language detection
- **Format Support:** SRT, VTT, ASS subtitle formats
- **Subtitle Preview:** Real-time subtitle preview
- **Embedding Options:** Hard-coded và soft-coded subtitles
- **Timing Synchronization:** Accurate subtitle timing

### Performance Considerations:

- **Subtitle Parsing:** Efficient subtitle parsing
- **Format Conversion:** Fast format conversion
- **Embedding Process:** Efficient subtitle embedding
- **Memory Management:** Handle large subtitle files

### Subtitle Processing:

- **Extraction:** Extract subtitles từ YouTube videos
- **Parsing:** Parse subtitle timing và text
- **Conversion:** Convert between subtitle formats
- **Embedding:** Embed subtitles vào video files
- **Preview:** Real-time subtitle preview

### Các bước tiếp theo:

1. Hoàn thành Domain Layer Subtitle Entities (Phase 1)
2. Implement Core Services (Phase 2)
3. Triển khai Presentation Layer (Phase 3)
4. Thiết lập State Management (Phase 4)
5. Integration với existing video analysis system
6. Subtitle functionality review

### Ràng buộc kỹ thuật:

- Support multiple subtitle formats (SRT, VTT, ASS)
- Handle subtitle timing synchronization
- Provide accurate language detection
- Support subtitle embedding vào video files
- Ensure efficient subtitle processing
