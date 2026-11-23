import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';

import 'lab.dart';

void main() =>
    runApp(const LabApp('Random Quotes', Colors.deepPurple, QuotePage()));

class Quote {
  const Quote(this.text, this.author, this.fromZenQuotes);

  factory Quote.fromPayload(Object? payload) {
    if (payload is List && payload.isNotEmpty) {
      final item = payload.first as Map<String, dynamic>;
      return Quote(item['q'] as String, item['a'] as String, true);
    }
    final item = payload as Map<String, dynamic>;
    return Quote(item['quote'] as String, item['author'] as String, false);
  }

  final String text;
  final String author;
  final bool fromZenQuotes;
}

class QuoteController extends GetxController {
  final quote = Rxn<Quote>();
  final loading = false.obs;
  final failed = false.obs;
  final client = http.Client();

  @override
  void onInit() {
    super.onInit();
    refreshQuote();
  }

  @override
  void onClose() {
    client.close();
    super.onClose();
  }

  Future<void> refreshQuote() async {
    if (loading.value) return;
    loading.value = true;
    failed.value = false;
    try {
      const endpoint = String.fromEnvironment(
        'QUOTE_URL',
        defaultValue: kIsWeb
            ? 'https://dummyjson.com/quotes/random'
            : 'https://zenquotes.io/api/random',
      );
      final response = await client
          .get(Uri.parse(endpoint))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        throw const FormatException('Unexpected response');
      }
      quote.value = Quote.fromPayload(
        jsonDecode(utf8.decode(response.bodyBytes)),
      );
    } catch (_) {
      failed.value = true;
    } finally {
      loading.value = false;
    }
  }
}

class QuotePage extends StatefulWidget {
  const QuotePage({super.key});

  @override
  State<QuotePage> createState() => _QuotePageState();
}

class _QuotePageState extends State<QuotePage> {
  final controller = Get.put(QuoteController());

  @override
  void dispose() {
    Get.delete<QuoteController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final quote = controller.quote.value;
      final loading = controller.loading.value;
      return LabPage(
        title: 'Random Quotes',
        children: [
          if (loading) const LinearProgressIndicator(),
          if (controller.failed.value)
            const MessageCard(
              'Could not load a quote. Check your connection and try again.',
            ),
          if (quote != null)
            Card(
              color: theme.colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.format_quote),
                    const SizedBox(height: 16),
                    Text(quote.text, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 16),
                    Text(quote.author, style: theme.textTheme.labelLarge),
                    if (quote.fromZenQuotes)
                      Text(
                        'Quotes provided by ZenQuotes.io',
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            ),
          FilledButton(
            onPressed: loading ? null : controller.refreshQuote,
            child: const Text('New quote'),
          ),
        ],
      );
    });
  }
}
