import 'package:flutter_test/flutter_test.dart';
import 'package:random_quotes/main.dart';

void main() {
  test('ZenQuotes and the browser provider decode to the same model', () {
    const first = [
      {'q': 'Practice every day.', 'a': 'Sample author', 'h': '<p>Example</p>'},
    ];
    const second = {'quote': 'Practice every day.', 'author': 'Sample author'};
    final native = Quote.fromPayload(first);
    final web = Quote.fromPayload(second);
    expect(native.text, web.text);
    expect(native.author, web.author);
    expect(native.fromZenQuotes, isTrue);
    expect(web.fromZenQuotes, isFalse);
  });
}
