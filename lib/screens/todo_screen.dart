import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../widgets/todo_input.dart';
import '../widgets/todo_item.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final List<Todo> _todos = [];

  void _addTodo(String title) {
    final newTodo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
    );

    setState(() {
      _todos.add(newTodo);
    });
  }

  void _toggleTodo(String id) {
    setState(() {
      final index = _todos.indexWhere((todo) => todo.id == id);

      if (index != -1) {
        final todo = _todos[index];

        _todos[index] = todo.copyWith(isDone: !todo.isDone);
      }
    });
  }

  void _deleteTodo(String id) {
    setState(() {
      _todos.removeWhere((todo) => todo.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo List')),
      body: Column(
        children: [
          TodoInput(onAddTodo: _addTodo),

          Expanded(
            child: ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                final todo = _todos[index];

                return TodoItem(
                  todo: todo,
                  onToggle: () => _toggleTodo(todo.id),
                  onDelete: () => _deleteTodo(todo.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
