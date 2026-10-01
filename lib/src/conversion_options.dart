import 'dart:convert';

/// Style for Markdown headings.
enum HeadingStyle {
  /// ATX style hashtags (e.g. # Heading)
  atx,

  /// Setext style underlines (e.g. Heading\n=======)
  setext,

  /// ATX style with closing hashtags (e.g. # Heading #).
  atxClosed,
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
  @Deprecated(
    'The upstream engine has no preserve newline style; this maps to spaces.',
  )
  preserve,
}

/// Style for highlighting.
enum HighlightStyle {
  /// Use double equals (==text==) for highlighting.
  doubleEqual,

  /// Use HTML mark tag (<mark>text</mark>) for highlighting.
  htmlMark,

  /// Use single asterisk (*text*) for highlighting (often italic).
  @Deprecated(
    'The upstream engine has no asterisk highlight style; this maps to bold.',
  )
  asterisk,

  /// Render highlighted text as bold.
  bold,

  /// Remove highlight markup while preserving its text.
  none,
}

/// Target format for converted output.
enum OutputFormat {
  /// CommonMark-compatible Markdown.
  markdown,

  /// Djot lightweight markup.
  djot,

  /// Visible text without markup.
  plain,
}

/// Style used to render links.
enum LinkStyle {
  /// Render each link with its destination inline.
  inline,

  /// Render links using numbered reference definitions.
  reference,
}

/// Strategy used to escape link and image destinations.
enum UrlEscapeStyle {
  /// Wrap destinations containing whitespace in angle brackets.
  angle,

  /// Percent-encode characters outside the safe URL set.
  percent,
}

/// Conversion engine strategy.
enum TierStrategy {
  /// Select the fastest compatible conversion tier automatically.
  auto,

  /// Always use the full DOM-walking conversion tier.
  tier2,
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

  /// Retained for source compatibility.
  ///
  /// Script removal is fixed by the upstream sanitizer and cannot be configured.
  @Deprecated('Unsupported by html-to-markdown-rs 3.x.')
  final bool removeScripts;

  /// Retained for source compatibility.
  ///
  /// Style removal is fixed by the upstream sanitizer and cannot be configured.
  @Deprecated('Unsupported by html-to-markdown-rs 3.x.')
  final bool removeStyles;

  /// Retained for source compatibility.
  ///
  /// Comment removal is fixed by the upstream sanitizer and cannot be configured.
  @Deprecated('Unsupported by html-to-markdown-rs 3.x.')
  final bool removeComments;

  /// Retained for source compatibility.
  ///
  /// Hidden-element removal is fixed by the upstream sanitizer and cannot be
  /// configured.
  @Deprecated('Unsupported by html-to-markdown-rs 3.x.')
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
    'preset': switch (preset) {
      // Upstream has no disabled preset. Minimal is the least aggressive value
      // and `enabled` remains the authoritative switch.
      PreprocessingPreset.none => 'minimal',
      _ => preset.name,
    },
    'remove_navigation': removeNavigation,
    'remove_forms': removeForms,
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

  /// Whether to escape ASCII characters with special markup meaning.
  final bool escapeAscii;

  /// Default language for fenced code blocks without a language hint.
  final String codeLanguage;

  /// Whether links whose label equals their absolute URI use `<URI>` syntax.
  final bool autolinks;

  /// Whether a URL-labeled link without a title uses its URL as the title.
  final bool defaultTitle;

  /// Whether line breaks inside table cells are retained.
  final bool brInTables;

  /// Whether tables omit alignment padding.
  final bool compactTables;

  /// The style to use for newlines.
  final NewlineStyle newlineStyle;

  /// The style to use for code blocks.
  final CodeBlockStyle codeBlockStyle;

  /// The style to use for text highlighting.
  final HighlightStyle highlightStyle;

  /// Whether document metadata is extracted during conversion.
  final bool extractMetadata;

  /// How to handle whitespace.
  final WhitespaceMode whitespaceMode;

  /// Whether all newlines are removed from the converted output.
  final bool stripNewlines;

  /// Whether long output lines are wrapped.
  final bool wrap;

  /// Maximum line width when [wrap] is enabled. Zero disables the limit.
  final int wrapWidth;

  /// Whether the entire document is converted as inline content.
  final bool convertAsInline;

  /// Markdown notation used for subscript text.
  final String subSymbol;

