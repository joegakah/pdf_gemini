import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_gemini/pdf_gemini.dart';

void main() {
  group('PDFChatClient', () {
    const geminiApiKey = '';
    final genaiService = GenaiClient(geminiApiKey: geminiApiKey);

    test('Prompt PDF Test', () async {
      final testFile = File('').readAsBytesSync();

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
