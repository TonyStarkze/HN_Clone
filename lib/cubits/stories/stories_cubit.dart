import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/hn_repository.dart';
import 'stories_state.dart';

class StoriesCubit extends Cubit<StoriesState> {
  final HnRepository _repository;

  List<int> _allIds = [];
  int _loadedCount = 0;
  static const int _pageSize = 20;

  StoriesCubit(this._repository) : super(StoriesInitial());

  Future<void> loadStories() async {
    emit(StoriesLoading());
    try {
      _allIds = await _repository.getTopStoryIds();
      _loadedCount = 0;
      await _fetchNextPage(initial: true);
    } catch (e) {
      emit(StoriesError('Failed to load stories: $e'));
    }
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! StoriesLoaded) return;
    if (current.hasReachedMax || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));
    try {
      await _fetchNextPage(initial: false);
    } catch (e) {
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> refresh() async {
    await loadStories();
  }

  Future<void> _fetchNextPage({required bool initial}) async {
    final start = _loadedCount;
    final end = min(start + _pageSize, _allIds.length);
    if (start >= _allIds.length) return;

    final pageIds = _allIds.sublist(start, end);
    final newItems = await _repository.getItems(pageIds);
    _loadedCount = end;

    final existing =
        (state is StoriesLoaded && !initial) ? (state as StoriesLoaded).stories : [];
    emit(StoriesLoaded(
      stories: [...existing, ...newItems],
      hasReachedMax: end >= _allIds.length,
      isLoadingMore: false,
    ));
  }
}
