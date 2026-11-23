import 'dart:io';

String greet(String name) => 'Hello, $name!';

void main() {
  const name = 'Flutter learner';
  final topics = <String>['widgets', 'layouts', 'state'];
  stdout.writeln(greet(name));
  for (final topic in topics) {
    stdout.writeln('Practice $topic');
  }
}
