import 'dart:ui';

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
  int _value = 500;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
              backgroundColor: Colors.black,
              child: const Icon(
                Icons.remove,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _value--;
                });
              }),
          InkWell(
            onTap: () {
              setState(() {
                _value++;
              });
            },
            child: SizedBox(
              width: 256,
              height: 256,
              child: TickerText(
                _value.toString(),
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 256.0,
                    fontFeatures: [FontFeature.tabularFigures()]),
                vsync: this,
              ),
            ),
          ),
          FloatingActionButton(
              backgroundColor: Colors.black,
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _value++;
                });
              }),
        ],
      ),
    );
  }
}
