import 'package:injectable/injectable.dart';
import '../../entities/download_task.dart';
import '../../repositories/download_repository.dart';
import '../../../core/result/result.dart';
import '../../../core/usecases/base_usecase.dart';

@injectable
class GetActiveDownloads
    implements BaseUseCaseNoParams<Result<List<DownloadTask>>> {
  final DownloadRepository repository;

  GetActiveDownloads(this.repository);

  @override
  Future<Result<List<DownloadTask>>> execute() async {
    try {
      final result = await repository.getActiveDownloads();
      if (result.isSuccess) {
        return Result.success(result.data!);
      } else {
        return Result.failure(result.errorMessage!);
      }
    } catch (e) {
      return Result.failure('Failed to get active downloads: $e');
    }
  }
}
