import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wetravellers/features/home/providers/home_providers.dart';
import 'package:wetravellers/features/home/presentation/home_controller.dart';
import 'package:wetravellers/features/home/presentation/widgets/home_section.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeControllerProvider);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(homeControllerProvider.notifier).refresh(),
        child: _buildBody(state, ref),
      ),
    );
  }

  Widget _buildBody(HomeState state, WidgetRef ref) {
    Widget content;
    switch (state.status) {
      case HomeStatus.loading:
        content = ListView.builder(
          itemCount: 6,
          itemBuilder: (_, __) => Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Container(height: 120, color: Colors.grey.shade200),
          ),
        );
        break;
      case HomeStatus.success:
      case HomeStatus.partial:
        content = ListView.builder(
          itemCount: state.sections.length,
          itemBuilder: (_, i) => HomeSectionWidget(section: state.sections[i]),
        );
        break;
      case HomeStatus.empty:
        content = Center(child: const Text('No content available'));
        break;
      case HomeStatus.error:
        content = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(state.errorMessage ?? 'Error'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.read(homeControllerProvider.notifier).load(),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
        break;
    }
    return SafeArea(
      top: true,
      bottom: false,
      child: content,
    );
  }
}
