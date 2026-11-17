import 'package:equatable/equatable.dart';
import '../widgets/filter_dialog.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeDataRequested extends HomeEvent {
  const HomeDataRequested();
}

class HomeRefreshed extends HomeEvent {
  const HomeRefreshed();
}

class HomeCategorySelected extends HomeEvent {
  final String category;
  const HomeCategorySelected(this.category);

  @override
  List<Object?> get props => [category];
}

class HomeSearchChanged extends HomeEvent {
  final String query;
  const HomeSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class HomeFilterApplied extends HomeEvent {
  final String category;
  final ServiceSortOption sortOption;

  const HomeFilterApplied({required this.category, required this.sortOption});

  @override
  List<Object?> get props => [category, sortOption];
}

class HomeFilterReset extends HomeEvent {
  const HomeFilterReset();
}
