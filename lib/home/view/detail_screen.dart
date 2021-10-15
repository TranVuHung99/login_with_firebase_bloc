import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:login_with_firebase_bloc/home/view/view.dart';
import 'package:login_with_firebase_bloc/todos/todos.dart';


class DetailsScreen extends StatelessWidget {
  final String id;
  final TodosBloc todosBloc;
  const DetailsScreen({Key? key, required this.id, required this.todosBloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return BlocBuilder<TodosBloc, TodosState>(
      bloc: todosBloc,
      builder: (context, state) {
        if (state is! TodosLoaded) {
          throw StateError('Cannot render details without a valid todo');
        }
        final todo = state.todos.firstWhere(
                (todo) => todo.id == id);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Todo Details'),
            actions: [
              IconButton(
                tooltip: 'Delete Todo',
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  Navigator.of(context).pop(todo);
                  await Future.delayed(const Duration(milliseconds: 300));
                  todosBloc.add(DeleteTodo(todo));
                },
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Checkbox(
                        value: todo.complete,
                        onChanged: (_) {
                            todosBloc.add(UpdateTodo(todo.copyWith(
                            complete: todo.complete == false,
                          )));
                        },
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Hero(
                            tag: '${todo.id}__heroTag',
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.only(
                                top: 8.0,
                                bottom: 16.0,
                              ),
                              child: Text(
                                todo.task,
                                style: Theme.of(context).textTheme.headline5,
                              ),
                            ),
                          ),
                          Text(
                            todo.note,
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            tooltip: 'Edit Todo',
            child: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return AddEditScreen(
                      onSave: (task, note) {
                          todosBloc.add(
                          UpdateTodo(todo.copyWith(task: task, note: note)),
                        );
                      },
                      isEditing: true,
                      todo: todo,
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}