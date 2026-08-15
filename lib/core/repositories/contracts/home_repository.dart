import '../../domain/models/home/home_section.dart';
import '../../../core/network/api_result.dart';

abstract interface class HomeRepository {
  Future<ApiResult<List<HomeSection>>> getHomeSections();
  Future<ApiResult<void>> refresh();
}