import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:wetravellers/features/ai/application/ai_state.dart';
import 'package:wetravellers/features/ai/presentation/widgets/ai_bottom_sheet.dart'
    show aiSheetControllerProvider;
import 'package:wetravellers/features/universal_search/application/universal_search_controller.dart';
import 'package:wetravellers/features/universal_search/application/universal_search_state.dart';
import 'package:wetravellers/features/universal_search/presentation/widgets/universal_search_widgets.dart';

/// The Universal Search + AI surface (US-1) — evolved from the v1 smart
/// search page into the full US-0 contract: a state-machine-driven
/// full-screen search experience with recents, categories, live
/// suggestions, structured-intent results rendered through the existing
/// card system, AI narrative results and intent-patch follow-ups.
///
/// The controller owns ALL state — this page is a pure renderer:
/// recents, suggestions, query preservation and phases all come from
/// `universalSearchControllerProvider`.
class UniversalSearchPage extends ConsumerStatefulWidget {
  const UniversalSearchPage({super.key});

  @override
  ConsumerState<UniversalSearchPage> createState() =>
      _UniversalSearchPageState();
}

class _UniversalSearchPageState extends ConsumerState<UniversalSearchPage> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final controller =
        ref.read(universalSearchControllerProvider.notifier);
    // The route scope owns the OPENING phase: a fresh autoDispose machine
    // is born on every push of /smart-search. First restore the preserved
    // query (US-1 STEP 8) — if present, the machine reopens into TYPING.
    controller
        .restorePreservedQuery()
        .then((preserved) {
      if (!mounted) return;
      if (preserved.isNotEmpty && controller.currentState.query.isEmpty) {
        controller.onQueryChanged(preserved);
      }
      _seedFieldAndOpen(controller);
    });
  }

  void _seedFieldAndOpen(UniversalSearchController controller) {
    controller.open();
    _inputController.text = controller.currentState.query;
    _inputController.addListener(_onFieldChanged);
    controller.surfaceReady();
    controller.loadRecents();
    // Focus together with the hero flight departure: the caret and the
    // keyboard rise while the container is still morphing — the instant
    // responsiveness of the native search experiences (US-1 STEP 6).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _inputController.removeListener(_onFieldChanged);
    _inputController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    ref
        .read(universalSearchControllerProvider.notifier)
        .onQueryChanged(_inputController.text);
  }

  void _submit() {
    final controller =
        ref.read(universalSearchControllerProvider.notifier);
    final text = controller.currentState.query.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    _focusNode.unfocus();
    // Recents update ONLY on submit (US-1 STEP 9) — typing never records.
    controller.recordRecent(text);
    controller.submit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  void _applySuggestion(String suggestion) {
    _inputController.text = suggestion;
    _inputController.selection = TextSelection.collapsed(
      offset: suggestion.length,
    );
    _submit();
  }

  void _clearInput() {
    _inputController.clear();
    _focusNode.requestFocus();
  }

  /// Closing always preserves the query (US-1 STEP 7/8): the field keeps
  /// its text — the controller state is the survival mechanism.
  void _close() {
    final controller = ref.read(universalSearchControllerProvider.notifier);
    controller.close();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final state = ref.watch(universalSearchControllerProvider);

    // The AI flow rides the established shared sheet controller (keyed by
    // prompt). When it lands, its sections are handed to the universal
    // controller — the single source of truth for rendering (US-1 STEP 19).
    if (state.phase == UniversalSearchPhase.searching && state.aiInterpreting) {
      final prompt = state.query.trim();
      final args = (prompt: prompt, context: null);
      final aiState = ref.watch(aiSheetControllerProvider(args));
      final notifier =
          ref.read(universalSearchControllerProvider.notifier);
      switch (aiState.status) {
        case AiStatus.success:
          notifier.aiResultsReady(
            aiState.sections,
            aiState.responseText,
          );
        case AiStatus.error:
        case AiStatus.empty:
          notifier.aiResultsFailed();
        case AiStatus.loading:
        case AiStatus.idle:
          break;
      }
    }

    return PopScope(
      // Keyboard-first back (US-1 STEP 22): while the field holds focus,
      // back dismisses the keyboard only; the second back closes.
      canPop: !_focusNode.hasFocus,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _focusNode.unfocus();
        } else {
          ref
              .read(universalSearchControllerProvider.notifier)
              .surfaceClosed();
        }
      },
      child: Scaffold(
        backgroundColor: scheme.surface,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: <Widget>[
              UniversalSearchHeader(
                controller: _inputController,
                focusNode: _focusNode,
                hasText: state.query.trim().isNotEmpty,
                onBack: _close,
                onClear: _clearInput,
                onSubmit: _submit,
              ),
              Divider(
                height: 1,
                color: scheme.outlineVariant.withValues(alpha: 0.4),
              ),
              Expanded(child: _buildBody(state)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(UniversalSearchState state) {
    // US-2 §3: an incomplete-but-valid intent parks with question chips —
    // visible in every non-searching phase while gaps remain.
    if (state.intentGaps.isNotEmpty &&
        state.phase != UniversalSearchPhase.searching) {
      return UniversalSearchGapsBody(
        state: state,
        onGapAnswered: (patched) => ref
            .read(universalSearchControllerProvider.notifier)
            .fillGap(patched),
      );
    }
    switch (state.phase) {
      case UniversalSearchPhase.active:
      case UniversalSearchPhase.typing:
      case UniversalSearchPhase.opening:
        return UniversalSearchSuggestionsBody(
          state: state,
          onSuggestionTap: _applySuggestion,
          onRecentTap: _applySuggestion,
          onRecentDismiss: (index) => ref
              .read(universalSearchControllerProvider.notifier)
              .removeRecentAt(index),
          onClearRecents: () => ref
              .read(universalSearchControllerProvider.notifier)
              .clearRecents(),
          onCategoryTap: (route) {
            // Category chips leave Universal Search to the vertical page —
            // an explicit exit, never a search request (US-1 STEP 11).
            context.go(route);
          },
        );
      case UniversalSearchPhase.searching:
        return const UniversalSearchLoadingBody(aiInterpreting: false);
      case UniversalSearchPhase.results:
      case UniversalSearchPhase.aiResult:
        return UniversalSearchResultsBody(
          state: state,
          scrollController: _scrollController,
          onEditQuery: () {
            _focusNode.requestFocus();
          },
          onFollowUp: (action) => ref
              .read(universalSearchControllerProvider.notifier)
              .applyFollowUp(action),
          onRetry: () => _submit(),
        );
      case UniversalSearchPhase.closed:
      case UniversalSearchPhase.closing:
        return const SizedBox.shrink();
    }
  }
}
