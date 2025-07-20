import '../entities/download_task.dart';

abstract class DownloadRepository {
  /// Bắt đầu tải xuống video/audio
  Stream<DownloadTask> downloadVideo(DownloadTask task);

  /// Tạm dừng tải xuống
  Future<void> pauseDownload(String taskId);

  /// Tiếp tục tải xuống
  Future<void> resumeDownload(String taskId);

  /// Hủy tải xuống
  Future<void> cancelDownload(String taskId);

  /// Thử lại tải xuống
  Future<void> retryDownload(String taskId);

  /// Lấy danh sách tác vụ đang tải
  Future<List<DownloadTask>> getActiveDownloads();

  /// Lấy danh sách tác vụ đã hoàn thành
  Future<List<DownloadTask>> getCompletedDownloads();

  /// Lấy danh sách tác vụ trong hàng đợi
  Future<List<DownloadTask>> getQueuedDownloads();

  /// Xóa tác vụ đã hoàn thành
  Future<void> removeCompletedDownload(String taskId);

  /// Xóa tất cả tác vụ đã hoàn thành
  Future<void> clearCompletedDownloads();

  /// Lấy thông tin tác vụ theo ID
  Future<DownloadTask?> getDownloadTask(String taskId);

  /// Cập nhật thông tin tác vụ
  Future<void> updateDownloadTask(DownloadTask task);
}
