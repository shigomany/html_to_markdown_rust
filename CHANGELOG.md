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
