/// Represents a file managed by the Gemini API.
///
/// This class contains metadata about the file, including its name,
/// display name, MIME type, size, creation and update times,
/// expiration time, SHA256 hash, URI, and state.
class GenaiFile {
  /// The name of the file.
  final String name;

  /// The display name of the file.
  final String displayName;

  /// The MIME type of the file.
  final String mimeType;

  /// The size of the file in bytes.
  final String sizeBytes;

  /// The creation time of the file.
  final DateTime createTime;

  /// The last update time of the file.
  final DateTime updateTime;

  /// The expiration time of the file.
  final DateTime expirationTime;

  /// The SHA256 hash of the file's content.
  final String sha256Hash;

  /// The URI where the file can be accessed.
  final String uri;

  /// The current state of the file (e.g., uploaded, processing).
  final String state;

  /// Creates an instance of [GenaiFile].
  ///
  /// Requires parameters for all fields to initialize a [GenaiFile] object.
  GenaiFile({
    required this.name,
    required this.displayName,
    required this.mimeType,
    required this.sizeBytes,
    required this.createTime,
    required this.updateTime,
    required this.expirationTime,
    required this.sha256Hash,
    required this.uri,
    required this.state,
  });

  /// Creates a [GenaiFile] instance from a map (JSON).
  ///
  /// Takes a [json] map and returns an instance of [GenaiFile].
  factory GenaiFile.fromJson(Map<String, dynamic> json) {
    return GenaiFile(
      name: json['name'],
      displayName: json['displayName'],
      mimeType: json['mimeType'],
      sizeBytes: json['sizeBytes'],
      createTime: DateTime.parse(json['createTime']),
      updateTime: DateTime.parse(json['updateTime']),
      expirationTime: DateTime.parse(json['expirationTime']),
      sha256Hash: json['sha256Hash'],
      uri: json['uri'],
      state: json['state'],
    );
  }

  /// Converts a [GenaiFile] instance back to JSON format.
  ///
  /// Returns a map representation of the [GenaiFile] instance.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'displayName': displayName,
      'mimeType': mimeType,
      'sizeBytes': sizeBytes.toString(),
      'createTime': createTime.toIso8601String(),
      'updateTime': updateTime.toIso8601String(),
      'expirationTime': expirationTime.toIso8601String(),
      'sha256Hash': sha256Hash,
      'uri': uri,
      'state': state,
    };
  }
}
