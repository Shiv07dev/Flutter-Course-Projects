import 'dart:async';

import 'package:material_ui/material_ui.dart';

import 'lab.dart';
import 'users_store.dart';

void main() =>
    runApp(const LabApp('Firestore Users', Colors.deepOrange, UsersPage()));

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  UsersStore? store;
  StreamSubscription<List<CourseUser>>? subscription;
  List<CourseUser> users = [];
  bool live = true;
  bool busy = false;
  String? error;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  Future<void> refresh() async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await subscription?.cancel();
      subscription = null;
      final database = store ??= await UsersStore.connect();
      final firstRead = await database.readOnce().timeout(
        const Duration(seconds: 8),
      );
      if (!mounted) return;
      setState(() => users = firstRead);
      if (live) {
        subscription = database.watch().listen(
          (rows) {
            if (mounted) {
              setState(() {
                users = rows;
                error = null;
              });
            }
          },
          onError: (Object _) {
            if (mounted) {
              setState(
                () => error = 'Live updates ended. Refresh to reconnect.',
              );
            }
          },
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => error = 'Could not reach Firestore. Start the local emulator, then refresh.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> write(Future<void> Function() change) async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await change().timeout(const Duration(seconds: 8));
      if (!live || subscription == null) {
        final rows = await store!.readOnce().timeout(
          const Duration(seconds: 8),
        );
        if (mounted) setState(() => users = rows);
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => error =
              'Could not confirm the change. Refresh the list before retrying.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> edit([CourseUser? user]) async {
    final form = GlobalKey<FormState>();
    var name = '';
    var city = '';
    final updated = await showDialog<CourseUser>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(user == null ? 'Add user' : 'Edit user'),
        scrollable: true,
        content: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: user?.name,
                decoration: const InputDecoration(labelText: 'Name'),
                textCapitalization: TextCapitalization.words,
                maxLength: 80,
                validator: (value) =>
                    (value ?? '').trim().isEmpty ? 'Enter a name' : null,
                onSaved: (value) => name = value!.trim(),
              ),
              TextFormField(
                initialValue: user?.city,
                decoration: const InputDecoration(labelText: 'City'),
                textCapitalization: TextCapitalization.words,
                maxLength: 150,
                validator: (value) =>
                    (value ?? '').trim().isEmpty ? 'Enter a city' : null,
                onSaved: (value) => city = value!.trim(),
              ),
            ],
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
              Navigator.pop(
                dialogContext,
                CourseUser(id: user?.id, name: name, city: city),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (mounted && updated != null) await write(() => store!.save(updated));
  }

  Future<void> remove(CourseUser user) async {
    if (await confirmDelete(context, user.name) && mounted) {
      await write(() => store!.delete(user.id!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final canWrite = store != null && !busy && error == null;
    return LabPage(
      title: 'Firestore Users',
      actions: [
        IconButton(
          tooltip: 'Read users once',
          onPressed: busy ? null : refresh,
          icon: const Icon(Icons.refresh),
        ),
      ],
      floatingActionButton: canWrite
          ? FloatingActionButton.extended(
              onPressed: () => edit(),
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Add user'),
            )
          : null,
      children: [
        Card(
          child: SwitchListTile(
            title: const Text('Live updates'),
            subtitle: Text(
              live
                  ? 'Listen to collection changes'
                  : 'Fetch a snapshot with Refresh',
            ),
            value: live,
            onChanged: busy
                ? null
                : (value) {
                    setState(() => live = value);
                    refresh();
                  },
          ),
        ),
        if (busy) const LinearProgressIndicator(),
        if (error case final message?) MessageCard(message),
        if (users.isEmpty && canWrite)
          const MessageCard(
            'Add a sample user to the local Firestore collection.',
          ),
        for (final user in users)
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(user.name),
              subtitle: Text(user.city),
              onTap: canWrite ? () => edit(user) : null,
              trailing: IconButton(
                tooltip: 'Delete user',
                onPressed: canWrite ? () => remove(user) : null,
                icon: const Icon(Icons.delete_outline),
              ),
            ),
          ),
      ],
    );
  }
}
