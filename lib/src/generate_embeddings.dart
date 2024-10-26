import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// A class to generate embeddings using the Gemini API.
///
/// This class provides methods to embed text chunks and generate prompts
/// based on user input and existing embeddings.
class GenerateEmbeddings {
  /// The API key used for authenticating requests to the Gemini API.
  final String geminiApiKey;

  /// Creates an instance of [GenerateEmbeddings].
  ///
  /// Requires a [geminiApiKey] to authenticate API requests.
  GenerateEmbeddings({required this.geminiApiKey});

  /// Dio instance for making HTTP requests.
  final dio = Dio();

  /// A utility for splitting strings into lines.
  final splitter = const LineSplitter();

  /// Base URL for the Gemini API.
  String baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';

  /// Generate text chunks from PDF
  Future<List<String>> getChunksFromPDF(Uint8List fileBytes) async {
    final List<String> pageTextChunks = [];

    final PdfDocument document = PdfDocument(inputBytes: fileBytes);

    final PdfTextExtractor extractor = PdfTextExtractor(document);

    for (int pageIndex = 0; pageIndex < document.pages.count; pageIndex++) {
      final List<TextLine> textLines = extractor.extractTextLines(
        startPageIndex: pageIndex,
      );
      final int halfLineIndex = (textLines.length / 2).floor();
      final StringBuffer firstHalfText = StringBuffer();
      final StringBuffer secondHalfText = StringBuffer();

      for (int lineIndex = 0; lineIndex < textLines.length; lineIndex++) {
        if (lineIndex < halfLineIndex) {
          firstHalfText.writeln(textLines[lineIndex].text);
        } else {
          secondHalfText.writeln(textLines[lineIndex].text);
        }
      }

      if (firstHalfText.isNotEmpty) {
        pageTextChunks.add(firstHalfText.toString());
      }
      if (secondHalfText.isNotEmpty) {
        pageTextChunks.add(secondHalfText.toString());
      }
    }
    return pageTextChunks;
  }

  /// Embeds a list of text chunks in batches.
  ///
  /// This method takes a list of strings (`textChunks`) and returns a map
  /// where each string is associated with its corresponding embedding vector.
  ///
  /// Parameters:
  /// - [textChunks]: A list of strings to be embedded.
  ///
  /// Returns:
  /// A [Future] that resolves to a map containing each input string and its
  /// corresponding embedding as a list of numbers.
  Future<Map<String, List<num>>> batchEmbedChunks({
    required List<String> textChunks,
  }) async {
    try {
      final Map<String, List<num>> embeddingsMap = {};

      // Number of text chunks to process in each batch.
      const int chunkSize = 100;

      // Process text chunks in batches.
      for (int i = 0; i < textChunks.length; i += chunkSize) {
        final chunkEnd = (i + chunkSize < textChunks.length)
            ? i + chunkSize
            : textChunks.length;
        final List<String> currentChunk = textChunks.sublist(i, chunkEnd);

        // Make a POST request to the API to get embeddings for the current chunk.
        final response = await dio.post(
          '$baseUrl/embedding-001:batchEmbedContents?key=$geminiApiKey',
          options: Options(headers: {'Content-Type': 'application/json'}),
          data: {
            'requests': currentChunk
                .map(
                  (text) => {
                    'model': 'models/embedding-001',
                    'content': {
                      'parts': [
                        {'text': text},
                      ],
                    },
                    'taskType': 'RETRIEVAL_DOCUMENT',
                  },
                )
                .toList(),
          },
        );
        final results = response.data['embeddings'];

        // Map each input string to its corresponding embedding result.
        for (var j = 0; j < currentChunk.length; j++) {
          embeddingsMap[currentChunk[j]] =
              (results![j]['values'] as List).cast<num>();
        }
      }
      return embeddingsMap; // Return the map of embeddings.
    } catch (e) {
      rethrow; // Rethrow any caught exceptions for handling upstream.
    }
  }

