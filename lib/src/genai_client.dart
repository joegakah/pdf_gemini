import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:pdf_gemini/pdf_gemini.dart';
import 'package:pdf_gemini/src/models/genai_response.dart';

/// A client for interacting with the Gemini API with pdf
class GenaiClient {
  /// Gemini API Key.
  final String geminiApiKey;

  /// Initializes the Genai File Manager.
  final GenaiFileManager genaiFileManager;

  /// Base URL used to call APIs.
  String baseUrl = "https://generativelanguage.googleapis.com/v1beta";

  /// Creates an instance of [GenaiClient].
  ///
  /// Requires a [geminiApiKey] to authenticate with the Gemini API.
  GenaiClient({required this.geminiApiKey})
      : genaiFileManager = GenaiFileManager(geminiApiKey: geminiApiKey);

  /// Prompts the generation of a document based on the provided parameters.
  ///
  /// Takes a [fileName], [fileType], [fileData], and a [prompt] string.
  /// Returns a [GenaiGeneratedResponseModel] containing the generated content.
  Future<GenaiGeneratedResponseModel> promptDocument(
    String fileName,
    String fileType,
    Uint8List fileData,
    String prompt,
  ) async {
    try {
      // Get the genai file by checking if it exists; otherwise, upload it.
      final file = await genaiFileManager.getGenaiFile(
        fileName,
        fileType,
        fileData,
      );

      final response = await Dio().post(
        '$baseUrl/models/gemini-1.5-flash:generateContent?key=$geminiApiKey',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
        data: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
                {
                  "file_data": {
                    "mime_type": "application/pdf",
                    "file_uri": file.uri,
                  }
                }
              ]
            }
          ]
        }),
      );

      var genaiResponse = GenaiGeneratedResponseModel.fromJson(response.data);

      return genaiResponse;
    } catch (e) {
      throw "Error $e";
    }
  }
}
