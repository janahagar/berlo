import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../ChatScreen.dart';
import '../map/map_page.dart';

class ImageClassificationPage extends StatefulWidget {
  const ImageClassificationPage({super.key});

  @override
  State<ImageClassificationPage> createState() =>
      _ImageClassificationPageState();
}

class _ImageClassificationPageState extends State<ImageClassificationPage> {
  File? _image;
  String? _ocrResult;
  bool _isLoading = false;
  List<String> _history = [];

  // Gemini output
  bool _geminiLoading = false;
  String? _geminiPlace;
  String? _geminiBrief;
  List<String>? _geminiPros;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked == null) return;

    setState(() {
      _image = File(picked.path);
      _ocrResult = null;
    });

    await _runOCR();
    if (_ocrResult != null && _ocrResult!.trim().isNotEmpty) {
      _history.insert(0, _ocrResult!);
    }
  }

  Future<void> _runOCR() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
    });

    final recognizer = TextRecognizer();
    final inputImage = InputImage.fromFile(_image!);

    try {
      final result = await recognizer.processImage(inputImage);
      setState(() {
        _ocrResult = result.text.isNotEmpty ? result.text : 'No text found.';
      });
    } catch (e) {
      setState(() {
        _ocrResult = 'Error during OCR: $e';
      });
    } finally {
      recognizer.close();
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _classifyWithGemini(String text) async {
    setState(() {
      _geminiLoading = true;
      _geminiPlace = null;
      _geminiBrief = null;
      _geminiPros = null;
    });

    final apiKey = 'YOUR_GEMINI_API_KEY'; // Replace this
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-pro:generateContent?key=$apiKey',
    );

    final prompt = """
You are a Berlin travel assistant. Given this OCR result, identify the Berlin site, give a short description, and list 3 tourist highlights in JSON:
Text: $text
""";

    final body = jsonEncode({
      "contents": [
        {
          "role": "user",
          "parts": [
            {"text": prompt},
          ],
        },
      ],
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      final data = jsonDecode(response.body);
      final reply = data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];

      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(reply ?? '');
      if (jsonMatch != null) {
        final result = jsonDecode(jsonMatch.group(0)!);
        setState(() {
          _geminiPlace = result['place'];
          _geminiBrief = result['brief'];
          _geminiPros = List<String>.from(result['pros']);
        });
      } else {
        setState(() {
          _geminiPlace = "Could not understand response.";
        });
      }
    } catch (e) {
      setState(() {
        _geminiPlace = "Gemini Error: $e";
      });
    } finally {
      setState(() {
        _geminiLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Image Classification (ML Kit)")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text("Upload or capture a hieroglyph or Berlin site photo."),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera),
                  label: const Text("Camera"),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo),
                  label: const Text("Gallery"),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child:
                    kIsWeb
                        ? Image.network(_image!.path, height: 200)
                        : Image.file(_image!, height: 200),
              ),
            if (_isLoading) const CircularProgressIndicator(),
            if (_ocrResult != null && !_isLoading) ...[
              const SizedBox(height: 12),
              const Text(
                "OCR Result:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(_ocrResult!),
              ElevatedButton(
                onPressed: () => _classifyWithGemini(_ocrResult!),
                child: const Text("Ask Gemini"),
              ),
            ],
            if (_geminiLoading) const CircularProgressIndicator(),
            if (_geminiPlace != null && !_geminiLoading) ...[
              const SizedBox(height: 12),
              Text(
                "Place: $_geminiPlace",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (_geminiBrief != null) Text(_geminiBrief!),
              if (_geminiPros != null)
                ..._geminiPros!.map((p) => Text("• $p")).toList(),
            ],
          ],
        ),
      ),
    );
  }
}
