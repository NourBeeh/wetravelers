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
  bool refreshed = false;
  FakeHomeRepo({required this.result});
  @override
  Future<ApiResult<List<HomeSection>>> getHomeSections() async => result;
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
    expect(controller.state.status, HomeStatus.empty);
  });

  test('HomeController loads error', () async {
    final repo = FakeHomeRepo(result: ApiResult.failure(const ApiNetworkError(message: 'err')));
    final controller = HomeController(repo);
    await Future.delayed(Duration.zero);
    expect(controller.state.status, HomeStatus.error);
    expect(controller.state.errorMessage, contains('err'));
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
}
