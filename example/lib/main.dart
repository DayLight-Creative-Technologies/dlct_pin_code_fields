import 'package:flutter/material.dart';
import 'package:pin_code_text_fields/pin_code_text_fields.dart';

void main() {
  runApp(const PinCodeTextFieldsExampleApp());
}

class PinCodeTextFieldsExampleApp extends StatelessWidget {
  const PinCodeTextFieldsExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PIN Code Text Fields Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const PinCodeDemoPage(),
    );
  }
}

class PinCodeDemoPage extends StatefulWidget {
  const PinCodeDemoPage({super.key});

  @override
  _PinCodeDemoPageState createState() => _PinCodeDemoPageState();
}

class _PinCodeDemoPageState extends State<PinCodeDemoPage> {
  String _pinCode = '';
  bool _obscureText = false;
  bool _showContextMenu = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PIN Code Text Fields Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Standard PIN Code Text Field
            Text(
              'Standard PIN Code (6 digits)',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            PinCodeTextField(
              config: PinCodeConfig(
                length: 6,
                showContextMenu: _showContextMenu,
                enabled: true,
              ),
              onChanged: (value) {
                setState(() {
                  _pinCode = value;
                });
              },
              onCompleted: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('PIN Completed: $value')),
                );
              },
              pinBoxDecoration: PinBoxDecoration.outlinedDecoration(
                borderColor: Colors.blue,
                borderWidth: 2,
              ),
            ),
            const SizedBox(height: 20),

            // Customized PIN Code Text Field
            Text(
              'Customized PIN Code (4 digits)',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            PinCodeTextField(
              config: PinCodeConfig(
                length: 4,
                obscureText: _obscureText,
                showContextMenu: _showContextMenu,
              ),
              textStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              cursorColor: Colors.green,
              cursorWidth: 3,
              cursorHeight: 30,
              pinBoxDecoration: PinBoxDecoration.filledDecoration(
                fillColor: Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 20),

            // Context Menu and Obscure Text Toggles
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Show Context Menu'),
                Switch(
                  value: _showContextMenu,
                  onChanged: (bool value) {
                    setState(() {
                      _showContextMenu = value;
                    });
                  },
                ),
                const SizedBox(width: 20),
                const Text('Obscure Text'),
                Switch(
                  value: _obscureText,
                  onChanged: (bool value) {
                    setState(() {
                      _obscureText = value;
                    });
                  },
                ),
              ],
            ),

            // Display Current PIN Code
            const SizedBox(height: 20),
            Text(
              'Current PIN Code: $_pinCode',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
