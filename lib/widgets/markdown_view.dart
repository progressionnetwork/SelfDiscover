import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownView extends StatelessWidget {
  final String data;

  MarkdownView({required this.data});

  @override
  Widget build(BuildContext context) {
    return Markdown(
      data: data,
    );
  }
}
