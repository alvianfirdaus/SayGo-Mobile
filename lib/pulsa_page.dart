import 'package:flutter/material.dart';
import 'base_page.dart';

class PulsaPage extends StatelessWidget {
  const PulsaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<int> nominals = [5000, 10000, 20000, 50000, 100000];

    return BasePage(
      title: 'Isi Pulsa',
      child: Column(
        children: [
          const TextField(
            decoration: InputDecoration(
              labelText: 'Nomor Telepon',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          const Text(
            'Pilih Nominal',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: nominals.length,
              itemBuilder: (context, index) {
                return ElevatedButton(
                  onPressed: () {
                    // Implement pulsa purchase logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Pembelian pulsa Rp ${nominals[index]} berhasil!'),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: Text('Rp ${nominals[index]}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
