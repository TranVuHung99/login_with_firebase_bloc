import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:login_with_firebase_bloc/todos/todos.dart';
import 'package:meta/meta.dart';
import 'package:todos_repository/todos_repository.dart';

part 'stat_event.dart';
part 'stat_state.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  late StreamSubscription _todosSubscription;

  StatsBloc({required TodosBloc todosBloc}) : super(StatsLoading()) {
    on<StatsUpdated>(_onStatsUpdated);
    final todosState = todosBloc.state;
    if (todosState is TodosLoaded) add(StatsUpdated(todosState.todos));
    _todosSubscription = todosBloc.stream.listen((state) {
      if (state is TodosLoaded) {
        add(StatsUpdated(state.todos));
      }
    });
  }

  void _onStatsUpdated(StatsUpdated event, Emitter<StatsState> emit) async {
    final numActive =
        event.todos.where((todo) => !todo.complete).toList().length;
    final numCompleted =
        event.todos.where((todo) => todo.complete).toList().length;
    emit(StatsLoaded(numActive, numCompleted));
  }

  @override
  Future<void> close() {
    _todosSubscription.cancel();
    return super.close();
  }
}
