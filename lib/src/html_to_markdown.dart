import 'dart:ffi';

import 'package:ffi/ffi.dart' as ffi;
import 'package:html_to_markdown_rust/src/bindings.g.dart';

String htmlToMarkdown(String html) {
  final htmlPointer = html.toNativeUtf8().cast<Char>();
  final resultPtr = htm_convert(htmlPointer, html.length);
  if (resultPtr == nullptr) {
    throw Exception('Failed to convert HTML to Markdown');
  }
  final markdown = resultPtr.cast<ffi.Utf8>().toDartString();
  htm_free_string(resultPtr);
  return markdown;
}