  /// Markdown notation used for superscript text.
  final String supSymbol;

  /// Tags whose child images remain inline.
  final List<String> keepInlineImagesIn;

  /// Whether to skip images in the output.
  final bool skipImages;

  /// Whether to skip links in the output.
  final bool skipLinks;

  /// Target output format.
  final OutputFormat outputFormat;

  /// Link rendering style.
  final LinkStyle linkStyle;

  /// URL destination escaping style.
  final UrlEscapeStyle urlEscapeStyle;

  /// Whether the result includes the structured document tree.
  final bool includeDocumentStructure;

  /// Whether inline image payloads are extracted during conversion.
  final bool extractImages;

  /// Maximum decoded inline image size in bytes.
  final int maxImageSize;

  /// Whether inline SVG elements are captured as images.
  final bool captureSvg;

  /// Whether image dimensions are inferred from image data.
  final bool inferDimensions;

  /// Maximum DOM traversal depth, or `null` for the native safe default.
  ///
  /// The native engine may clamp large values to its platform safety limit.
  final int? maxDepth;

  /// CSS selectors whose matching elements and descendants are excluded.
  final List<String> excludeSelectors;

  /// Base URL used to resolve relative link and image destinations.
  final String? baseUrl;

  /// Conversion engine strategy.
  final TierStrategy tierStrategy;

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
    this.escapeAscii = false,
    this.codeLanguage = '',
    this.autolinks = true,
    this.defaultTitle = false,
    this.brInTables = false,
    this.compactTables = false,
    this.newlineStyle = NewlineStyle.backslash,
    this.codeBlockStyle = CodeBlockStyle.backticks,
    this.highlightStyle = HighlightStyle.doubleEqual,
    this.extractMetadata = true,
    this.whitespaceMode = WhitespaceMode.normalize,
    this.stripNewlines = false,
    this.wrap = false,
    this.wrapWidth = 80,
    this.convertAsInline = false,
    this.subSymbol = '',
    this.supSymbol = '',
    this.keepInlineImagesIn = const [],
    this.skipImages = false,
    this.skipLinks = false,
    this.outputFormat = OutputFormat.markdown,
    this.linkStyle = LinkStyle.inline,
    this.urlEscapeStyle = UrlEscapeStyle.angle,
    this.includeDocumentStructure = false,
    this.extractImages = false,
    this.maxImageSize = 5242880,
    this.captureSvg = false,
    this.inferDimensions = true,
    this.maxDepth,
    this.excludeSelectors = const [],
    this.baseUrl,
    this.tierStrategy = TierStrategy.auto,
    this.preserveTags = const [],
    this.stripTags = const [],
    this.preprocessing = const PreprocessingOptions(),
  });

  /// Converts the options to a JSON map.
  Map<String, dynamic> toJson() {
    if (listIndentWidth < 0) {
      throw RangeError.value(
        listIndentWidth,
        'listIndentWidth',
        'Must be non-negative.',
      );
    }
    if (wrapWidth < 0) {
      throw RangeError.value(wrapWidth, 'wrapWidth', 'Must be non-negative.');
    }
    if (maxImageSize < 0 || (extractImages && maxImageSize == 0)) {
      throw RangeError.value(
        maxImageSize,
        'maxImageSize',
        extractImages
            ? 'Must be positive when extractImages is enabled.'
            : 'Must be non-negative.',
      );
    }
    if (maxDepth != null && maxDepth! < 0) {
      throw RangeError.value(maxDepth!, 'maxDepth', 'Must be non-negative.');
    }

    return {
      'heading_style': switch (headingStyle) {
        HeadingStyle.atx => 'atx',
        HeadingStyle.setext => 'underlined',
        HeadingStyle.atxClosed => 'atxclosed',
      },
      'list_indent_width': listIndentWidth,
      'list_indent_type': listIndentType.name,
      'bullets': bullets,
      'strong_em_symbol': strongEmSymbol,
      'escape_asterisks': escapeAsterisks,
      'escape_underscores': escapeUnderscores,
      'escape_misc': escapeMisc,
      'escape_ascii': escapeAscii,
      'code_language': codeLanguage,
      'autolinks': autolinks,
      'default_title': defaultTitle,
      'br_in_tables': brInTables,
      'compact_tables': compactTables,
      'newline_style': switch (newlineStyle) {
        NewlineStyle.backslash => 'backslash',
        NewlineStyle.trailingSpaces || NewlineStyle.preserve => 'spaces',
      },
      'code_block_style': switch (codeBlockStyle) {
        CodeBlockStyle.tilde => 'tildes',
        _ => codeBlockStyle.name,
      },
      'highlight_style': switch (highlightStyle) {
        HighlightStyle.doubleEqual => 'doubleequal',
        HighlightStyle.htmlMark => 'html',
        HighlightStyle.asterisk || HighlightStyle.bold => 'bold',
        HighlightStyle.none => 'none',
      },
      'extract_metadata': extractMetadata,
      'whitespace_mode': switch (whitespaceMode) {
        WhitespaceMode.preserve => 'strict',
        WhitespaceMode.normalize || WhitespaceMode.condense => 'normalized',
      },
      'strip_newlines': stripNewlines,
      'wrap': wrap,
      'wrap_width': wrapWidth,
      'convert_as_inline': convertAsInline,
      'sub_symbol': subSymbol,
      'sup_symbol': supSymbol,
      'keep_inline_images_in': keepInlineImagesIn,
      'skip_images': skipImages,
      'skip_links': skipLinks,
      'output_format': outputFormat.name,
      'link_style': linkStyle.name,
      'url_escape_style': urlEscapeStyle.name,
      'include_document_structure': includeDocumentStructure,
      'extract_images': extractImages,
      'max_image_size': maxImageSize,
      'capture_svg': captureSvg,
      'infer_dimensions': inferDimensions,
      'max_depth': maxDepth,
      'exclude_selectors': excludeSelectors,
      if (baseUrl != null) 'base_url': baseUrl,
      'tier_strategy': tierStrategy.name,
      'preserve_tags': preserveTags,
      'strip_tags': stripTags,
      'preprocessing': preprocessing.toJson(),
    };
  }

  /// Converts the options to a JSON string.
  String toJsonString() => jsonEncode(toJson());
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
  ///
  /// Accepted values are from 0 through 1,000,000, inclusive.
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
    this.maxStructuredDataSize = 1000000,
  });

  /// Converts the config to a JSON map.
  Map<String, dynamic> toJson() {
    if (maxStructuredDataSize < 0 || maxStructuredDataSize > 1000000) {
      throw RangeError.range(
        maxStructuredDataSize,
        0,
        1000000,
        'maxStructuredDataSize',
      );
    }

    return {
      'extract_title': extractTitle,
      'extract_description': extractDescription,
      'extract_keywords': extractKeywords,
      'extract_headers': extractHeaders,
      'extract_links': extractLinks,
      'extract_images': extractImages,
      'extract_structured_data': extractStructuredData,
      'max_structured_data_size': maxStructuredDataSize,
    };
  }
}

