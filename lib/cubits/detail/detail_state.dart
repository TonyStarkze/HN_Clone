import 'package:equatable/equatable.dart';
import '../../models/hn_item.dart';

abstract class DetailState extends Equatable {
  const DetailState();

  @override
  List<Object?> get props => [];
}

class DetailInitial extends DetailState {}

class DetailLoading extends DetailState {}

class DetailLoaded extends DetailState {
  final HnItem story;
  final List<HnItem> topComments;

  const DetailLoaded({
    required this.story,
    required this.topComments,
  });

  @override
  List<Object?> get props => [story, topComments];
}

class DetailError extends DetailState {
  final String message;

  const DetailError(this.message);

  @override
  List<Object?> get props => [message];
}
