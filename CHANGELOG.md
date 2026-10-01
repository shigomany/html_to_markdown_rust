## 0.3.0

- Added `convertHtml`, a unified conversion API that can return converted text,
  a typed document tree, span-aware tables, rich metadata, inline images, and
  non-fatal `ProcessingWarning` values in one pass.
- Added Markdown, Djot, and plain-text output selection plus base-URL
  resolution, reference links, CSS selector exclusion, compact tables, and
  other Rust `3.15.1` conversion options.
- Added typed document nodes, span-aware table models, and models for UTF-8
  byte-range annotations. The Rust `3.15.1` structure collector currently
  leaves annotations empty and can include inline Markdown in node text. Table
  collection requires `includeDocumentStructure: true`; plain-text input can
  take a fast path that omits the document tree in any output format.
- Corrected structured table coordinates across row-spanning cells returned by
  Rust `3.15.1`, consistently in document nodes and extracted tables.
- Expanded metadata with author, canonical and base URLs, language, text
  direction, Open Graph, Twitter Card, classified links and images, custom meta
  tags, and typed structured-data entries.
- Preserved `htmlToMarkdown`, `htmlToMarkdownWithMetadata`, and
  `htmlToMarkdownWithInlineImages` for existing callers.

## 0.2.0

- Updated the Rust converter from `html-to-markdown-rs 2.25.1` to `3.15.1`
  and the native-assets Rust toolchain to `1.99.0`.
- Updated Native Assets to `hooks 2.2.0`, `code_assets 2.1.0`, and
  `native_toolchain_rust 1.0.7`; refreshed Dart and FFI tooling dependencies.
- Raised the minimum Dart SDK to `3.13.0` and pinned development Flutter to
  `3.47.5` with FVM.
- Kept the three public conversion functions and adapted options, metadata,
  and inline-image results to the unified Rust 3.x conversion API.
- Fixed UTF-8 input lengths and released all FFI allocations on success and
  failure, including HTML buffers and embedded-NUL input.
- Fixed JSON serialization of conversion options and enabled `skipLinks`
  while retaining formatted link text.
- Reworked the README with installation, examples, use cases, and
  reproducible benchmarks.

### Migration notes

- Rust 3.x can change Markdown formatting; whitespace-only input now produces
  an empty string. Test output snapshots before upgrading.
- Legacy script/style/comment/hidden-element preprocessing switches are
  deprecated because Rust 3.x no longer exposes those controls. The legacy
  `NewlineStyle.preserve` and `HighlightStyle.asterisk` values map to trailing
  spaces and bold highlighting respectively.
- `MetadataConfig.maxStructuredDataSize` accepts `0` through `1,000,000` bytes
  (the upstream safety ceiling), defaults to `1,000,000`, and rejects larger
  values. Disabled metadata fields are filtered from the result.
- SVG dimensions remain optional; automatic dimension inference supports
  raster images.

## 0.1.2

- Fixed version at README.md.

## 0.1.1

- Updated links in README.md.
- Added dart doc comments for all public APIs.
- Added example package.

## 0.1.0

- Initial version.
- High-performance HTML to Markdown conversion using Rust FFI.
- Supports headings, paragraphs, lists, links, images, tables, and more.
