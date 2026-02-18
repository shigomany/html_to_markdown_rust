import 'dart:convert';

/// Style for Markdown headings.
enum HeadingStyle {
  /// ATX style hashtags (e.g. # Heading)
  atx,

  /// Setext style underlines (e.g. Heading\n=======)
  setext,
}

/// Type of indentation for lists.
enum ListIndentType {
  /// Use spaces for indentation.
  spaces,

  /// Use tabs for indentation.
  tabs,
}

/// Style for code blocks.
enum CodeBlockStyle {
  /// Use fence (```) for code blocks.
  backticks,

  /// Use indentation (4 spaces) for code blocks.
  indented,

  /// Use tilde (~~~) for code blocks.
  tilde,
}

/// Style for handling newlines.
enum NewlineStyle {
  /// Use backslash for hard line breaks.
  backslash,

  /// Use two trailing spaces for hard line breaks.
  trailingSpaces,

  /// Preserve newlines as is.
  preserve,
}

/// Style for highlighting.
enum HighlightStyle {
  /// Use double equals (==text==) for highlighting.
  doubleEqual,

  /// Use HTML mark tag (<mark>text</mark>) for highlighting.
  htmlMark,

  /// Use single asterisk (*text*) for highlighting (often italic).
  asterisk,
}

/// Mode for handling white spaces.
enum WhitespaceMode {
  /// Normalize whitespace (collapse multiple spaces).
  normalize,

  /// Preserve whitespace as is.
  preserve,

  /// Condense whitespace suitable for Markdown.
  condense,
}

/// Presets for HTML preprocessing options.
enum PreprocessingPreset {
  /// No preprocessing.
  none,

  /// Minimal preprocessing.
  minimal,

  /// Standard preprocessing.
  standard,

  /// Aggressive preprocessing.
  aggressive,
}

/// Configuration options for HTML preprocessing before conversion.
class PreprocessingOptions {
  /// Whether preprocessing is enabled.
  final bool enabled;

  /// The preset configuration to use.
  final PreprocessingPreset preset;

  /// Whether to remove navigation elements (<nav>).
  final bool removeNavigation;

  /// Whether to remove form elements (<form>).
  final bool removeForms;

  /// Whether to remove script elements (<script>).
  final bool removeScripts;

  /// Whether to remove style elements (<style>).
  final bool removeStyles;

  /// Whether to remove comments (<!-- -->).
  final bool removeComments;

  /// Whether to remove hidden elements (style="display: none", etc.).
  final bool removeHiddenElements;

  /// Creates a new [PreprocessingOptions] instance.
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

  /// Converts the options to a JSON map.
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

/// Main configuration options for converting HTML to Markdown.
class ConversionOptions {
  /// The style to use for headings.
  final HeadingStyle headingStyle;

  /// The width of indentation for lists.
  final int listIndentWidth;

  /// The character to use for list indentation.
  final ListIndentType listIndentType;

  /// The character to use for unordered list bullets.
  final String bullets;

  /// The symbol to use for strong emphasis (bold).
  final String strongEmSymbol;

  /// Whether to escape asterisks.
  final bool escapeAsterisks;

  /// Whether to escape underscores.
  final bool escapeUnderscores;

  /// Whether to escape miscellaneous characters.
  final bool escapeMisc;

  /// The style to use for newlines.
  final NewlineStyle newlineStyle;

  /// The style to use for code blocks.
  final CodeBlockStyle codeBlockStyle;

  /// The style to use for text highlighting.
  final HighlightStyle highlightStyle;

  /// How to handle whitespace.
  final WhitespaceMode whitespaceMode;

  /// Whether to skip images in the output.
  final bool skipImages;

  /// Whether to skip links in the output.
  final bool skipLinks;

  /// List of tags to preserve as HTML.
  final List<String> preserveTags;

  /// List of tags to strip (remove tags but keep content).
  final List<String> stripTags;

