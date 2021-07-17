import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'See Food',
      theme: ThemeData(
        primaryColor: Colors.deepPurple,
        primaryColorDark: Colors.deepPurple[700],
        accentColor: Colors.pinkAccent,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  XFile? _file;
  String _labels = '';
  bool _result = false;

  Future<void> _openFilePicker() async {
    var file = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _file = file;
    });
    await _runMLKitOnDeviceImageLabeler();
  }

  Future<void> _runMLKitOnDeviceImageLabeler() async {
    InputImage firebaseVisionImage = InputImage.fromFile(File(_file!.path));
    ImageLabeler imageLabeler = GoogleMlKit.vision.imageLabeler();
    List<ImageLabel> imageLabels =
        await imageLabeler.processImage(firebaseVisionImage);
    String labels =
        imageLabels.map((imageLabel) => imageLabel.label).join(', ');
    setState(() {
      _labels = labels;
      if (_labels.contains("Food") ||
          _labels.contains("Cuisine") ||
          _labels.contains("Vegetable") ||
          _labels.contains("Fruit") ||
          _labels.contains("Fast food") ||
          _labels.contains("Meal")) {
        setState(() {
          _result = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('See Food'),
        actions: <Widget>[
          _file != null
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _file = null;
                    });
                  },
                  icon: const Icon(Icons.close),
                )
              : IconButton(
                  onPressed: () async {
                    await _openFilePicker();
                  },
                  icon: const Icon(Icons.attach_file),
                )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _openFilePicker();
        },
        child: const Icon(Icons.attach_file),
      ),
      body: _file == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Center(
                  child: const Text('Click FAB to select an Image'),
                ),
              ],
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    color: _result ? Colors.green : Colors.red,
                    padding: const EdgeInsets.all(16.0),
                    margin: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 12.0,
                    ),
                    child: Text(
                      _result
                          ? "Yes! Image does contains food items.\n\n$_labels"
                          : "No! Image doesn't contain food items.\n\n$_labels",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(12.0),
                    child: Image.file(File(_file!.path)),
                  ),
                ],
              ),
            ),
    );
  }
}
