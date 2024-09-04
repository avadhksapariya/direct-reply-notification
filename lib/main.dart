import 'package:direct_reply_notification/webcam_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = MethodChannel('com.app.platform_channel/method_calls');
  String msgFromNative = '';

  TextEditingController nameController = TextEditingController();
  bool validate = false;

  Future<void> passDataToNative(String userName) async {
    try {
      var result = await platform.invokeMethod('passDataToNative', [
        {"text": userName}
      ]);
      msgFromNative = ' $result';
    } on PlatformException catch (e) {
      msgFromNative = "Failed to get battery level: '${e.message}'.";
    }
    setState(() {
      msgFromNative = msgFromNative;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'MethodChannel Demo',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple[300]!,
              Colors.blue[300]!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Card(
            elevation: 8,
            shadowColor: Colors.black,
            margin: const EdgeInsets.all(12.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name:',
                        errorText: validate ? 'Please enter your name.' : null,
                        alignLabelWithHint: true,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        validate = nameController.text.isEmpty;
                      });
                      if (validate == false) {
                        passDataToNative(nameController.text);
                      }
                    },
                    child: const Text('Pass data to native'),
                  ),
                  if (nameController.text.isNotEmpty) Text(msgFromNative),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) => WebCamPage()));
                      },
                      child: const Text('Open WebCam'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
