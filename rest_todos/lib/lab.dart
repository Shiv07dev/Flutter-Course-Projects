import 'package:material_ui/material_ui.dart';

ThemeData labTheme(Color color) => ThemeData(colorSchemeSeed: color);

class LabApp extends StatelessWidget {
  const LabApp(this.title, this.color, this.home, {super.key});

  final String title;
  final Color color;
  final Widget home;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: title,
    theme: labTheme(color),
    home: home,
  );
}

class LabPage extends StatelessWidget {
  const LabPage({
    super.key,
    required this.title,
    required this.children,
    this.actions,
    this.floatingActionButton,
  });

  final String title;
  final List<Widget> children;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title), actions: actions),
    floatingActionButton: floatingActionButton,
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            itemBuilder: (_, index) => children[index],
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemCount: children.length,
          ),
        ),
      ),
    ),
  );
}

class MessageCard extends StatelessWidget {
  const MessageCard(this.message, {super.key, this.action});

  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          if (action != null) ...[const SizedBox(height: 12), action!],
        ],
      ),
    ),
  );
}

Future<bool> confirmDelete(BuildContext context, String name) async =>
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ??
    false;
