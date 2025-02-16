import 'package:flutter/material.dart';
import 'base_page.dart';

class TransferPage extends StatelessWidget {
  const TransferPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Transfer',
      child: Column(
        children: [
          const TextField(
            decoration: InputDecoration(
              labelText: 'Nomor Rekening Tujuan',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Jumlah Transfer',
              border: OutlineInputBorder(),
              prefixText: 'Rp ',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Implement transfer logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transfer berhasil!')),
              );
              Navigator.pop(context);
            },
            child: const Text('Transfer'),
          ),
        ],
      ),
    );
  }
}
