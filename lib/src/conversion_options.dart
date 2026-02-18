enum HeadingStyle { atx, setext }

enum ListIndentType { spaces, tabs }

enum CodeBlockStyle { backticks, indented, tilde }

enum NewlineStyle { backslash, trailingSpaces, preserve }

enum HighlightStyle { doubleEqual, htmlMark, asterisk }

enum WhitespaceMode { normalize, preserve, condense }

enum PreprocessingPreset { none, minimal, standard, aggressive }

class PreprocessingOptions {
  final bool enabled;
  final PreprocessingPreset preset;
  final bool removeNavigation;
  final bool removeForms;
  final bool removeScripts;
  final bool removeStyles;
  final bool removeComments;
  final bool removeHiddenElements;

  const PreprocessingOptions({
    this.enabled = false,
    this.preset = PreprocessingPreset.none,
    this.removeNavigation = false,
    this.removeForms = false,
    this.removeScripts = true,
    this.removeStyles = true,
    this.removeComments = true,
    this.removeHiddenElements = true,
  });

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'preset': preset.name,
    'removeNavigation': removeNavigation,
    'removeForms': removeForms,
    'removeScripts': removeScripts,
    'removeStyles': removeStyles,
    'removeComments': removeComments,
    'removeHiddenElements': removeHiddenElements,
  };
}

class ConversionOptions {
  final HeadingStyle headingStyle;
  final int listIndentWidth;
  final ListIndentType listIndentType;
  final String bullets;
  final String strongEmSymbol;
  final bool escapeAsterisks;
  final bool escapeUnderscores;
  final bool escapeMisc;
  final NewlineStyle newlineStyle;
  final CodeBlockStyle codeBlockStyle;
  final HighlightStyle highlightStyle;
  final WhitespaceMode whitespaceMode;
  final bool skipImages;
  final bool skipLinks;
  final List<String> preserveTags;
  final List<String> stripTags;
  final PreprocessingOptions preprocessing;

  const ConversionOptions({
    this.headingStyle = HeadingStyle.atx,
    this.listIndentWidth = 4,
    this.listIndentType = ListIndentType.spaces,
    this.bullets = '-',
    this.strongEmSymbol = '*',
    this.escapeAsterisks = false,
    this.escapeUnderscores = false,
    this.escapeMisc = false,
    this.newlineStyle = NewlineStyle.backslash,
    this.codeBlockStyle = CodeBlockStyle.backticks,
    this.highlightStyle = HighlightStyle.doubleEqual,
    this.whitespaceMode = WhitespaceMode.normalize,
    this.skipImages = false,
    this.skipLinks = false,
    this.preserveTags = const [],
    this.stripTags = const [],
    this.preprocessing = const PreprocessingOptions(),
  });

  Map<String, dynamic> toJson() => {
    'headingStyle': headingStyle.name,
    'listIndentWidth': listIndentWidth,
    'listIndentType': listIndentType.name,
    'bullets': bullets,
    'strongEmSymbol': strongEmSymbol,
    'escapeAsterisks': escapeAsterisks,
    'escapeUnderscores': escapeUnderscores,
    'escapeMisc': escapeMisc,
    'newlineStyle': newlineStyle.name,
    'codeBlockStyle': codeBlockStyle.name,
    'highlightStyle': highlightStyle.name,
    'whitespaceMode': whitespaceMode.name,
    'skipImages': skipImages,
    'skipLinks': skipLinks,
    'preserveTags': preserveTags,
    'stripTags': stripTags,
    'preprocessing': preprocessing.toJson(),
  };

  String toJsonString() => toJson().toString();
}

class MetadataConfig {
  final bool extractTitle;
  final bool extractDescription;
  final bool extractKeywords;
  final bool extractHeaders;
  final bool extractLinks;
  final bool extractImages;
  final bool extractStructuredData;
  final int maxStructuredDataSize;

  const MetadataConfig({
    this.extractTitle = true,
    this.extractDescription = true,
    this.extractKeywords = true,
    this.extractHeaders = true,
    this.extractLinks = true,
    this.extractImages = true,
    this.extractStructuredData = true,
    this.maxStructuredDataSize = 1048576,
  });

  Map<String, dynamic> toJson() => {
    'extractTitle': extractTitle,
    'extractDescription': extractDescription,
    'extractKeywords': extractKeywords,
    'extractHeaders': extractHeaders,
    'extractLinks': extractLinks,
    'extractImages': extractImages,
    'extractStructuredData': extractStructuredData,
    'maxStructuredDataSize': maxStructuredDataSize,
  };
}

class LinkMetadata {
  final String? href;
  final String? text;
  final String? title;
  final bool isExternal;
  final bool isImage;

  const LinkMetadata({
    this.href,
    this.text,
    this.title,
    this.isExternal = false,
    this.isImage = false,
  });

  factory LinkMetadata.fromJson(Map<String, dynamic> json) => LinkMetadata(
    href: json['href'] as String?,
    text: json['text'] as String?,
    title: json['title'] as String?,
    isExternal: json['is_external'] as bool? ?? false,
    isImage: json['is_image'] as bool? ?? false,
  );
}

class ImageMetadata {
  final String? src;
  final String? alt;
  final String? title;
  final int? width;
  final int? height;

  const ImageMetadata({
    this.src,
    this.alt,
    this.title,
    this.width,
    this.height,
  });

  factory ImageMetadata.fromJson(Map<String, dynamic> json) => ImageMetadata(
    src: json['src'] as String?,
    alt: json['alt'] as String?,
    title: json['title'] as String?,
    width: json['width'] as int?,
    height: json['height'] as int?,
  );
}

class HeaderMetadata {
  final int level;
  final String text;
  final String? id;

