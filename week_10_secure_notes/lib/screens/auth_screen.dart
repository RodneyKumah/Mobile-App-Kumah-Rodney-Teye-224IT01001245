import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import '../services/biometric_service.dart';
import '../services/secure_storage_service.dart';
import 'notes_list_screen.dart';

class AuthScreen extends StatefulWidget {
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final BiometricService biometric = BiometricService();
  final TextEditingController controller = TextEditingController();

  void goToNotes() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => NotesListScreen()),
    );
  }

  void verifyPin() async {
    final stored = await SecureStorageService.loadPin();

    if (stored == null) {
      final hash =
          sha256.convert(utf8.encode(controller.text)).toString();
      await SecureStorageService.savePin(hash);
      goToNotes();
      return;
    }

    final inputHash =
        sha256.convert(utf8.encode(controller.text)).toString();

    if (inputHash == stored) {
      goToNotes();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Wrong PIN")),
      );
    }
  }

  // ✅ FIXED BIOMETRIC FUNCTION
  Future<void> handleBiometric() async {
    try {
      bool canCheck = await biometric.canCheckBiometrics();

      if (!canCheck) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Biometric not available on this device")),
        );
        return;
      }

      bool authenticated = await biometric.authenticate();

      if (authenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Biometric Success ✅")),
        );
        goToNotes();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Authentication Failed ❌")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // 🔐 BIOMETRIC BUTTON
            ElevatedButton.icon(
              onPressed: handleBiometric,
              icon: const Icon(Icons.fingerprint),
              label: const Text("Unlock with Biometrics"),
            ),

            const SizedBox(height: 20),
            const Text("OR"),
            const SizedBox(height: 20),

            // 🔑 PIN INPUT
            TextField(
              controller: controller,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: "Enter PIN"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: verifyPin,
              child: const Text("Unlock with PIN"),
            ),
          ],
        ),
      ),
    );
  }
}