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
  int _value = 12345;
  Animation<double>? _animation;
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller!);
    _controller?.addListener(() {
      setState(() {});
    });
    _controller?.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller?.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TickerText(
          _value.toString(),
          style: const TextStyle(color: Colors.black, fontSize: 32.0),
          verticalOffset: _animation!.value,
        ),
        ElevatedButton(
            onPressed: () {
              setState(() {
                _value++;
                _controller?.forward();
              });
            },
            child: Text('data')),
      ],
    );
  }
}
