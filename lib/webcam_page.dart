import 'dart:html';
import 'dart:js' as js;
import 'dart:ui_web' as ui;

import 'package:flutter/foundation.dart';
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
  bool _isFrontCamera = true;

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

    // Ensure jsQR is exposed
    js.context.callMethod('exposeJsQR');

    _initializeCamera();
  }

  void _initializeCamera() {
    final constraints = {
      'video': {
        'facingMode': _isFrontCamera ? 'user' : 'environment',
      },
    };

    window.navigator.mediaDevices!.getUserMedia(constraints).then((MediaStream stream) {
      _webCamVideoElement.srcObject = stream;
      _webCamVideoElement.autoplay = true; // Ensure the video plays automatically
      _webCamVideoElement.onLoadedMetadata.listen((_) {
        _startScanning();
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error accessing camera: $error')));
      if (kDebugMode) {
        print('Error accessing camera: $error');
      }
    });
  }

  void _startScanning() {
    if (_webCamVideoElement.readyState == 2) {
      // HAVE_ENOUGH_DATA
      window.requestAnimationFrame((_) => _scanFrame());
    } else {
      _webCamVideoElement.onCanPlay.listen((_) {
        window.requestAnimationFrame((_) => _scanFrame());
      });
    }
  }

  void _scanFrame() {
    _canvasContext.drawImage(_webCamVideoElement, 0, 0);

    ImageData imageData =
        _canvasContext.getImageData(0, 0, _canvasElement.width!, _canvasElement.height!);

    // Call jsQR to decode the barcode
    var result = js.context
        .callMethod('jsQR', [imageData.data, _canvasElement.width, _canvasElement.height]);

    if (result != null && result['data'] != null) {
      String qrCodeData = result['data'];
      if (kDebugMode) {
        print('QR Code detected: $qrCodeData');
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('QR Code detected: $qrCodeData')));
    } else {
      if (kDebugMode) {
        print('No QR Code detected');
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No QR Code detected')));
    }

    // Continue scanning
    window.requestAnimationFrame((_) => _scanFrame());
  }

  void _toggleCamera() {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
      _initializeCamera();
    });
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
                child: const Text('Call JS')),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleCamera,
        tooltip: 'Switch Camera',
        child: const Icon(Icons.switch_camera),
      ),
    );
  }
}
