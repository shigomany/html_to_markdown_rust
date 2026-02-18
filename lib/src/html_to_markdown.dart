import 'dart:convert';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:html_to_markdown_rust/src/bindings.g.dart';
import 'package:html_to_markdown_rust/src/conversion_options.dart';

/// Converts an HTML string to Markdown.
///
/// [html] is the HTML string to convert.
/// [options] is the optional configuration for the conversion.
String htmlToMarkdown(String html, [ConversionOptions? options]) {
  final htmlPointer = html.toNativeUtf8().cast<Char>();

  final resultPtr = options == null
      ? htm_convert(htmlPointer, html.length)
      : _convertWithOptions(htmlPointer, html.length, options);

  if (resultPtr == nullptr) {
    throw Exception('Failed to convert HTML to Markdown');
  }

  final markdown = resultPtr.cast<Utf8>().toDartString();
  htm_free_string(resultPtr);
  return markdown;
}

Pointer<Char> _convertWithOptions(
  Pointer<Char> htmlPointer,
  int length,
  ConversionOptions options,
) {
  final optionsJson = jsonEncode(options.toJson());
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
  final htmlPointer = html.toNativeUtf8().cast<Char>();
  final optionsJson = options != null ? jsonEncode(options.toJson()) : null;
  final metadataJson = metadataConfig != null
      ? jsonEncode(metadataConfig.toJson())
      : null;

  final optionsPointer = optionsJson?.toNativeUtf8().cast<Char>() ?? nullptr;
  final metadataPointer = metadataJson?.toNativeUtf8().cast<Char>() ?? nullptr;

  try {
    final resultPtr = htm_convert_with_metadata(
      htmlPointer,
      html.length,
      optionsPointer,
      metadataPointer,
    );

    if (resultPtr == nullptr) {
      throw Exception('Failed to convert HTML to Markdown with metadata');
    }

    final resultString = resultPtr.cast<Utf8>().toDartString();
    htm_free_string(resultPtr);

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
    if (optionsPointer != nullptr) calloc.free(optionsPointer);
    if (metadataPointer != nullptr) calloc.free(metadataPointer);
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
  final htmlPointer = html.toNativeUtf8().cast<Char>();
  final optionsJson = options != null ? jsonEncode(options.toJson()) : null;
  final imageConfigJson = imageConfig != null
      ? jsonEncode(imageConfig.toJson())
      : null;

  final optionsPointer = optionsJson?.toNativeUtf8().cast<Char>() ?? nullptr;
  final imageConfigPointer =
      imageConfigJson?.toNativeUtf8().cast<Char>() ?? nullptr;

  try {
    final resultPtr = htm_convert_with_inline_images(
      htmlPointer,
      html.length,
      optionsPointer,
      imageConfigPointer,
    );

    if (resultPtr == nullptr) {
      throw Exception('Failed to convert HTML to Markdown with inline images');
    }

    final resultString = resultPtr.cast<Utf8>().toDartString();
    htm_free_string(resultPtr);

    final resultMap = jsonDecode(resultString) as Map<String, dynamic>;
    return InlineImagesResult.fromJson(resultMap);
  } finally {
    if (optionsPointer != nullptr) calloc.free(optionsPointer);
    if (imageConfigPointer != nullptr) calloc.free(imageConfigPointer);
  }
}
