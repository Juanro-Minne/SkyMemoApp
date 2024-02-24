import 'package:flutter/material.dart';

class TabCustom extends StatelessWidget {
  final String text;
  final EdgeInsets padding;

  const TabCustom(
      {Key? key, required this.text, this.padding = const EdgeInsets.all(10.0)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Padding(
        padding: padding,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