/// Classification of a hyperlink destination.
enum LinkType {
  /// A fragment link within the same document.
  anchor,

  /// A relative or same-site link.
  internal,

  /// An HTTP or HTTPS link.
  external,

  /// A `mailto:` link.
  email,

  /// A `tel:` link.
  phone,

  /// Any other or unclassified link.
  other,
}

/// Classification of an image source.
enum ImageType {
  /// An image embedded in a data URI.
  dataUri,

  /// An inline SVG element.
  inlineSvg,

  /// An image with an absolute HTTP or HTTPS URL.
  external,

  /// An image with a relative source path.
  relative,
}

/// Direction of document text.
enum TextDirection {
  /// Left-to-right text.
  leftToRight,

  /// Right-to-left text.
  rightToLeft,

  /// Direction inferred from the content.
  auto,
}

/// Format of an extracted structured-data entry.
enum StructuredDataType {
  /// JSON-LD data from an `application/ld+json` script.
  jsonLd,

  /// HTML microdata.
  microdata,

  /// RDFa attributes.
  rdfa,
}

/// A structured-data block extracted from the document.
class StructuredData {
  /// Structured-data format.
  final StructuredDataType dataType;

  /// Original serialized content.
  final String rawJson;

  /// Detected schema type, such as `Article`.
  final String? schemaType;

  /// Creates a structured-data entry.
  const StructuredData({
    required this.dataType,
    required this.rawJson,
    this.schemaType,
  });

  /// Decodes [rawJson] as JSON.
  dynamic get decoded => jsonDecode(rawJson);

