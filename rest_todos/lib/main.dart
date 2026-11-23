import 'package:material_ui/material_ui.dart';

import 'lab.dart';
import 'todo_api.dart';

void main() => runApp(const LabApp('REST Todos', Colors.indigo, TodoPage()));

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final api = TodoApi();
  List<Todo> todos = [];
  bool busy = false;
  bool failed = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    api.close();
    super.dispose();
  }

  Future<void> load([Future<void> Function()? change]) async {
    if (busy) return;
    setState(() {
      busy = true;
      failed = false;
    });
    try {
      if (change != null) await change();
      final updated = await api.readAll();
      if (mounted) setState(() => todos = updated);
    } catch (_) {
      if (mounted) setState(() => failed = true);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> edit([Todo? todo]) async {
    final form = GlobalKey<FormState>();
    var title = '';
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(todo == null ? 'New task' : 'Rename task'),
        content: Form(
          key: form,
          child: TextFormField(
            autofocus: true,
            initialValue: todo?.title,
            decoration: const InputDecoration(labelText: 'Task title'),
            maxLength: 100,
            validator: (value) =>
                (value ?? '').trim().isEmpty ? 'Enter a task title' : null,
            onSaved: (value) => title = value!.trim(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final state = form.currentState!;
              if (!state.validate()) return;
              state.save();
              Navigator.pop(dialogContext, title);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (!mounted || result == null) return;
    await load(
      () => todo == null ? api.create(result) : api.update(todo, title: result),
    );
  }

  Future<void> remove(Todo todo) async {
    if (await confirmDelete(context, todo.title) && mounted) {
      await load(() => api.delete(todo.id));
    }
  }

  @override
  Widget build(BuildContext context) => LabPage(
    title: 'REST Todos',
    actions: [
      IconButton(
        tooltip: 'Refresh tasks',
        onPressed: busy ? null : () => load(),
        icon: const Icon(Icons.refresh),
      ),
    ],
    floatingActionButton: busy
        ? null
        : FloatingActionButton.extended(
            onPressed: () => edit(),
            icon: const Icon(Icons.add),
            label: const Text('New task'),
          ),
    children: [
      if (busy) const LinearProgressIndicator(),
      if (failed)
        MessageCard(
          'The request failed. Check that the course API is running, then refresh the task list.',
          action: OutlinedButton(
            onPressed: () => load(),
            child: const Text('Refresh'),
          ),
        ),
      if (!busy && !failed && todos.isEmpty)
        const MessageCard('Your list is empty. Add a task to get started.'),
      for (final todo in todos)
        Card(
          child: ListTile(
            leading: Checkbox(
              semanticLabel: 'Complete ${todo.title}',
              value: todo.completed,
              onChanged: busy
                  ? null
                  : (value) => load(() => api.update(todo, completed: value)),
            ),
            title: Text(
              todo.title,
              style: TextStyle(
                decoration: todo.completed ? TextDecoration.lineThrough : null,
              ),
            ),
            onTap: busy ? null : () => edit(todo),
            trailing: IconButton(
              tooltip: 'Delete task',
              onPressed: busy ? null : () => remove(todo),
              icon: const Icon(Icons.delete_outline),
            ),
          ),
        ),
    ],
  );
}
