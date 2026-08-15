import 'package:flutter/material.dart';
import '../../services/transaction/transaction_service.dart';

final _txService = TransactionService();

class PayScreen extends StatefulWidget {
  const PayScreen({super.key});

  @override
  State<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  bool _creating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pay')),
      body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Pay — Create a simulated payment'),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _creating ? null : () async {
            setState(() { _creating = true; });
            final tx = await _txService.createTransaction(receiverDeviceId: 'RECEIVER-DEVICE-001', amount: 100);
            if (!mounted) return;
            setState(() { _creating = false; });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Created simulated tx ${tx.transactionId}')));
          },
          child: const Text('Create ₹100 SIMULATED PAYMENT'),
        )
      ])),
    );
  }
}
