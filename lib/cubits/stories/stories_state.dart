import 'package:equatable/equatable.dart';
import '../../models/hn_item.dart';

abstract class StoriesState extends Equatable {
  const StoriesState();

  @override
  List<Object?> get props => [];
}

class StoriesInitial extends StoriesState {}

class StoriesLoading extends StoriesState {}

class StoriesLoaded extends StoriesState {
  final List<HnItem> stories;
  final bool hasReachedMax;
  final bool isLoadingMore;

  const StoriesLoaded({
    required this.stories,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

  StoriesLoaded copyWith({
    List<HnItem>? stories,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return StoriesLoaded(
      stories: stories ?? this.stories,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [stories, hasReachedMax, isLoadingMore];
}

class StoriesError extends StoriesState {
  final String message;

  const StoriesError(this.message);

  @override
  List<Object?> get props => [message];
}