  /// Generates a prompt based on user input and existing embeddings.
  ///
  /// This method constructs a prompt that combines user input with the most
  /// relevant embedded texts. It calculates distances between the user's
  /// embedding and existing embeddings to find the closest matches.
  ///
  /// Parameters:
  /// - [userPrompt]: The prompt provided by the user for generating a response.
  /// - [embeddings]: A map of existing embeddings to compare against the user's prompt.
  ///
  /// Returns:
  /// A [Future] that resolves to a formatted string incorporating relevant texts
  /// and instructions for generating a response.
  Future<String> promptForEmbedding({
    required String userPrompt,
    required Map<String, List<num>>? embeddings,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/embedding-001:embedContent?key=$geminiApiKey',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: jsonEncode({
          'model': 'models/embedding-001',
          'content': {
            'parts': [
              {'text': userPrompt},
            ],
          },
          'taskType': 'RETRIEVAL_QUERY',
        }),
      );
      final currentEmbedding =
          (response.data['embedding']['values'] as List).cast<num>();

      if (embeddings == null) {
        return 'Error: Embedding calculation failed or no embeddings in state.';
      }

      final Map<String, double> distances =
          {}; // To store distances between embeddings.

      // Calculate distances between the user's embedding and existing embeddings.
      embeddings.forEach((key, value) {
        final double distance = calculateEuclideanDistance(
          vectorA: currentEmbedding,
          vectorB: value,
        );
        distances[key] = distance; // Store distance for each embedding.
      });

      // Sort distances to find the closest matches.
      final List<MapEntry<String, double>> sortedDistances = distances.entries
          .toList()
        ..sort((a, b) => a.value.compareTo(b.value));

      final StringBuffer mergedText = StringBuffer();

      // Merge the top four closest texts into a single string.
      for (int i = 0; i < 4 && i < sortedDistances.length; i++) {
        mergedText.write(sortedDistances[i].key);
        if (i < 3 && i < sortedDistances.length - 1) {
          mergedText.write('\n\n'); // Add spacing between entries.
        }
      }

      // Construct the final prompt string with instructions for response generation.
      final prompt = '''
You're a chat with pdf ai assistance.

I've providing you with the most relevant text from pdf attached by user and your job is to read the following text delimited by delimiter #### carefully word by word and answer the prompt requested by user.

Prompt will be initialised by the word "Prompt".

####
$mergedText
####

Prompt: $userPrompt

Give answer in a friendly tone with being crisp and precise in your answer. DONOT use any buzzwords, make sure your language is simple and easy to understand. 

If user asks something unrelated to the pdf or book, simply reply with your overall sense.

If you don't know the answer, just say "I don't know" or "I'm not sure".
''';

      return prompt; // Return the constructed prompt string.
    } catch (e) {
      throw 'An error occurred, please try again.'; // Handle errors gracefully.
    }
  }

  /// Calculates the Euclidean distance between two vectors.
  ///
  /// This method computes how far apart two vectors are in multi-dimensional space,
  /// which is useful for determining similarity between embeddings.
  ///
  /// Parameters:
  /// - [vectorA]: The first vector as a list of numbers.
  /// - [vectorB]: The second vector as a list of numbers.
  ///
  /// Returns:
  /// The Euclidean distance as a double value.
  double calculateEuclideanDistance({
    required List<num> vectorA,
    required List<num> vectorB,
  }) {
    try {
      assert(
        vectorA.length == vectorB.length,
        'Vectors must be of the same length', // Ensure vectors are comparable.
      );

      double sum = 0;

      // Calculate squared differences and sum them up.
      for (int i = 0; i < vectorA.length; i++) {
        sum += (vectorA[i] - vectorB[i]) * (vectorA[i] - vectorB[i]);
      }

      return sqrt(sum); // Return square root of sum of squares as distance.
    } catch (e) {
      throw 'Error in calculating Euclidean distance: $e'; // Handle errors gracefully.
    }
  }
}
