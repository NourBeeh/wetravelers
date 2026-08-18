import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wetravellers/core/domain/models/home/home_section.dart';
import 'package:wetravellers/core/network/user_facing_message.dart';
import 'package:wetravellers/core/repositories/contracts/home_repository.dart';

enum HomeStatus { loading, success, empty, error, partial }

class HomeState {
  final HomeStatus status;
  final List<HomeSection> sections;
  final String? errorMessage;
  final bool isRefreshing;

  const HomeState({
    this.status = HomeStatus.loading,
    this.sections = const [],
    this.errorMessage,
    this.isRefreshing = false,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<HomeSection>? sections,
    String? errorMessage,
    bool? isRefreshing,
  }) {
    return HomeState(
      status: status ?? this.status,
      sections: sections ?? this.sections,
      errorMessage: errorMessage ?? this.errorMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

class HomeController extends StateNotifier<HomeState> {
  final HomeRepository repository;
  HomeController(this.repository) : super(const HomeState()) {
    load();
  }

  Future<void> load() async {
    if (state.sections.isEmpty) {
      state = state.copyWith(status: HomeStatus.loading);
    } else {
      state = state.copyWith(isRefreshing: true);
    }
    final result = await repository.getHomeSections();
    result.when(
      success: (sections) {
        if (sections.isEmpty) {
          state = state.copyWith(status: HomeStatus.empty, sections: [], isRefreshing: false);
        } else {
          state = state.copyWith(status: HomeStatus.success, sections: sections, isRefreshing: false);
        }
      },
      failure: (error) {
        final message = userFacingMessage(error, subject: 'home feed');
        if (state.sections.isEmpty) {
          state = state.copyWith(status: HomeStatus.error, errorMessage: message, isRefreshing: false);
        } else {
          state = state.copyWith(status: HomeStatus.partial, errorMessage: message, isRefreshing: false);
        }
      },
    );
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true);
    await repository.refresh();
    await load();
    state = state.copyWith(isRefreshing: false);
  }
}
