import 'dart:math';
import 'benchmarks.dart';
import 'html_test_data.dart';

void main() {
  print(
    '\n╔══════════════════════════════════════════════════════════════════╗',
  );
  print('║           HTML to Markdown Benchmark Comparison                 ║');
  print('║     html_to_markdown_rust vs html2md                             ║');
  print(
    '╚══════════════════════════════════════════════════════════════════╝\n',
  );

  final results = <BenchmarkResult>[];

  // Simple HTML Benchmark
  print('Running Simple HTML benchmark...');
  final simpleRust = SimpleHtmlBenchmarkRust(HtmlTestData.simpleHtml);
  final simpleHtml2md = SimpleHtmlBenchmarkHtml2md(HtmlTestData.simpleHtml);

  simpleRust.warmup();
  final simpleRustScore = simpleRust.measure();

  simpleHtml2md.warmup();
  final simpleHtml2mdScore = simpleHtml2md.measure();

  results.add(
    BenchmarkResult(
      name: 'Simple HTML',
      htmlSize: HtmlTestData.simpleHtmlLength,
      rustScore: simpleRustScore,
      html2mdScore: simpleHtml2mdScore,
    ),
  );

  print('✓ Simple HTML benchmark complete\n');

  // Complex HTML Benchmark
  print('Running Complex HTML benchmark...');
  final complexRust = ComplexHtmlBenchmarkRust(HtmlTestData.complexHtml);
  final complexHtml2md = ComplexHtmlBenchmarkHtml2md(HtmlTestData.complexHtml);

  complexRust.warmup();
  final complexRustScore = complexRust.measure();

  complexHtml2md.warmup();
  final complexHtml2mdScore = complexHtml2md.measure();

  results.add(
    BenchmarkResult(
      name: 'Complex HTML',
      htmlSize: HtmlTestData.complexHtmlLength,
      rustScore: complexRustScore,
      html2mdScore: complexHtml2mdScore,
    ),
  );

  print('✓ Complex HTML benchmark complete\n');

  // Nested HTML Benchmark
  print('Running Nested HTML benchmark...');
  final nestedRust = NestedHtmlBenchmarkRust(HtmlTestData.nestedHtml);
  final nestedHtml2md = NestedHtmlBenchmarkHtml2md(HtmlTestData.nestedHtml);

  nestedRust.warmup();
  final nestedRustScore = nestedRust.measure();

  nestedHtml2md.warmup();
  final nestedHtml2mdScore = nestedHtml2md.measure();

  results.add(
    BenchmarkResult(
      name: 'Nested HTML',
      htmlSize: HtmlTestData.nestedHtmlLength,
      rustScore: nestedRustScore,
      html2mdScore: nestedHtml2mdScore,
    ),
  );

  print('✓ Nested HTML benchmark complete\n');

  // Large HTML Benchmark
  print('Running Large HTML benchmark...');
  final largeRust = LargeHtmlBenchmarkRust(HtmlTestData.largeHtml);
  final largeHtml2md = LargeHtmlBenchmarkHtml2md(HtmlTestData.largeHtml);

  largeRust.warmup();
  final largeRustScore = largeRust.measure();

  largeHtml2md.warmup();
  final largeHtml2mdScore = largeHtml2md.measure();

  results.add(
    BenchmarkResult(
      name: 'Large HTML',
      htmlSize: HtmlTestData.largeHtmlLength,
      rustScore: largeRustScore,
      html2mdScore: largeHtml2mdScore,
    ),
  );

  print('✓ Large HTML benchmark complete\n');

  // Print results table
  printResultsTable(results);

  // Print summary
  printSummary(results);
}

void printResultsTable(List<BenchmarkResult> results) {
  print(
    '┌─────────────────────────┬──────────┬──────────────────┬──────────────────┬───────────┐',
  );
  print(
    '│ Test Case               │ HTML Size│ html_to_markdown_│                  │           │',
  );
  print(
    '│                         │ (bytes)  │      rust        │     html2md       │  Speedup  │',
  );
  print(
    '│                         │          │ (μs/op)          │ (μs/op)          │           │',
  );
  print(
    '├─────────────────────────┼──────────┼──────────────────┼──────────────────┼───────────┤',
  );

  for (final result in results) {
    final name = result.name.padRight(23);
    final size = _formatBytes(result.htmlSize).padRight(8);
    final rustTime = _formatTime(result.rustScore).padRight(16);
    final html2mdTime = _formatTime(result.html2mdScore).padRight(16);
    final speedup = _formatSpeedup(result.speedup).padRight(9);
    print('│ $name│ $size│ $rustTime│ $html2mdTime│ $speedup│');
  }

  print(
    '└─────────────────────────┴──────────┴──────────────────┴──────────────────┴───────────┘',
  );
}

void printSummary(List<BenchmarkResult> results) {
  final avgSpeedup =
      results.map((r) => r.speedup).reduce((a, b) => a + b) / results.length;

  // Calculate geometric mean of speedups
  double product = 1.0;
  for (final result in results) {
    product *= result.speedup;
  }
  final geomeanSpeedup = pow(product, 1 / results.length);
  final overallSpeedup = geomeanSpeedup;

  print('\n📊 Summary Statistics:');
  print(
    '─────────────────────────────────────────────────────────────────────',
  );
  print(
    'Average Speedup:              ${avgSpeedup.toStringAsFixed(2)}x faster',
  );
  print(
    'Geometric Mean Speedup:       ${overallSpeedup.toStringAsFixed(2)}x faster',
  );
  print(
    'Total HTML Size Benchmarked:  ${_formatBytes(results.map((r) => r.htmlSize).reduce((a, b) => a + b))}',
  );
  print('Number of Benchmarks:         ${results.length}');
  print(
    '─────────────────────────────────────────────────────────────────────\n',
  );

  // Find best and worst performance
  final bestResult = results.reduce((a, b) => a.speedup > b.speedup ? a : b);
  final worstResult = results.reduce((a, b) => a.speedup < b.speedup ? a : b);

  print(
    '🏆 Best Performance:  ${bestResult.name} (${bestResult.speedup.toStringAsFixed(2)}x faster)',
  );
  print(
    '📉 Worst Performance: ${worstResult.name} (${worstResult.speedup.toStringAsFixed(2)}x faster)\n',
  );
}

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
}

String _formatTime(double microseconds) {
  if (microseconds >= 1000) {
    return '${(microseconds / 1000).toStringAsFixed(2)} ms';
  }
  return '${microseconds.toStringAsFixed(2)} μs';
}

String _formatSpeedup(double speedup) {
  if (speedup < 1.0) {
    return '${(1.0 / speedup).toStringAsFixed(2)}x ↓';
  }
  return '${speedup.toStringAsFixed(2)}x ↑';
}

class BenchmarkResult {
  final String name;
  final int htmlSize;
  final double rustScore;
  final double html2mdScore;

  BenchmarkResult({
    required this.name,
    required this.htmlSize,
    required this.rustScore,
    required this.html2mdScore,
  });

  double get speedup => html2mdScore / rustScore;
}
