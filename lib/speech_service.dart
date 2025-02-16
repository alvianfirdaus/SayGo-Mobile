import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

// Import your pages
import 'saldo.dart';
import 'transfer_page.dart';
import 'topup_page.dart';
import 'listrik_page.dart';
import 'tagihan_page.dart';
import 'pulsa_page.dart';

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool isListening = false;
  late BuildContext _context;
  bool waitingForConfirmation = false;
  String? _lastPredictedLabel;
  bool _manualStop = false;

  // Singleton pattern
  static final SpeechService _instance = SpeechService._internal();

  factory SpeechService() {
    return _instance;
  }

  SpeechService._internal() {
    _configureTts();
  }

  Future<void> _configureTts() async {
    await _flutterTts.setLanguage("id-ID");
    await _flutterTts.setSpeechRate(0.6);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      if (waitingForConfirmation) {
        // Resume listening after TTS completes
        listen();
      }
    });
  }

  void setContext(BuildContext context) {
    _context = context;
  }

  Future<void> _showListeningPopup() async {
    if (!_context.mounted) return;

    showDialog(
      context: _context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Mendengarkan...",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          _manualStop = true; // Set flag when X is clicked
                          _stopListening();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Silakan ucapkan perintah...",
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _hideListeningPopup() {
    if (_context.mounted && Navigator.canPop(_context)) {
      Navigator.of(_context).pop();
    }
  }

  Future<void> _stopListening() async {
    if (isListening) {
      await _speech.stop();
      isListening = false;
      _hideListeningPopup();
    }
  }

  Future<void> listen() async {
    _manualStop = false; // Reset manual stop flag when starting to listen
    if (!_context.mounted) return;

    Map<Permission, PermissionStatus> statuses =
        await [Permission.microphone, Permission.speech].request();

    if (statuses[Permission.microphone]?.isGranted == true &&
        statuses[Permission.speech]?.isGranted == true) {
      if (!isListening) {
        bool available = await _speech.initialize(
          onStatus: (status) {
            if (status == "done" && isListening && !_manualStop) {
              // Only auto restart if not manually stopped
              Future.delayed(const Duration(milliseconds: 500), listen);
            }
          },
          onError: (error) {
            print("Speech recognition error: $error");
            _stopListening();
            if (!_manualStop) {
              // Only auto restart if not manually stopped
              Future.delayed(const Duration(seconds: 1), listen);
            }
          },
        );

        if (available) {
          _showListeningPopup();
          await _speech.listen(
            localeId: 'id-ID',
            listenMode: stt.ListenMode.confirmation,
            onResult: (result) {
              String command = result.recognizedWords.toLowerCase().trim();
              if (command.isNotEmpty) {
                _processCommand(command);
              }
            },
          );
          isListening = true;
        } else {
          print("Speech recognition not available");
        }
      }
    } else {
      print("Microphone permission denied");
      if (_context.mounted) {
        ScaffoldMessenger.of(_context).showSnackBar(
          const SnackBar(
            content: Text("Izin mikrofon diperlukan untuk fitur ini"),
          ),
        );
      }
    }
  }

  void _processCommand(String command) async {
    if (waitingForConfirmation && _lastPredictedLabel != null) {
      await _stopListening();

      try {
        final confirmationResponse = await _sendToApi(command, "confirm");

        if (confirmationResponse == "1") {
          await _flutterTts.speak("Membuka halaman yang anda inginkan...");
          await Future.delayed(const Duration(seconds: 2));

          waitingForConfirmation = false; // Reset sebelum navigasi
          _openRequestedPage(_lastPredictedLabel);
          _lastPredictedLabel = null;
        } else {
          await _flutterTts.speak("Konfirmasi tidak valid. Silakan coba lagi.");
          waitingForConfirmation = false;
          _lastPredictedLabel = null;

          if (!_manualStop) {
            await Future.delayed(const Duration(seconds: 1));
            listen();
          }
        }
      } catch (e) {
        print("Error processing confirmation: $e");
        await _flutterTts.speak("Terjadi kesalahan. Silakan coba lagi.");
        waitingForConfirmation = false;
        _lastPredictedLabel = null;

        if (!_manualStop) {
          await Future.delayed(const Duration(seconds: 1));
          listen();
        }
      }
    } else {
      try {
        final predictedLabel = await _sendToApi(command, "default");

        if (predictedLabel != null) {
          await _stopListening();

          String message;
          bool requiresConfirmation = true;

          switch (predictedLabel) {
            case "1":
              message = "Apakah anda ingin melakukan transfer?";
              break;
            case "2":
              message = "Apakah anda ingin melakukan top up?";
              break;
            case "3":
              message = "Apakah anda ingin melakukan pembelian listrik?";
              break;
            case "4":
              message = "Apakah anda ingin melakukan pembayaran tagihan?";
              break;
            case "5":
              message = "Apakah anda ingin melakukan isi pulsa?";
              break;
            case "6":
              message = "Apakah anda ingin melihat saldo?";
              break;
            default:
              message = "Perintah anda tidak dikenali, silahkan coba lagi.";
              requiresConfirmation = false;
          }

          if (requiresConfirmation) {
            _lastPredictedLabel = predictedLabel;
            waitingForConfirmation = true;

            await _flutterTts.speak(message);
            await Future.delayed(const Duration(seconds: 2));
            listen();
          } else {
            await _flutterTts
                .speak("Perintah tidak dikenali, silakan coba lagi.");
            if (!_manualStop) {
              await Future.delayed(const Duration(seconds: 2));
              listen();
            }
          }
        } else {
          if (!_manualStop) {
            await _flutterTts
                .speak("Maaf, terjadi kesalahan. Silakan coba lagi.");
            await Future.delayed(const Duration(seconds: 2));
            listen();
          }
        }
      } catch (e) {
        print("Error processing command: $e");
        if (_context.mounted && !_manualStop) {
          ScaffoldMessenger.of(_context).showSnackBar(
            const SnackBar(
              content: Text("Terjadi kesalahan saat memproses perintah"),
            ),
          );
          await Future.delayed(const Duration(seconds: 1));
          listen();
        }
      }
    }
  }

  Future<String?> _sendToApi(String command, String mode) async {
    const apiUrl =
        'https://d227-66-96-225-70.ngrok-free.app/predict'; // Update with your API URL

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"prompt": command, "mode": mode}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['response'];
      } else {
        print("API Error: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Network error: $e");
      if (_context.mounted) {
        ScaffoldMessenger.of(_context).showSnackBar(
          const SnackBar(
            content: Text("Terjadi kesalahan jaringan"),
          ),
        );
      }
      return null;
    }
  }

  void _openRequestedPage(String? label) {
    if (!_context.mounted) return;

    Widget? pageToOpen;

    switch (label) {
      case "1":
        pageToOpen = const TransferPage();
        break;
      case "2":
        pageToOpen = const TopUpPage();
        break;
      case "3":
        pageToOpen = const ListrikPage();
        break;
      case "4":
        pageToOpen = const TagihanPage();
        break;
      case "5":
        pageToOpen = const PulsaPage();
        break;
      case "6":
        pageToOpen = const SaldoPage();
        break;
    }

    if (pageToOpen != null) {
      Navigator.push(
        _context,
        MaterialPageRoute(builder: (context) => pageToOpen!),
      );
    }
  }

  void reset() {
    _manualStop = false;
  }

  void dispose() {
    _speech.cancel();
    _flutterTts.stop();
    isListening = false;
    waitingForConfirmation = false;
    _manualStop = false;
  }
}
