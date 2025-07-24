import 'package:injectable/injectable.dart';
import '../../repositories/download_repository.dart';
import '../../../core/error/failures.dart';
import '../../../core/result/result.dart' as result;
import 'package:dartz/dartz.dart';

@injectable
class ReorderDownloadQueue {
  final DownloadRepository repository;

  ReorderDownloadQueue(this.repository);

  Future<Either<Failure, void>> call(List<String> taskIds) async {
    try {
      final result = await repository.reorderQueue(taskIds);
      if (result.isSuccess) {
        return const Right(null);
      } else {
        return Left(CacheFailure(result.errorMessage!));
      }
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
