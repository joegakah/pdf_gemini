# Pdf Gemini Package

This package provides a simple way to interact, chat with pdf files using google gemini and managing uploaded files.

## Features
- Upload PDF to gemini
- Prompt PDF ang get generated response with Google Gemini Api
- Lightweight and easy to integrate into any Flutter app.

## Installation

Run the command on your command prompt

```bash
flutter pub add pdf_gemini
```

## Usage

### Step 1: Import the Package
In your Dart file, import the package:

```dart
import 'package:pdf_gemini/pdf_gemini.dart';

```

### Step 2: Provide Your API Key
When using the API service, instantiate the service class and pass your API key to it. Here's an example of how to fetch data from an API endpoint:

```dart
void main() async {
  const geminiApiKey = 'your_api_key_here';
  final genaiService = GenaiClient(geminiApiKey: geminiApiKey);

  try {
    final testFile = File('');
    final data = await genaiService.promptDocument(
      'file_name', 
      'pdf', 
      testFile.readAsBytesSync(), 
      'Your prompt',
    );
    print(data.text);
  } catch (e) {
    print('Error: $e');
  }
}
```

### Example Explained:
- Replace `'your_api_key_here'` with your actual API key provided by the service you're integrating.
- The `promptDocument()` method accepts the document and prompt input and returns the generated response as a model (text: text, citations: sources) if successful.
- Make sure to handle exceptions in case of a failed request.

## Testing

To ensure your package works as expected, you can write tests to mock API responses. Here's a simple test example:

```dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_gemini/pdf_gemini.dart';

void main() {
  group('PDFChatClient', () {
    const geminiApiKey = '';
    final genaiService = GenaiClient(geminiApiKey: geminiApiKey);

    test('Prompt PDF Test', () async {
      // Create a temporary test file
      final testFile = File('your_file_path').readAsBytesSync();

      try {
        await genaiService.promptDocument(
          fileName: 'Your file name',
          fileType: 'pdf',
          fileData: testFile,
          prompt: 'your prompt',
          model: 'gemini-1.5-flash',
        );
      } catch (e) {
        fail('Failed: $e');
      }
    });
  });
}

```

## Contributing

Contributions are welcome! If you'd like to improve this package, feel free to fork the repository and submit a pull request. Make sure to write tests for any new features.

## License

This project is licensed under the BSD 3-clause license - see the [LICENSE](LICENSE) file for details.