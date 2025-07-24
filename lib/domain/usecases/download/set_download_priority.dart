import 'package:injectable/injectable.dart';
import '../../repositories/download_repository.dart';
import '../../../core/error/failures.dart';
import '../../../core/result/result.dart' as result;
import 'package:dartz/dartz.dart';

@injectable
class SetDownloadPriority {
  final DownloadRepository repository;

  SetDownloadPriority(this.repository);

  Future<Either<Failure, void>> call(String taskId, int priority) async {
    try {
      final result = await repository.setPriority(taskId, priority);
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