  /// Preprocessing options to apply before conversion.
  final PreprocessingOptions preprocessing;

  /// Creates a new [ConversionOptions] instance.
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

  /// Converts the options to a JSON map.
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

  /// Converts the options to a JSON string.
  String toJsonString() => toJson().toString();
}

/// Configuration for metadata extraction.
class MetadataConfig {
  /// Whether to extract the document title.
  final bool extractTitle;

  /// Whether to extract the document description.
  final bool extractDescription;

  /// Whether to extract keywords.
  final bool extractKeywords;

  /// Whether to extract headers.
  final bool extractHeaders;

  /// Whether to extract links.
  final bool extractLinks;

  /// Whether to extract images.
  final bool extractImages;

  /// Whether to extract structured data (JSON-LD).
  final bool extractStructuredData;

  /// Maximum size for structured data in bytes.
  final int maxStructuredDataSize;

  /// Creates a new [MetadataConfig] instance.
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

  /// Converts the config to a JSON map.
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

/// Metadata about a link found in the document.
class LinkMetadata {
  /// The destination URL of the link.
  final String? href;

  /// The text content of the link.
  final String? text;

  /// The title attribute of the link.
  final String? title;

  /// Whether the link points to an external resource.
  final bool isExternal;

  /// Whether the link is an image link.
  final bool isImage;

  /// Creates a new [LinkMetadata] instance.
  const LinkMetadata({
    this.href,
    this.text,
    this.title,
    this.isExternal = false,
    this.isImage = false,
  });

  /// Creates a [LinkMetadata] instance from a JSON map.
  factory LinkMetadata.fromJson(Map<String, dynamic> json) => LinkMetadata(
    href: json['href'] as String?,
    text: json['text'] as String?,
    title: json['title'] as String?,
    isExternal: json['is_external'] as bool? ?? false,
    isImage: json['is_image'] as bool? ?? false,
  );
}

/// Metadata about an image found in the document.
class ImageMetadata {
  /// The source URL of the image.
  final String? src;

  /// The alternative text of the image.
  final String? alt;

  /// The title attribute of the image.
  final String? title;

  /// The width of the image.
  final int? width;

  /// The height of the image.
  final int? height;

  /// Creates a new [ImageMetadata] instance.
  const ImageMetadata({
    this.src,
    this.alt,
    this.title,
    this.width,
    this.height,
  });

  /// Creates an [ImageMetadata] instance from a JSON map.
  factory ImageMetadata.fromJson(Map<String, dynamic> json) => ImageMetadata(
    src: json['src'] as String?,
    alt: json['alt'] as String?,
    title: json['title'] as String?,
    width: json['width'] as int?,
    height: json['height'] as int?,
  );
}

/// Metadata about a header found in the document.
class HeaderMetadata {
  /// The heading level (1-6).
  final int level;

  /// The text content of the header.
  final String text;

  /// The ID attribute of the header.
  final String? id;

  /// Creates a new [HeaderMetadata] instance.
  const HeaderMetadata({required this.level, required this.text, this.id});

  /// Creates a [HeaderMetadata] instance from a JSON map.
  factory HeaderMetadata.fromJson(Map<String, dynamic> json) => HeaderMetadata(
    level: json['level'] as int,
    text: json['text'] as String,
    id: json['id'] as String?,
  );
}

/// Collected metadata from the document.
class DocumentMetadata {
  /// The document title.
  final String? title;

  /// The document description.
  final String? description;

  /// List of keywords extracted from metadata.
  final List<String>? keywords;

  /// List of headers found in the document.
  final List<HeaderMetadata>? headers;

  /// List of links found in the document.
  final List<LinkMetadata>? links;

  /// List of images found in the document.
  final List<ImageMetadata>? images;

  /// Structured data (JSON-LD) found in the document.
  final List<Map<String, dynamic>>? structuredData;

