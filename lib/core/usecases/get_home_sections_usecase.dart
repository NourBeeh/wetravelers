import 'package:flutter/foundation.dart';
import '../repositories/contracts/home_repository.dart';
import '../domain/models/home/home_section.dart';
import '../network/api_result.dart';

@immutable
class GetHomeSectionsUseCase {
  const GetHomeSectionsUseCase(this.repository);

  final HomeRepository repository;

  Future<ApiResult<List<HomeSection>>> call() => repository.getHomeSections();
}
