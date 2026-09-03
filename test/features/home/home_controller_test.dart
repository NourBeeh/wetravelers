import 'package:flutter_test/flutter_test.dart';
import 'package:wetravellers/core/domain/models/home/home_item.dart';
import 'package:wetravellers/core/domain/models/home/home_section.dart';
import 'package:wetravellers/core/domain/models/home/home_types.dart';
import 'package:wetravellers/core/network/api_result.dart';
import 'package:wetravellers/core/network/api_error.dart';
import 'package:wetravellers/core/repositories/contracts/home_repository.dart';
import 'package:wetravellers/features/home/presentation/home_controller.dart';

class FakeHomeRepo implements HomeRepository {
  ApiResult<List<HomeSection>> result;
  ApiResult<List<HomeItem>> recommendedResult;
  bool refreshed = false;
  FakeHomeRepo({
    required this.result,
    this.recommendedResult = const ApiResult.success([]),
  });
  @override
  Future<ApiResult<List<HomeSection>>> getHomeSections() async => result;
  @override
  Future<ApiResult<List<HomeItem>>> getRecommendedHotels({int limit = 6}) async =>
      recommendedResult;
  @override
  Future<ApiResult<void>> refresh() async {
    refreshed = true;
    return ApiResult.success(null);
  }
}

void main() {
  test('HomeController loads success', () async {
    final sections = [
      HomeSection(id: 's1', title: 't', layout: HomeSectionLayout.vertical, items: [])
    ];
    final repo = FakeHomeRepo(result: ApiResult.success(sections));
    final controller = HomeController(repo);
    await Future.delayed(Duration.zero);
    expect(controller.state.status, HomeStatus.success);
    expect(controller.state.sections.length, 1);
  });

  test('HomeController loads empty', () async {
    final repo = FakeHomeRepo(result: ApiResult.success([]));
    final controller = HomeController(repo);
    await Future.delayed(Duration.zero);
    expect(controller.state.status, HomeStatus.developmentPreview);
    expect(controller.state.sections, isNotEmpty);
  });

  test('HomeController loads error', () async {
    final repo = FakeHomeRepo(result: ApiResult.failure(const ApiNetworkError(message: 'err')));
    final controller = HomeController(repo);
    await Future.delayed(Duration.zero);
    expect(controller.state.status, HomeStatus.error);
    expect(controller.state.errorMessage, contains('No connection'));
    expect(controller.state.errorMessage, isNot(contains('err')));
  });

  test('HomeController refresh triggers repo refresh', () async {
    final repo = FakeHomeRepo(result: ApiResult.success([]));
    final controller = HomeController(repo);
    await controller.refresh();
    expect(repo.refreshed, true);
  });

  test('Card type selection', () {
    final item = HomeItem(id: 'i', type: HomeCardType.hotel, title: 'h');
    expect(item.type, HomeCardType.hotel);
  });

  test('Layout selection', () {
    final section = HomeSection(id: 's', title: 't', layout: HomeSectionLayout.grid, items: []);
    expect(section.layout, HomeSectionLayout.grid);
  });

  test('Malformed Home data handled', () {
    final section = HomeSection(id: '', title: '', layout: HomeSectionLayout.vertical, items: []);
    expect(section.title, '');
  });

  test('loadRecommendedHotels fills state on success', () async {
    final hotels = [
      HomeItem(id: 'h1', type: HomeCardType.hotel, title: 'Grand Cairo'),
    ];
    final repo = FakeHomeRepo(
      result: ApiResult.success([]),
      recommendedResult: ApiResult.success(hotels),
    );
    final controller = HomeController(repo);
    await Future.delayed(Duration.zero);

    expect(controller.state.recommendedHotels.length, 1);
    expect(controller.state.recommendedHotels.first.title, 'Grand Cairo');
  });

  test('loadRecommendedHotels ignores failure and empty list silently', () async {
    final repo = FakeHomeRepo(
      result: ApiResult.success([]),
      recommendedResult: const ApiResult.failure(ApiNetworkError(message: 'err')),
    );
    final controller = HomeController(repo);
    await Future.delayed(Duration.zero);
    // Failure path: state stays untouched, no error surfaced.
    expect(controller.state.recommendedHotels, isEmpty);
    expect(controller.state.errorMessage, isNull);

    final emptyRepo = FakeHomeRepo(
      result: ApiResult.success([]),
      recommendedResult: const ApiResult.success([]),
    );
    final controller2 = HomeController(emptyRepo);
    await Future.delayed(Duration.zero);
    // Empty list: also untouched (supplementary data).
    expect(controller2.state.recommendedHotels, isEmpty);
    expect(controller2.state.errorMessage, isNull);
  });
}
