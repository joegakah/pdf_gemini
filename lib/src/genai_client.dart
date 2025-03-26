import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:pdf_gemini/pdf_gemini.dart';
import 'package:pdf_gemini/src/genai_generated_response_model.dart';

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
  Future<GenaiGeneratedResponseModel> promptDocument({
    required String fileName,
    required String fileType,
    required Uint8List fileData,
    required String prompt,
    String? model,
  }) async {
    try {
      // Get the genai file by checking if it exists; otherwise, upload it.
      final file = await genaiFileManager.getGenaiFile(
        fileName,
        fileType,
        fileData,
      );

      /// Sends a POST request to the specified model endpoint to generate content.
      ///
      /// The request is sent to the URL constructed using the base URL, the model name
      /// (defaulting to 'gemini-1.5-flash' if not provided), and the API key.
      ///
      /// Parameters:
      /// - `baseUrl`: The base URL of the API.
      /// - `model`: The model name to use for content generation. Defaults to 'gemini-1.5-flash' if null.
      /// - `geminiApiKey`: The API key for authentication.
      ///
      /// Returns:
      /// A `Future` that resolves to the response of the POST request.
      final response = await Dio().post(
        '$baseUrl/models/${model ?? 'gemini-1.5-flash'}:generateContent?key=$geminiApiKey',
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
