import 'package:flutter/material.dart';
import 'base_page.dart';

class ListrikPage extends StatelessWidget {
  const ListrikPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Pembayaran Listrik',
      child: Column(
        children: [
          const TextField(
            decoration: InputDecoration(
              labelText: 'Nomor Meter/ID Pelanggan',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Nominal',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: '20000', child: Text('Token 20.000')),
              DropdownMenuItem(value: '50000', child: Text('Token 50.000')),
              DropdownMenuItem(value: '100000', child: Text('Token 100.000')),
              DropdownMenuItem(value: '200000', child: Text('Token 200.000')),
            ],
            onChanged: (value) {},
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Implement electricity payment logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pembayaran listrik berhasil!')),
              );
              Navigator.pop(context);
            },
            child: const Text('Bayar'),
          ),
        ],
      ),
    );
  }
}
