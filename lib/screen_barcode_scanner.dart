import 'dart:html' as html;
import 'dart:ui_web' as ui; // Required for registering the view factory

import 'package:flutter/material.dart';

class ScreenBarcodeScanner extends StatefulWidget {
  const ScreenBarcodeScanner({Key? key, required this.onBarcodeDetected}) : super(key: key);

  final Function(String serialNo) onBarcodeDetected;

  @override
  State<ScreenBarcodeScanner> createState() => _ScreenBarcodeScannerState();
}

class _ScreenBarcodeScannerState extends State<ScreenBarcodeScanner> {
  String receivedData = '';

  @override
  void initState() {
    super.initState();

    // Register the view type 'qr-scanner-html'
    ui.platformViewRegistry.registerViewFactory(
      'qr-scanner-html',
      (int viewId) {
        // Create an IFrameElement to display the QR code scanner
        final iframe = html.IFrameElement()
          ..src = 'assets/index.html'
          ..style.border = 'none'; // Removes the default iframe border
        return iframe;
      },
    );

    html.window.onMessage.listen((event) {
      if (event.data != null && event.origin == html.window.location.origin) {
        setState(() {
          receivedData = event.data;
          widget.onBarcodeDetected(event.data);
          print('Barcode: $receivedData');

          // Check if the receivedData is a valid barcode
          if (receivedData.isNotEmpty) {
            Navigator.pop(context);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use HtmlElementView to render the custom element
    return const HtmlElementView(
      viewType: 'qr-scanner-html',
    );
  }
}
