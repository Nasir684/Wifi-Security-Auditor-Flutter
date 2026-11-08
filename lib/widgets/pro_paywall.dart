import 'package:flutter/material.dart';

class ProPaywall extends StatelessWidget {
  const ProPaywall({super.key});

  @override
  Widget build(BuildContext context) => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('WanaLab Pro', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Pro subscription purchasing is not configured yet.'),
            ],
          ),
        ),
      );
}
