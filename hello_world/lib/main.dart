import 'package:material_ui/material_ui.dart';

void main() => runApp(const HelloWorldApp());

class HelloWorldApp extends StatelessWidget {
  const HelloWorldApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Hello World',
    home: Scaffold(
      appBar: AppBar(title: const Text('First Flutter App')),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
          decoration: BoxDecoration(
            color: const Color(0xff14665f),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Text(
            'Hello World',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    ),
  );
}
