import 'package:injectable/injectable.dart';
import '../../repositories/download_repository.dart';
import '../../../core/result/result.dart';
import '../../../core/usecases/base_usecase.dart';

@injectable
class ResumeDownload implements BaseUseCase<Result<void>, String> {
  final DownloadRepository repository;

  ResumeDownload(this.repository);

  @override
  Future<Result<void>> execute(String downloadId) async {
    try {
      final result = await repository.resumeDownload(downloadId);
      if (result.isSuccess) {
        return const Result.success(null);
      } else {
        return Result.failure(result.errorMessage!);
      }
    } catch (e) {
      return Result.failure('Failed to resume download: $e');
    }
  }
}
