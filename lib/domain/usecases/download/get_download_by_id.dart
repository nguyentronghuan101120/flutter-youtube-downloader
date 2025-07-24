import 'package:injectable/injectable.dart';
import '../../entities/download_task.dart';
import '../../repositories/download_repository.dart';
import '../../../core/result/result.dart';
import '../../../core/usecases/base_usecase.dart';

@injectable
class GetDownloadById implements BaseUseCase<Result<DownloadTask>, String> {
  final DownloadRepository repository;

  GetDownloadById(this.repository);

  @override
  Future<Result<DownloadTask>> execute(String downloadId) async {
    try {
      final result = await repository.getDownloadById(downloadId);
      if (result.isSuccess) {
        return Result.success(result.data!);
      } else {
        return Result.failure(result.errorMessage!);
      }
    } catch (e) {
      return Result.failure('Failed to get download by ID: $e');
    }
  }
}
