import 'dart:convert';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:html_to_markdown_rust/src/bindings.g.dart';
import 'package:html_to_markdown_rust/src/conversion_options.dart';

({Pointer<Char> pointer, int length}) _encodeHtml(String html) {
  final bytes = utf8.encode(html);
  final pointer = calloc<Uint8>(bytes.length + 1);
  pointer.asTypedList(bytes.length).setAll(0, bytes);
  pointer[bytes.length] = 0;
  return (pointer: pointer.cast<Char>(), length: bytes.length);
}

/// Converts an HTML string to Markdown.
///
/// [html] is the HTML string to convert.
/// [options] is the optional configuration for the conversion.
String htmlToMarkdown(String html, [ConversionOptions? options]) {
  final optionsJson = options != null ? jsonEncode(options.toJson()) : null;
  final htmlAllocation = _encodeHtml(html);
  final htmlPointer = htmlAllocation.pointer;

  try {
    Pointer<Char> resultPtr = nullptr;
    try {
      resultPtr = options == null
          ? htm_convert(htmlPointer, htmlAllocation.length)
          : _convertWithOptions(
              htmlPointer,
              htmlAllocation.length,
              optionsJson!,
            );

      if (resultPtr == nullptr) {
        throw Exception('Failed to convert HTML to Markdown');
      }

      return resultPtr.cast<Utf8>().toDartString();
    } finally {
      if (resultPtr != nullptr) htm_free_string(resultPtr);
    }
  } finally {
    calloc.free(htmlPointer);
  }
}

Pointer<Char> _convertWithOptions(
  Pointer<Char> htmlPointer,
  int length,
  String optionsJson,
) {
  final optionsPointer = optionsJson.toNativeUtf8().cast<Char>();

  try {
    return htm_convert_with_options(htmlPointer, length, optionsPointer);
  } finally {
    calloc.free(optionsPointer);
  }
}

/// Converts an HTML string to Markdown and extracts metadata.
///
/// [html] is the HTML string to convert.
/// [options] is the optional configuration for the conversion.
/// [metadataConfig] is the optional configuration for metadata extraction.
ConversionResult htmlToMarkdownWithMetadata(
  String html, {
  ConversionOptions? options,
  MetadataConfig? metadataConfig,
}) {
  final optionsJson = options != null ? jsonEncode(options.toJson()) : null;
  final metadataJson = metadataConfig != null
      ? jsonEncode(metadataConfig.toJson())
      : null;
  final htmlAllocation = _encodeHtml(html);
  final htmlPointer = htmlAllocation.pointer;

  Pointer<Char> optionsPointer = nullptr;
  Pointer<Char> metadataPointer = nullptr;

  try {
    optionsPointer = optionsJson?.toNativeUtf8().cast<Char>() ?? nullptr;
    metadataPointer = metadataJson?.toNativeUtf8().cast<Char>() ?? nullptr;
    Pointer<Char> resultPtr = nullptr;
    try {
      resultPtr = htm_convert_with_metadata(
        htmlPointer,
        htmlAllocation.length,
        optionsPointer,
        metadataPointer,
      );

      if (resultPtr == nullptr) {
        throw Exception('Failed to convert HTML to Markdown with metadata');
      }

      final resultString = resultPtr.cast<Utf8>().toDartString();

      final resultMap = jsonDecode(resultString) as Map<String, dynamic>;
      final markdown = resultMap['markdown'] as String;
      final metadataJsonMap = resultMap['metadata'] as Map<String, dynamic>?;

      return ConversionResult(
        markdown: markdown,
        metadata: metadataJsonMap != null
            ? DocumentMetadata.fromJson(metadataJsonMap)
            : null,
      );
    } finally {
      if (resultPtr != nullptr) htm_free_string(resultPtr);
    }
  } finally {
    if (optionsPointer != nullptr) calloc.free(optionsPointer);
    if (metadataPointer != nullptr) calloc.free(metadataPointer);
    calloc.free(htmlPointer);
  }
}

/// Converts an HTML string to Markdown and extracts inline images.
///
/// [html] is the HTML string to convert.
/// [options] is the optional configuration for the conversion.
/// [imageConfig] is the optional configuration for inline image handling.
InlineImagesResult htmlToMarkdownWithInlineImages(
  String html, {
  ConversionOptions? options,
  InlineImageConfig? imageConfig,
}) {
  final optionsJson = options != null ? jsonEncode(options.toJson()) : null;
  final imageConfigJson = imageConfig != null
      ? jsonEncode(imageConfig.toJson())
      : null;
  final htmlAllocation = _encodeHtml(html);
  final htmlPointer = htmlAllocation.pointer;

  Pointer<Char> optionsPointer = nullptr;
  Pointer<Char> imageConfigPointer = nullptr;

  try {
    optionsPointer = optionsJson?.toNativeUtf8().cast<Char>() ?? nullptr;
    imageConfigPointer =
        imageConfigJson?.toNativeUtf8().cast<Char>() ?? nullptr;
    Pointer<Char> resultPtr = nullptr;
    try {
      resultPtr = htm_convert_with_inline_images(
        htmlPointer,
        htmlAllocation.length,
        optionsPointer,
        imageConfigPointer,
      );

      if (resultPtr == nullptr) {
        throw Exception(
          'Failed to convert HTML to Markdown with inline images',
        );
      }

      final resultString = resultPtr.cast<Utf8>().toDartString();
      final resultMap = jsonDecode(resultString) as Map<String, dynamic>;
      return InlineImagesResult.fromJson(resultMap);
    } finally {
      if (resultPtr != nullptr) htm_free_string(resultPtr);
    }
  } finally {
    if (optionsPointer != nullptr) calloc.free(optionsPointer);
    if (imageConfigPointer != nullptr) calloc.free(imageConfigPointer);
    calloc.free(htmlPointer);
  }
}
