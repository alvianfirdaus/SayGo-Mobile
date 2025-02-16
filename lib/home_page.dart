import 'package:flutter/material.dart';
import 'speech_service.dart';
import 'saldo.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SpeechService _speechService = SpeechService();

  @override
  void initState() {
    super.initState();
    _speechService.setContext(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("Tekan tombol mikrofon dan ucapkan perintah.",
                style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            IconButton(
              icon:
                  Icon(_speechService.isListening ? Icons.mic : Icons.mic_none),
              onPressed: _speechService.listen,
              iconSize: 50,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const SaldoPage()));
              },
              child: const Text('Cek Saldo', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
