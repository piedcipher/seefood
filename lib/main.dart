import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
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
  File _file;
  String _labels;
  bool _result;

  void _openFilePicker() async {
    var file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _file = file;
    });
    _runMLKitOnDeviceImageLabeler();
  }

  void _runMLKitOnDeviceImageLabeler() async {
    FirebaseVisionImage firebaseVisionImage =
        FirebaseVisionImage.fromFile(_file);
    ImageLabeler imageLabeler = FirebaseVision.instance.imageLabeler();
    List<ImageLabel> imageLabels =
        await imageLabeler.processImage(firebaseVisionImage);
    String labels = imageLabels.map((imageLabel) => imageLabel.text).join(", ");
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
      } else {
        setState(() {
          _result = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("See Food"),
          actions: <Widget>[
            _file != null
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        _file = null;
                      });
                    },
                    icon: Icon(Icons.close),
                  )
                : IconButton(
                    onPressed: () {
                      _openFilePicker();
                    },
                    icon: Icon(Icons.attach_file),
                  )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _openFilePicker,
          child: Icon(Icons.attach_file),
        ),
        body: _file == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: Text(
                      "Click FAB to select an Image",
                    ),
                  ),
                ],
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FutureBuilder(
                      builder: (BuildContext buildContext,
                              AsyncSnapshot<dynamic> snapshot) =>
                          Container(
                            width: double.infinity,
                            color: _result ? Colors.green : Colors.red,
                            padding: EdgeInsets.all(16.0),
                            margin: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                            child: Text(
                              _result
                                  ? "Yes! Image does contains food items.\n\n$_labels"
                                  : "No! Image doesn't contain food items.\n\n$_labels",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(12.0),
                      child: FutureBuilder(
                          builder: (BuildContext buildContext,
                              AsyncSnapshot<dynamic> snapshot) =>
                              Image.file(_file)),
                    ),
                  ],
                ),
              ));
  }
}
