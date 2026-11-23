import 'package:material_ui/material_ui.dart';

import 'lab.dart';

void main() => runApp(const RoutingApp());

class RoutingApp extends StatelessWidget {
  const RoutingApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Route Demo',
    theme: labTheme(Colors.deepPurple),
    initialRoute: '/',
    onGenerateRoute: (settings) {
      final arguments = settings.arguments;
      final Widget page = switch (settings.name) {
        '/' => const Splash(),
        '/login' => const Login(),
        '/dashboard' when arguments is String => Dashboard(arguments),
        _ => const LabPage(
          title: 'Page unavailable',
          children: [MessageCard('Go back and try again.')],
        ),
      };
      return MaterialPageRoute<void>(builder: (_) => page, settings: settings);
    },
  );
}

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) => LabPage(
    title: 'Route Demo',
    children: [
      const MessageCard(
        'Practice passing a username from the sign-in screen to the dashboard.',
      ),
      FilledButton(
        onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
        child: const Text('Start'),
      ),
    ],
  );
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final form = GlobalKey<FormState>();
  final username = TextEditingController();
  final password = TextEditingController();

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    super.dispose();
  }

  void signIn() {
    if (!form.currentState!.validate()) return;
    Navigator.pushReplacementNamed(
      context,
      '/dashboard',
      arguments: username.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) => LabPage(
    title: 'Demo Sign-in',
    children: [
      Form(
        key: form,
        child: Column(
          children: [
            TextFormField(
              controller: username,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? 'Enter a username' : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Demo password',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? 'Enter a demo password' : null,
              onFieldSubmitted: (_) => signIn(),
            ),
          ],
        ),
      ),
      FilledButton(onPressed: signIn, child: const Text('Open dashboard')),
      TextButton(
        onPressed: () => Navigator.push<void>(
          context,
          MaterialPageRoute(builder: (_) => const Register()),
        ),
        child: const Text('View registration'),
      ),
    ],
  );
}

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final formKey = GlobalKey<FormState>();
  String password = '';

  @override
  Widget build(BuildContext context) => LabPage(
    title: 'Demo registration',
    children: [
      Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? 'Enter a username' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Demo password',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => password = value,
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? 'Enter a demo password' : null,
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
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) Navigator.pop(context);
              },
              child: const Text('Return to sign-in'),
            ),
          ],
        ),
      ),
    ],
  );
}

class Dashboard extends StatelessWidget {
  const Dashboard(this.username, {super.key});

  final String username;

  @override
  Widget build(BuildContext context) => LabPage(
    title: 'Dashboard',
    children: [
      MessageCard('Welcome, $username!'),
      OutlinedButton(
        onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
        child: const Text('Sign out'),
      ),
    ],
  );
}
