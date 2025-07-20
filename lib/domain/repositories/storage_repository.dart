abstract class StorageRepository {
  /// Lấy đường dẫn thư mục download mặc định
  Future<String> getDefaultDownloadPath();

  /// Lấy đường dẫn thư mục tạm
  Future<String> getTempPath();

  /// Kiểm tra quyền truy cập storage
  Future<bool> hasStoragePermission();

  /// Yêu cầu quyền truy cập storage
  Future<bool> requestStoragePermission();

  /// Kiểm tra dung lượng trống
  Future<int> getAvailableSpace();

  /// Kiểm tra có đủ dung lượng không
  Future<bool> hasEnoughSpace(int requiredBytes);

  /// Tạo thư mục nếu chưa tồn tại
  Future<void> createDirectory(String path);

  /// Kiểm tra file có tồn tại không
  Future<bool> fileExists(String filePath);

  /// Xóa file
  Future<void> deleteFile(String filePath);

  /// Di chuyển file
  Future<void> moveFile(String sourcePath, String destinationPath);

  /// Lấy kích thước file
  Future<int> getFileSize(String filePath);

  /// Lấy danh sách file trong thư mục
  Future<List<String>> getFilesInDirectory(String directoryPath);
}
