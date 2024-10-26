// ignore_for_file: avoid_print

import 'dart:io';
import 'package:pdf_gemini/pdf_gemini.dart';
import 'package:pdf_gemini/src/models/genai_response.dart'; // Ensure this package is included in your pubspec.yaml

void main() async {
  // Replace with your actual Gemini API key
  const String geminiApiKey = 'YOUR_GEMINI_API_KEY';

  // Create an instance of GenaiClient
  final genaiClient = GenaiClient(geminiApiKey: geminiApiKey);

  // Example file data (replace with actual file data)
  File file = File('' /* Your file path here */);
  String fileName = 'example.pdf';
  String fileType = 'pdf';

  try {
    // Upload a file and get the GenAI file
    GenaiFile uploadedFile = await genaiClient.genaiFileManager.uploadFile(
      fileName,
      fileType,
      file.readAsBytesSync(),
    );

    print('Uploaded File: ${uploadedFile.displayName}');

    // Generate content using the uploaded file
    String prompt = "Can you add a few more lines to this poem?";
    GenaiGeneratedResponseModel response = await genaiClient.promptDocument(
      uploadedFile.displayName,
      uploadedFile.mimeType,
      file.readAsBytesSync(),
      prompt,
    );

    print('Generated Text: ${response.text}');

    if (response.citationUri != null) {
      print('Citation URI: ${response.citationUri}');
    }

    // Retrieve all uploaded files
    List<GenaiFile> uploadedFiles =
        await genaiClient.genaiFileManager.getUploadedFiles();

    print('Uploaded Files:');
    for (var file in uploadedFiles) {
      print('- ${file.displayName} (${file.sizeBytes} bytes)');
    }
  } catch (e) {
    print('Error: $e');
  }
}
