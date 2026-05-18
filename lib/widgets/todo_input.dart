import 'package:flutter/material.dart';

class TodoInput extends StatefulWidget {
  final void Function(String title) onAddTodo;

  const TodoInput({super.key, required this.onAddTodo});

  @override
  State<TodoInput> createState() => _TodoInputState();
}

class _TodoInputState extends State<TodoInput> {
  final TextEditingController _controller = TextEditingController();

  void _submit() {
    final title = _controller.text.trim();

    if (title.isEmpty) {
      return;
    }

    widget.onAddTodo(title);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Nouvelle tâche',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),

          const SizedBox(width: 8),

          ElevatedButton(onPressed: _submit, child: const Text('Ajouter')),
        ],
      ),
    );
  }
}
