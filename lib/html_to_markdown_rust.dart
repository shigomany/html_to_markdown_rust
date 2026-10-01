/// HTML converter with Markdown, Djot, and plain-text output (Rust-powered).
///
/// Converts HTML with Rust's html-to-markdown-rs library via FFI, with optional
/// typed document structure, tables, metadata, embedded images, and warnings.
///
/// ## Usage
///
/// ```dart
/// import 'package:html_to_markdown_rust/html_to_markdown_rust.dart';
///
/// void main() {
///   final html = '<h1>Hello World</h1><p>This is a test.</p>';
///   final markdown = htmlToMarkdown(html);
///   print(markdown);
/// }
/// ```
///
/// ## With Options
///
/// ```dart
/// final options = ConversionOptions(
///   headingStyle: HeadingStyle.atx,
///   bullets: '*',
///   skipImages: true,
/// );
/// final markdown = htmlToMarkdown(html, options);
/// ```
///
/// ## With Structured Results
///
/// ```dart
/// final result = convertHtml(
///   html,
///   options: const ConversionOptions(includeDocumentStructure: true),
/// );
/// print(result.content);
/// print(result.tables.length);
/// print(result.document?.nodes.length);
/// ```
///
/// ## With Metadata Extraction
///
/// ```dart
/// final result = htmlToMarkdownWithMetadata(
///   html,
///   options: ConversionOptions(),
///   metadataConfig: MetadataConfig(),
/// );
/// print(result.markdown);
/// print(result.metadata?.title);
/// ```
///
/// ## With Inline Images Extraction
///
/// ```dart
/// final result = htmlToMarkdownWithInlineImages(
///   html,
///   imageConfig: InlineImageConfig(maxDecodedSizeBytes: 10 * 1024 * 1024),
/// );
/// print(result.markdown);
/// for (final img in result.inlineImages) {
///   print('Image: ${img.filename}, format: ${img.format}');
/// }
/// ```
library;

export 'src/html_to_markdown.dart'
    show
        convertHtml,
        htmlToMarkdown,
        htmlToMarkdownWithMetadata,
        htmlToMarkdownWithInlineImages;
export 'src/conversion_options.dart'
    show
        ConversionOptions,
        MetadataConfig,
        DocumentMetadata,
        LinkMetadata,
        ImageMetadata,
        HeaderMetadata,
        StructuredData,
        StructuredDataType,
        TextDirection,
        LinkType,
        ImageType,
        HeadingStyle,
        ListIndentType,
        CodeBlockStyle,
        NewlineStyle,
        HighlightStyle,
        OutputFormat,
        LinkStyle,
        UrlEscapeStyle,
        TierStrategy,
        WhitespaceMode,
        PreprocessingPreset,
        PreprocessingOptions,
        ConversionResult,
        InlineImageConfig,
        InlineImage,
        InlineImageFormat,
        InlineImageSource,
        InlineImageWarning,
        InlineImagesResult;

export 'src/conversion_result.dart';
