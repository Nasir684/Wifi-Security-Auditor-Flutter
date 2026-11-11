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
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: _consented 
              ? Colors.green.withOpacity(0.08) 
              : Colors.orange.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _consented 
                ? Colors.green.withOpacity(0.3) 
                : Colors.orange.withOpacity(0.3),
          ),
        ),
        child: CheckboxListTile(
          value: _consented,
          onChanged: (value) {
            final nextValue = value ?? false;
            setState(() => _consented = nextValue);
            widget.onConsentChanged(nextValue);
          },
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: Colors.green,
          title: const Text(
            'I own this network or have written permission to audit it',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          subtitle: const Text(
            'Only scan or test networks you are authorized to assess. PECA 2016 & Play Store compliant - WanaLab, Wana.',
            style: TextStyle(fontSize: 11, color: Colors.white70),
          ),
        ),
      );
}
