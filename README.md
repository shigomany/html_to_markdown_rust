# HTML to Markdown Rust

A high-performance Dart package that converts HTML to Markdown using Rust's [`html-to-markdown-rs`](https://crates.io/crates/html-to-markdown-rs) library via FFI (Foreign Function Interface).

This package provides fast, memory-efficient HTML to Markdown conversion with support for complex HTML structures including headings, paragraphs, lists, links, images, tables, and more.

## Features

- **High Performance**: Rust-powered conversion for optimal speed
- **Comprehensive HTML Support**: Handles most common HTML elements
  - Headings (`<h1>` through `<h6>`)
  - Paragraphs (`<p>`)
  - Lists (ordered and unordered)
  - Links (`<a>`) with automatic Markdown syntax
  - Images (`<img>`) with alt text
  - Bold (`<strong>`, `<b>`) and italic (`<em>`, `<i>`)
  - Code (`<code>`, `<pre>`)
  - Blockquotes (`<blockquote>`)
  - Tables (`<table>`, `<tr>`, `<td>`, `<th>`)
  - Horizontal rules (`<hr>`)
  - Line breaks (`<br>`)
- **Memory Safe**: Proper memory management with automatic cleanup
- **Null Safe Dart API**: Follows Dart's null safety principles
- **Cross Platform**: Works on macOS, Linux, and Windows

## Requirements

- **Dart SDK**: `^3.10.1` or higher
- **Rust toolchain**: Required for building the native library (automatically handled by `native_toolchain_rust`)

## Installation

Add this to your package's `pubspec.yaml`:

```yaml
dependencies:
  html_to_markdown_rust: ^1.0.0
```

Then run:

```bash
dart pub get
```

## Building

The native Rust library is built automatically when you run your Dart application. The `native_toolchain_rust` package handles this process.

If you need to rebuild the native library manually:

```bash
cd rust
cargo build --release
```

## Usage

### Basic Conversion

Convert a simple HTML string to Markdown:

```dart
import 'package:html_to_markdown_rust/html_to_markdown_rust.dart';

void main() {
  final html = '<h1>Hello World</h1><p>This is a test.</p>';
  final markdown = htmlToMarkdown(html);
  print(markdown);
  // Output: # Hello World
  //         This is a test.
}
```

### Complex HTML

Convert more complex HTML structures:

```dart
void main() {
  final html = '''
    <div class="container">
      <h2>Features</h2>
      <ul>
        <li>Fast conversion</li>
        <li>Memory efficient</li>
        <li>Easy to use</li>
      </ul>
      <p>Check out our <a href="https://example.com">website</a>!</p>
    </div>
  ''';
  final markdown = htmlToMarkdown(html);
  print(markdown);
  // Output: ## Features
  //         - Fast conversion
  //         - Memory efficient
  //         - Easy to use
  //         Check out our [website](https://example.com)!
}
```

### Error Handling

The conversion function throws an exception if the conversion fails:

```dart
void main() {
  try {
    final markdown = htmlToMarkdown(html);
    print(markdown);
  } on Exception catch (e) {
    print('Conversion failed: $e');
  }
}
```

## API Reference

### `htmlToMarkdown(String html)`

Converts HTML string to Markdown format.

**Parameters:**
- `html` - The HTML string to convert

**Returns:**
- `String` - The converted Markdown

**Throws:**
- `Exception` - If the conversion fails

## How it Works

This package uses Dart's FFI (Foreign Function Interface) to call Rust functions that perform the HTML to Markdown conversion:

1. The Dart function `htmlToMarkdown()` converts the input HTML string to a UTF-8 C string
2. The Rust function `htm_convert()` processes the HTML using the `html-to-markdown-rs` library
3. The result is returned as a C string pointer
4. Dart converts the result back to a Dart String
5. The Rust memory is freed using `htm_free_string()`

## Architecture

