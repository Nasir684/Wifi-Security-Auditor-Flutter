import 'package:flutter/material.dart';

class OwnerConsentGate extends StatefulWidget {
  final ValueChanged<bool> onConsentChanged;

  const OwnerConsentGate({super.key, required this.onConsentChanged});

  @override
  State<OwnerConsentGate> createState() => _OwnerConsentGateState();
}

class _OwnerConsentGateState extends State<OwnerConsentGate> {
  bool _consented = false;

  @override
  Widget build(BuildContext context) => CheckboxListTile(
        value: _consented,
        onChanged: (value) {
          final nextValue = value ?? false;
          setState(() => _consented = nextValue);
          widget.onConsentChanged(nextValue);
        },
        controlAffinity: ListTileControlAffinity.leading,
        title: const Text('I own this network or have written permission to audit it'),
        subtitle: const Text('Only scan or test networks you are authorized to assess.'),
      );
}
