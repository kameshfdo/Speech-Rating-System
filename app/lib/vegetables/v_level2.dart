// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'dart:convert';
import 'package:app/vegetables/v_level3.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class VLevel2 extends StatefulWidget {
  const VLevel2({super.key});

  @override
  State<VLevel2> createState() => _VLevel2State();
}

class _VLevel2State extends State<VLevel2> {
  String _status = "Identify the Image";
  String _responseText = "";
  bool _isRecording = false;
  FlutterSoundRecorder? _recorder;
  String? _filePath;
  final String _targetValue = "tomato";

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    await _recorder!.openRecorder();
    await Permission.microphone.request();
  }

  Future<void> _startRecording() async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = '${tempDir.path}/temp.wav';

    await _recorder!.startRecorder(
      toFile: tempPath,
      codec: Codec.pcm16WAV,
    );

    setState(() {
      _isRecording = true;
      _status = "Recording...";
      _filePath = tempPath;
    });
  }

  Future<void> _stopRecording() async {
    await _recorder!.stopRecorder();

    setState(() {
      _isRecording = false;
      _status = "Recording stopped. Click The Check Button.";
    });
  }

  Future<void> _uploadFile() async {
    if (_filePath == null) {
      setState(() {
        _status = "Click recording button first";
      });
      return;
    }

    String url = 'http://10.0.2.2:5000/transcribe';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.files.add(await http.MultipartFile.fromPath('file', _filePath!));
      request.fields['target'] = _targetValue;

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseBody);
        setState(() {
          _status = "Recorded uploaded successfully";
          _responseText = jsonResponse['rate_speech'] ?? 'No rate_speech found';
        });
      } else {
        setState(() {
          _status = "Failed to upload Record: ${response.statusCode}";
          _responseText = "";
        });
      }
    } catch (e) {
      setState(() {
        _status = "Error: $e";
        _responseText = "";
      });
    }
  }

  @override
  void dispose() {
    _recorder!.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        title: Text(
          "Level 2",
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 59, 193, 64),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Container(
                height: constraints.maxHeight * 0.87,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Image.asset('assets/pictures/tomato.png'),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _status,
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed:
                          _isRecording ? _stopRecording : _startRecording,
                      child: Text(
                          _isRecording ? "Stop Recording" : "Start Recording"),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 59, 193, 64),
                      ),
                      onPressed: _uploadFile,
                      child: Text(
                        "Check",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: TextEditingController(text: _responseText),
                      readOnly: true,
                      maxLines: null,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Result",
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: constraints.maxHeight * 0.13,
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(16.0),
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => VLevel3()),
                    );
                  },
                  child: Icon(Icons.arrow_forward),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
