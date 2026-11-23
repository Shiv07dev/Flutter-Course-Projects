import 'package:material_ui/material_ui.dart';

import 'lab.dart';

void main() =>
    runApp(const LabApp('Registration Form', Colors.blue, ProfileForm()));

class ProfileForm extends StatefulWidget {
  const ProfileForm({super.key});

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final form = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String password = '';
  String track = 'Flutter';
  ({String name, String email, String track})? profile;

  void submit() {
    final state = form.currentState!;
    if (!state.validate()) return;
    state.save();
    FocusScope.of(context).unfocus();
    setState(() => profile = (name: name, email: email, track: track));
  }

  @override
  Widget build(BuildContext context) => LabPage(
    title: 'Registration Form',
    children: [
      Form(
        key: form,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: (value) => (value ?? '').trim().length < 2
                  ? 'Enter at least two characters'
                  : null,
              onSaved: (value) => name = value!.trim(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) =>
                  RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                      .hasMatch((value ?? '').trim())
                  ? null
                  : 'Enter a valid email address',
              onSaved: (value) => email = value!.trim(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Demo password',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => password = value,
              validator: (value) => (value ?? '').length < 6
                  ? 'Enter at least six characters'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm demo password',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value != password ? 'Passwords must match' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: track,
              decoration: const InputDecoration(
                labelText: 'Learning track',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Flutter', child: Text('Flutter')),
                DropdownMenuItem(value: 'Dart', child: Text('Dart')),
              ],
              onChanged: (value) => track = value ?? 'Flutter',
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: submit, child: const Text('Save profile')),
          ],
        ),
      ),
      if (profile case final saved?)
        Card(
          child: ListTile(
            title: Text(saved.name),
            subtitle: Text('${saved.email}\n${saved.track}'),
          ),
        ),
    ],
  );
}
