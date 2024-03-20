import 'package:flutter/material.dart';
import 'package:ticker/ticker_text.dart';

void main() {
  runApp(const RenderObjectTest());
}

class RenderObjectTest extends StatelessWidget {
  const RenderObjectTest({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(child: TickingText()),
      ),
    );
  }
}

class TickingText extends StatefulWidget {
  const TickingText({super.key});

  @override
  State<TickingText> createState() => _TickingTextState();
}

class _TickingTextState extends State<TickingText>
    with SingleTickerProviderStateMixin {
  int _value = 90;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          _value++;
        });
      },
      child: TickerText(
        _value.toString(),
        style: const TextStyle(color: Colors.black, fontSize: 24.0),
        vsync: this,
      ),
    );
  }
}