  /// Creates a structured-data entry from upstream JSON.
  factory StructuredData.fromJson(Map<String, dynamic> json) => StructuredData(
    dataType: switch (json['data_type']) {
      'microdata' => StructuredDataType.microdata,
      'rdfa' => StructuredDataType.rdfa,
      _ => StructuredDataType.jsonLd,
    },
    rawJson: json['raw_json'] as String? ?? '',
    schemaType: json['schema_type'] as String?,
  );
}

/// Metadata about a link found in the document.
class LinkMetadata {
  /// The destination URL of the link.
  final String? href;

  /// The text content of the link.
  final String? text;

  /// The title attribute of the link.
  final String? title;

  /// Classification of the link destination.
  final LinkType linkType;

  /// Values from the link's `rel` attribute.
  final List<String> rel;

  /// Additional HTML attributes from the link element.
  final Map<String, String> attributes;

  /// Whether the link points to an external resource.
  bool get isExternal => linkType == LinkType.external;

  /// Whether the link is an image link.
  final bool isImage;

  /// Creates a new [LinkMetadata] instance.
  const LinkMetadata({
    this.href,
    this.text,
    this.title,
    LinkType? linkType,
    bool isExternal = false,
    this.rel = const [],
    this.attributes = const {},
    this.isImage = false,
  }) : linkType = linkType ?? (isExternal ? LinkType.external : LinkType.other);

  /// Creates a [LinkMetadata] instance from a JSON map.
  factory LinkMetadata.fromJson(Map<String, dynamic> json) => LinkMetadata(
    href: json['href'] as String?,
    text: json['text'] as String?,
    title: json['title'] as String?,
    linkType: switch (json['link_type']) {
      'anchor' => LinkType.anchor,
      'internal' => LinkType.internal,
      'external' => LinkType.external,
      'email' => LinkType.email,
      'phone' => LinkType.phone,
      _ =>
        (json['is_external'] as bool? ?? false)
            ? LinkType.external
            : LinkType.other,
    },
    rel: (json['rel'] as List<dynamic>? ?? const [])
        .map((value) => value as String)
        .toList(),
    attributes: Map<String, String>.from(
      json['attributes'] as Map? ?? const {},
    ),
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

  /// Classification of the image source.
  final ImageType imageType;

  /// Additional HTML attributes from the image element.
  final Map<String, String> attributes;

  /// Creates a new [ImageMetadata] instance.
  const ImageMetadata({
    this.src,
    this.alt,
    this.title,
    this.width,
    this.height,
    this.imageType = ImageType.relative,
    this.attributes = const {},
  });

  /// Creates an [ImageMetadata] instance from a JSON map.
  factory ImageMetadata.fromJson(Map<String, dynamic> json) {
    final dimensions = json['dimensions'] as Map<String, dynamic>?;
    return ImageMetadata(
      src: json['src'] as String?,
      alt: json['alt'] as String?,
      title: json['title'] as String?,
      width: (dimensions?['width'] ?? json['width']) as int?,
      height: (dimensions?['height'] ?? json['height']) as int?,
      imageType: switch (json['image_type']) {
        'data_uri' => ImageType.dataUri,
        'inline_svg' => ImageType.inlineSvg,
        'external' => ImageType.external,
        _ => ImageType.relative,
      },
      attributes: Map<String, String>.from(
        json['attributes'] as Map? ?? const {},
      ),
    );
  }
}

/// Metadata about a header found in the document.
class HeaderMetadata {
  /// The heading level (1-6).
  final int level;

  /// The text content of the header.
  final String text;

  /// The ID attribute of the header.
  final String? id;

  /// Document tree depth of the heading element.
  final int depth;

  /// Byte offset of the heading in the original HTML.
  final int htmlOffset;

  /// Creates a new [HeaderMetadata] instance.
  const HeaderMetadata({
    required this.level,
    required this.text,
    this.id,
    this.depth = 0,
    this.htmlOffset = 0,
  });