```
Dart Layer (lib/)
├── html_to_markdown_rust.dart  # Public API entry point
├── src/
│   ├── html_to_markdown.dart   # Conversion logic with FFI
│   ├── codec.dart               # Codec utilities
│   └── bindings.g.dart          # Generated FFI bindings

Rust Layer (rust/)
├── src/
│   └── lib.rs                   # FFI interface functions
├── Cargo.toml                   # Rust dependencies
└── build.rs                     # Build configuration
```

## Development

### Running Tests

```bash
# Run all tests
dart test

# Run with coverage
dart test --coverage=coverage
```

### Regenerating FFI Bindings

If you modify the Rust API, regenerate the bindings:

```bash
dart run ffigen
```

### Code Generation

After modifying the Rust code, rebuild the native library:

```bash
# The native library will be built automatically when you run your app
# or you can manually trigger it with:
dart run build_runner build
```

## Performance

This package is optimized for performance:
- Conversion happens in Rust for maximum speed
- Minimal memory overhead with proper cleanup
- Efficient string handling via FFI

Benchmarks (on typical HTML documents):
- Simple documents: < 1ms
- Medium documents (10KB): ~2-5ms
- Large documents (100KB): ~10-20ms

### Benchmark Results

We've benchmarked `html_to_markdown_rust` against the popular `html2md` package:

```
┌─────────────────────────┬──────────┬──────────────────┬──────────────────┬───────────┐
│ Test Case               │ HTML Size│ html_to_markdown_│                  │           │
│                         │ (bytes)  │      rust        │     html2md       │  Speedup  │
│                         │          │ (μs/op)          │ (μs/op)          │           │
├─────────────────────────┼──────────┼──────────────────┼──────────────────┼───────────┤
│ Simple HTML            │ 66 B    │ 24.28 μs        │ 104.64 μs       │ 4.31x ↑  │
│ Complex HTML           │ 1.2 KB  │ 331.45 μs       │ 1.51 ms         │ 4.56x ↑  │
│ Nested HTML            │ 978 B   │ 269.18 μs       │ 1.08 ms         │ 4.03x ↑  │
│ Large HTML             │ 37.1 KB │ 8.05 ms         │ 131.82 ms       │ 16.38x ↑ │
└─────────────────────────┴──────────┴──────────────────┴──────────────────┴───────────┘

Summary:
- Average Speedup: 7.32x faster
- Geometric Mean Speedup: 6.00x faster
- Best Performance: Large HTML (16.38x faster)
```

### Running Benchmarks

You can run the benchmarks yourself to see the performance on your system:

```bash
cd benchmark
dart pub get
dart run main.dart
```

For more details, see the [benchmark/README.md](benchmark/README.md) file.

## Limitations

- The conversion follows the behavior of the underlying `html-to-markdown-rs` crate
- Some advanced HTML features may not be fully supported
- Custom HTML tags are typically removed during conversion
- JavaScript and CSS are not processed (as expected for Markdown output)

## Troubleshooting

### Build Errors

If you encounter build errors related to Rust:

1. Ensure Rust is installed: `rustc --version`
2. Update the Rust toolchain: `rustup update`
3. Clean and rebuild: `dart clean && dart pub get`

### Runtime Errors

If conversion fails:
- Ensure the input is valid UTF-8 encoded HTML
- Check for memory issues with very large HTML documents
- Review the error message for specific failure causes

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

### Development Workflow

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## License

This package is released under the MIT License. See the LICENSE file for details.

## Credits

- Built with [html-to-markdown-rs](https://crates.io/crates/html-to-markdown-rs) Rust crate
- Uses Dart's [FFI](https://dart.dev/guides/libraries/c-interop) for native interop
- Native library building handled by [native_toolchain_rust](https://pub.dev/packages/native_toolchain_rust)

## Support

For issues, questions, or contributions:
- GitHub Issues: https://github.com/your-org/html_to_markdown_rust/issues
- Documentation: https://github.com/your-org/html_to_markdown_rust
