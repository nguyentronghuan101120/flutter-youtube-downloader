import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';

@freezed
class Result<T> with _$Result<T> {
  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(String message) = Failure<T>;
}

/// Extension để dễ dàng chuyển đổi từ Future
extension ResultExtension<T> on Future<T> {
  Future<Result<T>> toResult() async {
    try {
      final data = await this;
      return Result.success(data);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}

/// Extension để xử lý Result
extension ResultHandler<T> on Result<T> {
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get data => when(success: (data) => data, failure: (_) => null);

  String? get errorMessage =>
      when(success: (_) => null, failure: (message) => message);
}
