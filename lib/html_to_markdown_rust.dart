/// HTML to Markdown Converter (Rust-powered)
///
/// A high-performance Dart package that converts HTML to Markdown using Rust's
/// html-to-markdown-rs library via FFI (Foreign Function Interface).
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
        HeadingStyle,
        ListIndentType,
        CodeBlockStyle,
        NewlineStyle,
        HighlightStyle,
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
