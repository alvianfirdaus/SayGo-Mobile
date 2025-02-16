import 'package:flutter/material.dart';
import 'base_page.dart';

class TopUpPage extends StatelessWidget {
  const TopUpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<int> nominals = [10000, 20000, 50000, 100000, 200000, 500000];

    return BasePage(
      title: 'Top Up',
      child: Column(
        children: [
          const Text(
            'Pilih Nominal Top Up',
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
                    // Implement top up logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Top up Rp ${nominals[index].toString()} berhasil!'),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: Text('Rp ${nominals[index].toString()}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