  /// Creates a [HeaderMetadata] instance from a JSON map.
  factory HeaderMetadata.fromJson(Map<String, dynamic> json) => HeaderMetadata(
    level: json['level'] as int,
    text: json['text'] as String,
    id: json['id'] as String?,
    depth: json['depth'] as int? ?? 0,
    htmlOffset: json['html_offset'] as int? ?? 0,
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

  /// Document author from metadata.
  final String? author;

  /// Canonical URL declared by the document.
  final String? canonicalUrl;

  /// Base URL declared by a `<base>` element.
  final String? baseHref;

  /// Document language from the root `lang` attribute.
  final String? language;

  /// Document text direction.
  final TextDirection? textDirection;

  /// Open Graph metadata keyed without the `og:` prefix.
  final Map<String, String> openGraph;

  /// Twitter Card metadata keyed without the `twitter:` prefix.
  final Map<String, String> twitterCard;

  /// Additional named metadata entries.
  final Map<String, String> metaTags;

  /// List of headers found in the document.
  final List<HeaderMetadata>? headers;

  /// List of links found in the document.
  final List<LinkMetadata>? links;

  /// List of images found in the document.
  final List<ImageMetadata>? images;

  /// Structured data (JSON-LD) found in the document.
  final List<Map<String, dynamic>>? structuredData;

  /// Structured data including its format and original JSON.
  final List<StructuredData>? structuredDataEntries;

  /// Creates a new [DocumentMetadata] instance.
  const DocumentMetadata({
    this.title,
    this.description,
    this.keywords,
    this.author,
    this.canonicalUrl,
    this.baseHref,
    this.language,
    this.textDirection,
    this.openGraph = const {},
    this.twitterCard = const {},
    this.metaTags = const {},
    this.headers,
    this.links,
    this.images,
    this.structuredData,
    this.structuredDataEntries,
  });

  /// Creates a [DocumentMetadata] instance from a JSON map.
  factory DocumentMetadata.fromJson(Map<String, dynamic> json) {
    final document = json['document'] as Map<String, dynamic>? ?? json;

    Map<String, String> parseStringMap(dynamic data) =>
        data is Map ? Map<String, String>.from(data) : const {};

    final structuredDataEntries = (json['structured_data'] as List<dynamic>?)
        ?.whereType<Map>()
        .map(
          (entry) => StructuredData.fromJson(Map<String, dynamic>.from(entry)),
        )
        .toList();

    List<Map<String, dynamic>>? parseStructuredData(dynamic data) {
      if (data == null) return null;
      final parsed = <Map<String, dynamic>>[];

      void addDecoded(dynamic value) {
        if (value is Map) {
          parsed.add(Map<String, dynamic>.from(value));
        } else if (value is List) {
          for (final item in value) {
            if (item is Map) parsed.add(Map<String, dynamic>.from(item));
          }
        }
      }

      if (data is List) {
        for (final entry in data) {
          if (entry is Map && entry['raw_json'] is String) {
            try {
              addDecoded(jsonDecode(entry['raw_json'] as String));
            } on FormatException {
              // Ignore malformed structured-data entries without dropping
              // valid entries returned alongside them.
            }
          } else {
            addDecoded(entry);
          }
        }
      } else {
        addDecoded(data);
      }
      return parsed;
    }

    return DocumentMetadata(
      title: document['title'] as String?,
      description: document['description'] as String?,
      keywords: (document['keywords'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      author: document['author'] as String?,
      canonicalUrl: document['canonical_url'] as String?,
      baseHref: document['base_href'] as String?,
      language: document['language'] as String?,
      textDirection: switch (document['text_direction']) {
        'ltr' => TextDirection.leftToRight,
        'rtl' => TextDirection.rightToLeft,
        'auto' => TextDirection.auto,
        _ => null,
      },
      openGraph: parseStringMap(document['open_graph']),
      twitterCard: parseStringMap(document['twitter_card']),
      metaTags: parseStringMap(document['meta_tags']),
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
      structuredDataEntries: structuredDataEntries,
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
    'max_decoded_size_bytes': maxDecodedSizeBytes,
    if (filenamePrefix != null) 'filename_prefix': filenamePrefix,
    'capture_svg': captureSvg,
    'infer_dimensions': inferDimensions,
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
    final sourceStr = json['source'] as String? ?? 'img_data_uri';

    InlineImageFormat parseFormat(String s) {
      return InlineImageFormat.values.firstWhere(
        (e) => e.name.toLowerCase() == s.toLowerCase(),
        orElse: () => InlineImageFormat.unknown,
      );
    }

    InlineImageSource parseSource(String s) {
      return switch (s.toLowerCase()) {
        'svg_element' || 'svgelement' => InlineImageSource.svgElement,
        'img_data_uri' || 'data_uri' || 'datauri' => InlineImageSource.dataUri,
        _ => InlineImageSource.dataUri,
      };
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
