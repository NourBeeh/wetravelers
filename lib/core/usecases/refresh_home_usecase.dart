import 'package:flutter/foundation.dart';
import '../repositories/contracts/home_repository.dart';
import '../network/api_result.dart';

@immutable
class RefreshHomeUseCase {
  const RefreshHomeUseCase(this.repository);

  final HomeRepository repository;

  Future<ApiResult<void>> call() => repository.refresh();
}
