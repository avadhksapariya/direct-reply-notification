import 'dart:html';
import 'dart:js' as js;
import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';

class WebCamPage extends StatefulWidget {
  const WebCamPage({super.key});

  @override
  State<WebCamPage> createState() => _WebCamPageState();
}

class _WebCamPageState extends State<WebCamPage> {
  late Widget _webCamWidget;
  late VideoElement _webCamVideoElement;
  late CanvasElement _canvasElement;
  late CanvasRenderingContext2D _canvasContext;

  @override
  void initState() {
    super.initState();
    _webCamVideoElement = VideoElement();
    ui.platformViewRegistry
        .registerViewFactory('webcamVideoElement', (int viewId) => _webCamVideoElement);
    _webCamWidget = HtmlElementView(key: UniqueKey(), viewType: 'webcamVideoElement');

    // Setup the canvas for capturing video frames
    _canvasElement = CanvasElement();
    _canvasElement.width = 750;
    _canvasElement.height = 750;
    _canvasContext = _canvasElement.getContext('2d') as CanvasRenderingContext2D;

    // Request access to the webcam
    window.navigator.getUserMedia(video: true).then((MediaStream stream) {
      _webCamVideoElement.srcObject = stream;
      _webCamVideoElement.onLoadedMetadata.listen((_) {
        // Start scanning once the video metadata is loaded
        _startScanning();
      });
    });
  }

  void _startScanning() {
    window.requestAnimationFrame((_) => _scanFrame());
  }

  void _scanFrame() {
    _canvasContext.drawImage(_webCamVideoElement, 0, 0);

    ImageData imageData =
        _canvasContext.getImageData(0, 0, _canvasElement.width!, _canvasElement.height!);
    var code = js.context
        .callMethod('jsQR', [imageData.data, _canvasElement.width, _canvasElement.height]);

    if (code != null) {
      String qrCodeData = code['data'];
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('QR Code detected: $qrCodeData')));
    }
    window.requestAnimationFrame((_) => _scanFrame());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Webcam QR Scanner'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(width: 750, height: 750, child: _webCamWidget),
            ElevatedButton(
                onPressed: () {
                  js.context.callMethod("resFromJs");
                },
                child: const Text('Call JS'))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _webCamVideoElement.srcObject!.active != null
            ? _webCamVideoElement.play()
            : _webCamVideoElement.pause(),
        tooltip: 'Start stream, stop stream',
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
