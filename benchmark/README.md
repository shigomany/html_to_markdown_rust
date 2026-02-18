# HTML to Markdown Benchmarks

This directory contains benchmarks comparing `html_to_markdown_rust` with `html2md`.

## Setup

1. Install dependencies:
```bash
cd benchmark
dart pub get
```

2. Ensure the Rust library is built:
```bash
cd ..
dart pub get
```

## Running Benchmarks

Run all benchmarks:
```bash
dart run benchmark/main.dart
```

## Benchmark Results

The benchmarks compare the performance of:
- **html_to_markdown_rust**: A high-performance HTML to Markdown converter using Rust via FFI
- **html2md**: A pure Dart HTML to Markdown converter

### Test Cases

1. **Simple HTML**: Basic HTML with a heading and paragraph
2. **Complex HTML**: Comprehensive HTML with tables, lists, code blocks, etc.
3. **Nested HTML**: Deeply nested HTML structures
4. **Large HTML**: Large documents with 50 sections (~20KB)

### Output Format

The benchmark output includes:
- ASCII table with detailed results
- Execution time for each library (microseconds per operation)
- Speedup comparison
- Summary statistics including average and geometric mean speedup
- Best and worst performing test cases

## Example Output

```
╔══════════════════════════════════════════════════════════════════╗
║           HTML to Markdown Benchmark Comparison                 ║
║     html_to_markdown_rust vs html2md                             ║
╚══════════════════════════════════════════════════════════════════╝

Running Simple HTML benchmark...
✓ Simple HTML benchmark complete

Running Complex HTML benchmark...
✓ Complex HTML benchmark complete

Running Nested HTML benchmark...
✓ Nested HTML benchmark complete

Running Large HTML benchmark...
✓ Large HTML benchmark complete

┌─────────────────────────┬──────────┬──────────────────┬──────────────────┬───────────┐
│ Test Case               │ HTML Size│ html_to_markdown_│                  │           │
│                         │ (bytes)  │      rust        │     html2md      │  Speedup  │
│                         │          │ (μs/op)          │ (μs/op)          │           │
├─────────────────────────┼──────────┼──────────────────┼──────────────────┼───────────┤
│ Simple HTML             │ 65 B     │ 12.34 μs         │ 45.67 μs         │ 3.70x ↑   │
│ Complex HTML            │ 1.2 KB   │ 123.45 μs        │ 567.89 μs        │ 4.60x ↑   │
│ Nested HTML             │ 892 B    │ 98.76 μs         │ 432.10 μs        │ 4.38x ↑   │
│ Large HTML              │ 19.8 KB  │ 1234.56 μs       │ 5432.10 μs       │ 4.40x ↑   │
└─────────────────────────┴──────────┴──────────────────┴──────────────────┴───────────┘

📊 Summary Statistics:
─────────────────────────────────────────────────────────────────────
Average Speedup:              4.27x faster
Geometric Mean Speedup:       4.28x faster
Total HTML Size Benchmarked:  22.0 KB
Number of Benchmarks:         4
─────────────────────────────────────────────────────────────────────

🏆 Best Performance:  Complex HTML (4.60x faster)
📉 Worst Performance: Simple HTML (3.70x faster)
```

## Understanding the Results

- **Speedup**: How many times faster `html_to_markdown_rust` is compared to `html2md`
- **μs/op**: Microseconds per operation (lower is better)
- **↑**: Indicates `html_to_markdown_rust` is faster
- **↓**: Indicates `html2md` is faster (unlikely)

## Notes

- Benchmarks use the `benchmark_harness` package
- Each benchmark runs multiple iterations for accurate measurement
- Warmup runs are performed before measurement to account for JIT compilation
- Results may vary depending on system configuration and load
