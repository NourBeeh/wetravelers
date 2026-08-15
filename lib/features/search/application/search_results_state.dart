enum SearchResultState { idle, loading, success, empty, error }

class SearchResultsState<T> {
  final SearchResultState state;
  final List<T> items;
  final String? errorMessage;
  final List<String> providerWarnings;

  const SearchResultsState({
    this.state = SearchResultState.idle,
    this.items = const [],
    this.errorMessage,
    this.providerWarnings = const [],
  });

  SearchResultsState<T> copyWith({
    SearchResultState? state,
    List<T>? items,
    String? errorMessage,
    List<String>? providerWarnings,
  }) {
    return SearchResultsState<T>(
      state: state ?? this.state,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
      providerWarnings: providerWarnings ?? this.providerWarnings,
    );
  }
}
