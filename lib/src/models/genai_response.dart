/// Represents the response model for generated content from the Gemini API.
///
/// This class contains the generated text and an optional citation URI.
class GenaiGeneratedResponseModel {
  /// The generated text content.
  final String text;

  /// The URI of the source that cites this generated content, if available.
  final String? citationUri;

  /// Creates an instance of [GenaiGeneratedResponseModel].
  ///
  /// Requires [text] to be provided, and [citationUri] is optional.
  GenaiGeneratedResponseModel({required this.text, this.citationUri});

  /// Factory constructor to create a [GenaiGeneratedResponseModel] instance
  /// from a JSON response.
  ///
  /// Takes a [json] map and extracts relevant data to initialize the model.
  factory GenaiGeneratedResponseModel.fromJson(Map<String, dynamic> json) {
    // Extract text
    String text = '';
    List<dynamic> candidates = json['candidates'] ?? [];
    if (candidates.isNotEmpty) {
      text = candidates[0]['content']['parts'][0]['text'] ?? '';
    }

    // Extract citation URI
    String? citationUri;
    if (candidates.isNotEmpty && candidates[0]['citationMetadata'] != null) {
      List<dynamic> citationSources =
          candidates[0]['citationMetadata']['citationSources'] ?? [];
      if (citationSources.isNotEmpty) {
        citationUri = citationSources[0]['uri'];
      }
    }

    return GenaiGeneratedResponseModel(text: text, citationUri: citationUri);
  }
}
