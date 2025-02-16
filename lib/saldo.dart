import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class SaldoPage extends StatefulWidget {
  const SaldoPage({super.key});

  @override
  State<SaldoPage> createState() => _SaldoPageState();
}

class _SaldoPageState extends State<SaldoPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref('users/02');
  String nama = "";
  String nomorRekening = "";
  double saldo = 0.0;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    final snapshot = await _database.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map;
      setState(() {
        nama = data['nama'] ?? '';
        nomorRekening = data['norek'] ?? '';
        saldo = double.tryParse(data['saldo'].toString()) ?? 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saldo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Nama: $nama", style: const TextStyle(fontSize: 20)),
            Text("Nomor Rekening: $nomorRekening",
                style: const TextStyle(fontSize: 20)),
            Text("Saldo: Rp. $saldo", style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
