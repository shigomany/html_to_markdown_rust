import 'package:html_to_markdown_rust/html_to_markdown_rust.dart';
import 'package:html2md/html2md.dart' as html2md;
import 'package:benchmark_harness/benchmark_harness.dart';

class SimpleHtmlBenchmarkRust extends BenchmarkBase {
  final String html;
  SimpleHtmlBenchmarkRust(this.html)
    : super('Simple HTML - html_to_markdown_rust');

  @override
  void run() {
    htmlToMarkdown(html);
  }
}

class SimpleHtmlBenchmarkHtml2md extends BenchmarkBase {
  final String html;
  SimpleHtmlBenchmarkHtml2md(this.html) : super('Simple HTML - html2md');

  @override
  void run() {
    html2md.convert(html);
  }
}

class ComplexHtmlBenchmarkRust extends BenchmarkBase {
  final String html;
  ComplexHtmlBenchmarkRust(this.html)
    : super('Complex HTML - html_to_markdown_rust');

  @override
  void run() {
    htmlToMarkdown(html);
  }
}

class ComplexHtmlBenchmarkHtml2md extends BenchmarkBase {
  final String html;
  ComplexHtmlBenchmarkHtml2md(this.html) : super('Complex HTML - html2md');

  @override
  void run() {
    html2md.convert(html);
  }
}

class NestedHtmlBenchmarkRust extends BenchmarkBase {
  final String html;
  NestedHtmlBenchmarkRust(this.html)
    : super('Nested HTML - html_to_markdown_rust');

  @override
  void run() {
    htmlToMarkdown(html);
  }
}

class NestedHtmlBenchmarkHtml2md extends BenchmarkBase {
  final String html;
  NestedHtmlBenchmarkHtml2md(this.html) : super('Nested HTML - html2md');

  @override
  void run() {
    html2md.convert(html);
  }
}

class LargeHtmlBenchmarkRust extends BenchmarkBase {
  final String html;
  LargeHtmlBenchmarkRust(this.html)
    : super('Large HTML - html_to_markdown_rust');

  @override
  void run() {
    htmlToMarkdown(html);
  }
}

class LargeHtmlBenchmarkHtml2md extends BenchmarkBase {
  final String html;
  LargeHtmlBenchmarkHtml2md(this.html) : super('Large HTML - html2md');

  @override
  void run() {
    html2md.convert(html);
  }
}