  const HeaderMetadata({required this.level, required this.text, this.id});

  factory HeaderMetadata.fromJson(Map<String, dynamic> json) => HeaderMetadata(
    level: json['level'] as int,
    text: json['text'] as String,
    id: json['id'] as String?,
  );
}

class DocumentMetadata {
  final String? title;
  final String? description;
  final List<String>? keywords;
  final List<HeaderMetadata>? headers;
  final List<LinkMetadata>? links;
  final List<ImageMetadata>? images;
  final List<Map<String, dynamic>>? structuredData;

  const DocumentMetadata({
    this.title,
    this.description,
    this.keywords,
    this.headers,
    this.links,
    this.images,
    this.structuredData,
  });

  factory DocumentMetadata.fromJson(Map<String, dynamic> json) {
    final document = json['document'] as Map<String, dynamic>? ?? json;

    List<Map<String, dynamic>>? parseStructuredData(dynamic data) {
      if (data == null) return null;
      if (data is List) {
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
      return null;
    }

    return DocumentMetadata(
      title: document['title'] as String?,
      description: document['description'] as String?,
      keywords: (document['keywords'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      headers: (json['headers'] as List<dynamic>?)
          ?.map((e) => HeaderMetadata.fromJson(e as Map<String, dynamic>))
          .toList(),
      links: (json['links'] as List<dynamic>?)
          ?.map((e) => LinkMetadata.fromJson(e as Map<String, dynamic>))
          .toList(),
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => ImageMetadata.fromJson(e as Map<String, dynamic>))
          .toList(),
      structuredData: parseStructuredData(json['structured_data']),
    );
  }
}

class ConversionResult {
  final String markdown;
  final DocumentMetadata? metadata;

  const ConversionResult({required this.markdown, this.metadata});
}

class InlineImageConfig {
  final int maxDecodedSizeBytes;
  final String? filenamePrefix;
  final bool captureSvg;
  final bool inferDimensions;

  const InlineImageConfig({
    this.maxDecodedSizeBytes = 5242880,
    this.filenamePrefix,
    this.captureSvg = true,
    this.inferDimensions = false,
  });

  Map<String, dynamic> toJson() => {
    'maxDecodedSizeBytes': maxDecodedSizeBytes,
    if (filenamePrefix != null) 'filenamePrefix': filenamePrefix,
    'captureSvg': captureSvg,
    'inferDimensions': inferDimensions,
  };
}

enum InlineImageFormat { png, jpeg, gif, webp, svg, bmp, ico, unknown }

enum InlineImageSource { dataUri, svgElement }

class InlineImage {
  final String dataBase64;
  final InlineImageFormat format;
  final String? filename;
  final String? description;
  final int? width;
  final int? height;
  final InlineImageSource source;
  final Map<String, String> attributes;

  const InlineImage({
    required this.dataBase64,
    required this.format,
    this.filename,
    this.description,
    this.width,
    this.height,
    required this.source,
    this.attributes = const {},
  });

  factory InlineImage.fromJson(Map<String, dynamic> json) {
    final formatStr = json['format'] as String? ?? 'Unknown';
    final sourceStr = json['source'] as String? ?? 'DataUri';

    InlineImageFormat parseFormat(String s) {
      return InlineImageFormat.values.firstWhere(
        (e) => e.name.toLowerCase() == s.toLowerCase(),
        orElse: () => InlineImageFormat.unknown,
      );
    }

    InlineImageSource parseSource(String s) {
      return InlineImageSource.values.firstWhere(
        (e) => e.name.toLowerCase() == s.toLowerCase(),
        orElse: () => InlineImageSource.dataUri,
      );
    }

    final dims = json['dimensions'] as Map<String, dynamic>?;

    return InlineImage(
      dataBase64: json['data'] as String? ?? '',
      format: parseFormat(formatStr),
      filename: json['filename'] as String?,
      description: json['description'] as String?,
      width: dims?['width'] as int?,
      height: dims?['height'] as int?,
      source: parseSource(sourceStr),
      attributes:
          (json['attributes'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v.toString()),
          ) ??
          {},
    );
  }

  List<int> get dataBytes => _decodeBase64(dataBase64);

  static List<int> _decodeBase64(String base64) {
    final chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    final result = <int>[];
    var buffer = 0;
    var bits = 0;

    for (final char
        in base64.replaceAll(RegExp(r'[^A-Za-z0-9+/]'), '').split('')) {
      if (char == '=') break;
      buffer = (buffer << 6) | chars.indexOf(char);
      bits += 6;
      if (bits >= 8) {
        bits -= 8;
        result.add((buffer >> bits) & 0xFF);
      }
    }
    return result;
  }
}

class InlineImageWarning {
  final int index;
  final String message;

  const InlineImageWarning({required this.index, required this.message});

  factory InlineImageWarning.fromJson(Map<String, dynamic> json) =>
      InlineImageWarning(
        index: json['index'] as int? ?? 0,
        message: json['message'] as String? ?? '',
      );
}

class InlineImagesResult {
  final String markdown;
  final List<InlineImage> inlineImages;
  final List<InlineImageWarning> warnings;

  const InlineImagesResult({
    required this.markdown,
    required this.inlineImages,
    required this.warnings,
  });

  factory InlineImagesResult.fromJson(Map<String, dynamic> json) =>
      InlineImagesResult(
        markdown: json['markdown'] as String? ?? '',
        inlineImages:
            (json['inline_images'] as List<dynamic>?)
                ?.map((e) => InlineImage.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        warnings:
            (json['warnings'] as List<dynamic>?)
                ?.map(
                  (e) => InlineImageWarning.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            [],
      );
}