  /// Creates a new [DocumentMetadata] instance.
  const DocumentMetadata({
    this.title,
    this.description,
    this.keywords,
    this.headers,
    this.links,
    this.images,
    this.structuredData,
  });

  /// Creates a [DocumentMetadata] instance from a JSON map.
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

/// Result of an HTML to Markdown conversion.
class ConversionResult {
  /// The generated Markdown text.
  final String markdown;

  /// Extracted metadata, if requested.
  final DocumentMetadata? metadata;

  /// Creates a new [ConversionResult] instance.
  const ConversionResult({required this.markdown, this.metadata});
}

/// Configuration for handling inline images.
class InlineImageConfig {
  /// Maximum size of decoded image in bytes.
  final int maxDecodedSizeBytes;

  /// Optional prefix for filenames.
  final String? filenamePrefix;

  /// Whether to capture SVG images.
  final bool captureSvg;

  /// Whether to infer image dimensions.
  final bool inferDimensions;

  /// Creates a new [InlineImageConfig] instance.
  const InlineImageConfig({
    this.maxDecodedSizeBytes = 5242880,
    this.filenamePrefix,
    this.captureSvg = true,
    this.inferDimensions = false,
  });

  /// Converts the config to a JSON map.
  Map<String, dynamic> toJson() => {
    'maxDecodedSizeBytes': maxDecodedSizeBytes,
    if (filenamePrefix != null) 'filenamePrefix': filenamePrefix,
    'captureSvg': captureSvg,
    'inferDimensions': inferDimensions,
  };
}

/// Supported formats for inline images.
enum InlineImageFormat {
  /// PNG format.
  png,

  /// JPEG format.
  jpeg,

  /// GIF format.
  gif,

  /// WebP format.
  webp,

  /// SVG format.
  svg,

  /// BMP format.
  bmp,

  /// ICO format.
  ico,

  /// Unknown format.
  unknown,
}

/// Source type of an inline image.
enum InlineImageSource {
  /// Image source is a data URI.
  dataUri,

  /// Image source is an SVG element.
  svgElement,
}

/// Represents an inline image extracted from the HTML.
class InlineImage {
  /// Base64 encoded image data.
  final String dataBase64;

  /// Format of the image.
  final InlineImageFormat format;

  /// Optional filename for the image.
  final String? filename;

  /// Optional description (alt text).
  final String? description;

  /// Image width if available.
  final int? width;

  /// Image height if available.
  final int? height;

  /// Source of the image (data URI or SVG element).
  final InlineImageSource source;

  /// Additional attributes found on the image element.
  final Map<String, String> attributes;

  /// Creates a new [InlineImage] instance.
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

  /// Creates an [InlineImage] instance from a JSON map.
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

  /// The decoded bytes of the image data.
  List<int> get dataBytes => base64Decode(dataBase64);
}

/// Warning generated during inline image processing.
class InlineImageWarning {
  /// The index of the warning.
  final int index;

  /// The warning message.
  final String message;

  /// Creates a new [InlineImageWarning] instance.
  const InlineImageWarning({required this.index, required this.message});

  /// Creates an [InlineImageWarning] instance from a JSON map.
  factory InlineImageWarning.fromJson(Map<String, dynamic> json) =>
      InlineImageWarning(
        index: json['index'] as int? ?? 0,
        message: json['message'] as String? ?? '',
      );
}

/// Result of an HTML to Markdown conversion with inline images.
class InlineImagesResult {
  /// The generated Markdown text.
  final String markdown;

  /// List of inline images found in the document.
  final List<InlineImage> inlineImages;

  /// List of warnings generated during processing.
  final List<InlineImageWarning> warnings;

  /// Creates a new [InlineImagesResult] instance.
  const InlineImagesResult({
    required this.markdown,
    required this.inlineImages,
    required this.warnings,
  });

  /// Creates an [InlineImagesResult] instance from a JSON map.
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
