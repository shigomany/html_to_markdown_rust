# Benchmarks

This suite compares `html_to_markdown_rust` with the pure-Dart
[`html2md`](https://pub.dev/packages/html2md) converter on the same HTML inputs.
It is intended for reproducible local comparison, not as a universal speed
claim.

## What is measured

The runner uses `benchmark_harness` and reports microseconds per operation for
both converters, followed by their ratio. It exercises four fixtures:

- **Simple HTML** — a heading and paragraph
- **Complex HTML** — mixed document structures such as lists and tables
- **Nested HTML** — deeply nested elements
- **Large HTML** — a generated document with 50 sections

Each benchmark is warmed up before measurement. The two implementations run
sequentially in the same Dart process against identical input for each case.

## Run

The benchmark has its own package manifest. From the repository root:

```bash
cd benchmark
dart pub get
dart run main.dart
```

`dart pub get` resolves the benchmark dependencies; Dart native assets builds
the bundled Rust library when the runner starts. Rust `1.99.0` must be installed
and available to the build process. Because the package uses `dart:ffi`, run the
suite on a native platform rather than Web.

## Read the output

The generated table contains:

- input size in bytes;
- mean time in microseconds per operation for each converter;
- the `html2md time / html_to_markdown_rust time` ratio;
- arithmetic and geometric mean ratios across the four fixtures;
- the cases with the highest and lowest ratios.

A ratio above `1.0x` means `html_to_markdown_rust` took less time for that case;
a ratio below `1.0x` means `html2md` took less time. Keep the full output with
any published result so readers can see every case.

## Reproducible reporting

Record the following alongside results:

- operating system and CPU;
- Dart or Flutter version and execution mode;
- Rust toolchain version;
- package commit and dependency lockfile;
- whether the run followed a fresh build;
- relevant power mode and background system load.

Run the command several times and report the spread instead of selecting a
single favorable run. Compare results only when the environment, fixtures, and
dependencies match; JIT warmup, native compilation, CPU scaling, and system
load can materially change timings.
