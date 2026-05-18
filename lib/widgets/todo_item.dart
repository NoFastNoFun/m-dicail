import 'package:flutter/material.dart';
import '../models/todo.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(value: todo.isDone, onChanged: (_) => onToggle()),
      title: Text(
        todo.title,
        style: TextStyle(
          decoration: todo.isDone
              ? TextDecoration.lineThrough
              : TextDecoration.none,
        ),
      ),
      trailing: IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
    );
  }
}
