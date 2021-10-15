import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:login_with_firebase_bloc/app/app.dart';
import 'package:login_with_firebase_bloc/home/home.dart';
import 'package:login_with_firebase_bloc/home/view/add_edit_sceen.dart';
import 'package:login_with_firebase_bloc/todos/todos.dart';
import 'package:todos_repository/todos_repository.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  static Page page() => const MaterialPage<void>(child: HomePage());

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);

    return BlocProvider<TodosBloc>(
      create: (_) => TodosBloc(
        todosRepository: FirebaseTodosRepository(user.id),
      )..add(LoadTodos()),
      child: Builder(
        builder: (context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<TabBloc>(
                create: (_) => TabBloc(),
              ),
              BlocProvider<FilteredTodosBloc>(
                create: (_) => FilteredTodosBloc(
                    todosBloc: context.read<TodosBloc>()
                ),
              ),
              BlocProvider<StatsBloc>(
                create: (_) => StatsBloc(
                  todosBloc: context.read<TodosBloc>(),
                ),
              ),
            ],
            child: HomeScreen(),
          );
        },
      )
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TabBloc, AppTab>(
      builder: (context, activeTab) {
        return  Scaffold(
          appBar: AppBar(
            title: const Text('Todo-List'),
            actions: <Widget>[
              FilterButton(visible: activeTab == AppTab.todos),
              ExtraActions(),
            ],
          ),
          drawer: const _Drawer(),
          body: activeTab == AppTab.todos ? FilteredTodos() : Stats(),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_){
                return AddEditScreen(
                    onSave: (task, note) {
                      context
                          .read<TodosBloc>()
                          .add(AddTodo(Todo(task: task, note: note)));
                    },
                    isEditing: false
                );
                }
              ));
            },
            child: const Icon(Icons.add),
            tooltip: 'Add Todo',
          ),
          bottomNavigationBar: TabSelector(
            activeTab: activeTab,
            onTabSelected: (tab) => context.read<TabBloc>().add(UpdateTab(tab)),
          ),
        );
      },
    );
  }
}


class _Drawer extends StatelessWidget {

  const _Drawer({Key? key}) :  super(key: key);

  @override

  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final user = context.select((AppBloc bloc) => bloc.state.user);
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.teal.shade200,
                  Colors.teal.shade400,
                ],
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Avatar(photo: user.photo),
                const SizedBox(width: 10,),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(height: 4),
                    Text(user.email ?? '', style: textTheme.subtitle2),
                    const SizedBox(height: 4),
                    Text(user.name ?? '', style: textTheme.subtitle1),
                  ],
                ),
              ],
            ),
          ),
          ListTile(
            key: const Key('homePage_logout_button'),
            leading: const Icon(Icons.exit_to_app),
            title: Text('LOGOUT', style: textTheme.headline6),
            onTap: () => context.read<AppBloc>().add(AppLogoutRequested()),
          )
        ],
      ),
    );
  }
}
