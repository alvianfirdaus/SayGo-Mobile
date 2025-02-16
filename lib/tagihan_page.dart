import 'package:flutter/material.dart';
import 'base_page.dart';

class TagihanPage extends StatelessWidget {
  const TagihanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Pembayaran Tagihan',
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Jenis Tagihan',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'air', child: Text('PDAM')),
              DropdownMenuItem(value: 'internet', child: Text('Internet')),
              DropdownMenuItem(value: 'tv', child: Text('TV Kabel')),
            ],
            onChanged: (value) {},
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Nomor Pelanggan',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Implement bill payment logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pembayaran tagihan berhasil!')),
              );
              Navigator.pop(context);
            },
            child: const Text('Bayar Tagihan'),
          ),
        ],
      ),
    );
  }
}
