import 'dart:math';

import 'package:material_ui/material_ui.dart';

import 'lab.dart';

void main() => runApp(const LabApp('Color Mixer', Colors.teal, ColorMixer()));

class ColorMixer extends StatefulWidget {
  const ColorMixer({super.key});

  @override
  State<ColorMixer> createState() => _ColorMixerState();
}

class _ColorMixerState extends State<ColorMixer> {
  static const initialColor = Color(0xff14665f);
  final random = Random();
  Color color = initialColor;

  void shuffle() {
    setState(() => color = Color(0xff000000 | random.nextInt(0x1000000)));
  }

  @override
  Widget build(BuildContext context) {
    final luminance = color.computeLuminance();
    final contrastWithWhite = 1.05 / (luminance + 0.05);
    final contrastWithBlack = (luminance + 0.05) / 0.05;
    final ink = contrastWithWhite >= contrastWithBlack
        ? Colors.white
        : Colors.black;
    final hex = (color.toARGB32() & 0xffffff)
        .toRadixString(16)
        .padLeft(6, '0')
        .toUpperCase();

    return LabPage(
      title: 'Color Mixer',
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 210),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            '#$hex',
            style: TextStyle(
              color: ink,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        FilledButton.icon(
          onPressed: shuffle,
          icon: const Icon(Icons.shuffle),
          label: const Text('Random color'),
        ),
        TextButton(
          onPressed: () => setState(() => color = initialColor),
          child: const Text('Reset'),
        ),
      ],
    );
  }
}
