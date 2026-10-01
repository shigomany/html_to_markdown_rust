# html_to_markdown_rust

[![pub package](https://img.shields.io/pub/v/html_to_markdown_rust.svg)](https://pub.dev/packages/html_to_markdown_rust)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Turn HTML into clean Markdown from Dart and Flutter with the mature
[`html-to-markdown-rs`](https://crates.io/crates/html-to-markdown-rs) converter.
The package adds a small, null-safe Dart API over the Rust engine. A single
conversion can return Markdown, Djot, or plain text together with a typed
document tree, tables, metadata, embedded images, and processing warnings.

Use it for content importers, offline readers, note-taking apps, AI/RAG
pipelines, CMS migrations, and any native app that needs predictable Markdown
without implementing an HTML parser in Dart.

## Highlights

- Converts headings, lists, links, images, tables, blockquotes, code, and other
  common HTML structures.
- Controls heading, list, code-block, newline, whitespace, escaping, and tag
  handling through `ConversionOptions`.
- Extracts title, description, keywords, headings, links, images, and JSON-LD.
- Extracts data-URI and inline SVG images with size limits and warnings.
- Preserves typed document nodes and table spans in structured output.
- Builds the bundled Rust library automatically with Dart native assets.

## Requirements

- Dart SDK `^3.13.0` (Flutter `3.47.5` bundles Dart `3.13.4`)
- Rust `1.99.0`, installed and available to the build process
- A native target: Android, iOS, macOS, Linux, or Windows

Web is not supported because the package uses `dart:ffi`. The native tooling is
configured for the targets above. Development validation is performed on
macOS, so verify the build in your own target environment.

## Installation

```yaml
dependencies:
  html_to_markdown_rust: ^0.3.0
```

Then run `dart pub get` or `flutter pub get`. The Rust library is compiled by
the native-assets build hook when your application builds; no separate code
generation command is required.

## Quick start

```dart
import 'package:html_to_markdown_rust/html_to_markdown_rust.dart';

void main() {
  const html = '''
    <h1>Release notes</h1>
    <p>Now with <strong>native</strong> conversion.</p>
    <ul><li>Fast setup</li><li>Configurable output</li></ul>
  ''';

  final markdown = htmlToMarkdown(html);
  print(markdown);
}
```

`htmlToMarkdown` is synchronous and throws an `Exception` when conversion
fails. In Flutter, move large conversions off the UI isolate, for example with
`Isolate.run(() => htmlToMarkdown(html))` from `dart:isolate`.

## One-pass structured conversion

Use `convertHtml` when you need converted text and extracted data together:

```dart
final result = convertHtml(
  html,
  options: const ConversionOptions(
    outputFormat: OutputFormat.markdown,
    includeDocumentStructure: true,
    extractMetadata: true,
    extractImages: true,
    captureSvg: true,
  ),
  metadataConfig: const MetadataConfig(),
  imageConfig: const InlineImageConfig(
    filenamePrefix: 'article_',
    captureSvg: true,
  ),
);

print(result.content);
print(result.document?.nodes.length);
print(result.tables.length);
print(result.metadata?.title);
print(result.inlineImages.length);

for (final warning in result.warnings) {
  print('${warning.kind}: ${warning.message}');
}
```

Set `includeDocumentStructure: true` to collect `DocumentNode` values and
tables. Each table uses a sparse `TableGrid`: origin cells carry zero-based
positions plus `rowSpan` and `colSpan`. Inline `TextAnnotation.start` and
`.end` values are UTF-8 byte offsets within that node's text, rather than Dart
string indices. The current `html-to-markdown-rs 3.15.1` structure collector
leaves annotation lists empty, and node text can include inline Markdown.
Plain-text input can take an upstream fast path that returns a `null` document
in any output format, even when structure was requested.

Metadata includes document identity fields, language and direction, Open Graph
and Twitter Card values, headers, classified links and images, custom meta
tags, and structured-data entries. Inline images and non-fatal
`ProcessingWarning` diagnostics are returned alongside the same conversion.
SVG dimensions are optional; automatic dimension inference applies to raster
images. When `imageConfig` is supplied, its image settings override the
corresponding values in `ConversionOptions`.

## Configure the output

```dart
final markdown = htmlToMarkdown(
  html,
  const ConversionOptions(
    headingStyle: HeadingStyle.setext,
    bullets: '*',
    codeBlockStyle: CodeBlockStyle.tilde,
    whitespaceMode: WhitespaceMode.condense,
    preserveTags: ['details', 'summary'],
    preprocessing: PreprocessingOptions(
      enabled: true,
      preset: PreprocessingPreset.standard,
    ),
  ),
);
```

`ConversionOptions` also supports list indentation, emphasis symbols, escaping,
newline and highlight styles, skipping links or images, and stripping selected
tags while keeping their content.

It can also select `OutputFormat.markdown`, `OutputFormat.djot`, or
`OutputFormat.plain`, resolve relative destinations with `baseUrl`, emit
numbered reference links with `LinkStyle.reference`, remove matching elements
with `excludeSelectors`, and render tighter tables with `compactTables`.

## Convert and collect metadata

```dart
final result = htmlToMarkdownWithMetadata(
  html,
  options: const ConversionOptions(skipImages: true),
  metadataConfig: const MetadataConfig(
    extractStructuredData: true,
  ),
);

print(result.markdown);
print(result.metadata?.title);
print(result.metadata?.links?.map((link) => link.href));
```

Use `MetadataConfig` to select document fields, headings, links, images, and
structured data. `maxStructuredDataSize` limits accepted JSON-LD payloads to
`0` through `1,000,000` bytes, including the Rust engine's safety ceiling.

## Convert and extract inline images

```dart
final result = htmlToMarkdownWithInlineImages(
  html,
  imageConfig: const InlineImageConfig(
    maxDecodedSizeBytes: 10 * 1024 * 1024,
    filenamePrefix: 'article',
    captureSvg: true,
    inferDimensions: true,
  ),
);

for (final image in result.inlineImages) {
  print('${image.filename}: ${image.format}, ${image.dataBytes.length} bytes');
}
for (final warning in result.warnings) {
  print(warning.message);
}
```

The result contains Markdown plus extracted bytes, format, optional dimensions,
source, attributes, and non-fatal extraction warnings. The default decoded
image limit is 5 MiB.

## API overview

| API | Result |
| --- | --- |
| `convertHtml(...)` | Unified `HtmlConversionResult` with converted content and optional structured data |
| `htmlToMarkdown(html, [options])` | Markdown `String` |
| `htmlToMarkdownWithMetadata(...)` | `ConversionResult` with Markdown and optional `DocumentMetadata` |
| `htmlToMarkdownWithInlineImages(...)` | `InlineImagesResult` with Markdown, images, and warnings |

The three `htmlToMarkdown...` functions remain available for existing callers.
All conversion APIs are synchronous; use `Isolate.run` for large inputs in
Flutter when conversion must not block the UI isolate. See
[`example/structured.dart`](example/structured.dart) for an end-to-end example.

## Benchmarks

The repository includes a reproducible comparison with the pure-Dart
[`html2md`](https://pub.dev/packages/html2md) package. Results depend on the
machine, toolchain, build mode, and system load, so the documentation does not
publish a fixed speedup. Run the suite on the environment that matters to you:

```bash
cd benchmark
dart pub get
dart run main.dart
```

See [benchmark/README.md](benchmark/README.md) for the cases and reporting
method.

## Migrating to 0.2.0

Version `0.2.0` updates `html-to-markdown-rs` to `3.x`. Review converted output
when upgrading because the engine's Markdown formatting can change. Legacy
preprocessing options are deprecated: the upstream engine now controls HTML
sanitization. Metadata extraction retains the upstream 1,000,000-byte structured-data
safety cap by default.

## Development

```bash
dart pub get
dart test
dart analyze
```

When the Rust FFI surface changes, regenerate the Dart bindings with:

```bash
dart run ffigen
```

The generated `lib/src/bindings.g.dart` file should not be edited by hand.

## License

[MIT](LICENSE)
