import '../../domain/models/home/home_section.dart';
import '../../domain/models/home/home_item.dart';
import '../../../core/network/api_result.dart';

abstract interface class HomeRepository {
  Future<ApiResult<List<HomeSection>>> getHomeSections();
  Future<ApiResult<List<HomeItem>>> getRecommendedHotels({int limit = 6});
  Future<ApiResult<void>> refresh();
}