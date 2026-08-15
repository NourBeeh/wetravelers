/// Generic domain result used by repositories/use-cases that are not purely
/// network-bound. Kept minimal on purpose; [ApiResult] covers HTTP paths.
class Result<T> {
  const Result._();

  Result.success() : this._();
  Result.failure() : this._();

  static const instance = Result._();

  bool get isSuccess => false;
  bool get isFailure => false;
}
