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
library;

export 'src/html_to_markdown.dart' show htmlToMarkdown;
