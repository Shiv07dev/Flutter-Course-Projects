import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

import 'lab.dart';

void main() =>
    runApp(const LabApp('GetX Counter', Colors.orange, CounterPage()));

class CounterController extends GetxController {
  final count = 0.obs;

  void increment() => count.value++;
  void decrement() => count.value--;
  void reset() => count.value = 0;
}

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  final controller = Get.put(CounterController());

  @override
  void dispose() {
    Get.delete<CounterController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LabPage(
    title: 'GetX Counter',
    children: [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Obx(
            () => Text(
              '${controller.count.value}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ),
        ),
      ),
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: controller.decrement,
              child: const Text('Subtract'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: controller.increment,
              child: const Text('Add'),
            ),
          ),
        ],
      ),
      TextButton(onPressed: controller.reset, child: const Text('Reset')),
    ],
  );
}
