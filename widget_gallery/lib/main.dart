import 'package:material_ui/material_ui.dart';

import 'lab.dart';

void main() => runApp(const LabApp('Widget Gallery', Colors.indigo, Gallery()));

class Gallery extends StatelessWidget {
  const Gallery({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LabPage(
      title: 'Widget Gallery',
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/flutter_icon.png',
                    width: 56,
                    height: 56,
                    semanticLabel: 'Flutter logo',
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Build with widgets',
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'A Row arranges the image and title. A Column stacks the content.',
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Button pressed'))),
                child: const Text('Try the button'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
