import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/hn_item.dart';
import '../../repositories/hn_repository.dart';
import 'detail_state.dart';

class DetailCubit extends Cubit<DetailState> {
  final HnRepository _repository;

  DetailCubit(this._repository) : super(DetailInitial());

  Future<void> loadDetail(HnItem story) async {
    emit(DetailLoading());
    try {
      // Fetch up to 20 top-level comments concurrently
      final commentIds = story.kids.take(20).toList();
      final comments = await _repository.getItems(commentIds);
      emit(DetailLoaded(story: story, topComments: comments));
    } catch (e) {
      emit(DetailError('Failed to load comments: $e'));
    }
  }
}
