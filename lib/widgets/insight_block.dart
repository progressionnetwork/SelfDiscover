import 'package:flutter/material.dart';
import 'package:self_discover/models/insight.dart';

class InsightBlock extends StatelessWidget {
  final Insight insight;
  final VoidCallback onTap;

  InsightBlock({required this.insight, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(insight.title),
        subtitle: Text(insight.content),
        onTap: onTap,
      ),
    );
  }
}
