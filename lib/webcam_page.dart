import 'dart:html' as html;
import 'dart:ui_web' as ui; // Required for registering the view factory

import 'package:flutter/material.dart';

class WebCamPage extends StatelessWidget {
  WebCamPage({Key? key}) : super(key: key) {
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
  }

  @override
  Widget build(BuildContext context) {
    // Use HtmlElementView to render the custom element
    return const HtmlElementView(
      viewType: 'qr-scanner-html',
    );
  }
}
