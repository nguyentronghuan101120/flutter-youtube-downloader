/// Base class for all use cases
///
/// This class provides a common interface for all use cases
/// and ensures consistent error handling
abstract class BaseUseCase<Type, Params> {
  /// Execute the use case
  ///
  /// [params] - Parameters required for the use case
  /// Returns the result of the use case
  Future<Type> execute(Params params);
}

/// Use case with no parameters
abstract class BaseUseCaseNoParams<Type> {
  /// Execute the use case
  ///
  /// Returns the result of the use case
  Future<Type> execute();
}

/// Use case with multiple parameters
abstract class BaseUseCaseMultiParams<Type> {
  /// Execute the use case
  ///
  /// Returns the result of the use case
  Future<Type> execute();
}
