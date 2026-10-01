import 'package:html_to_markdown_rust/html_to_markdown_rust.dart';

void main() {
  const html = '''
    <html lang="en">
      <head>
        <title>Converter guide</title>
        <meta name="author" content="Example Author">
      </head>
      <body>
        <p class="navigation">Skip this navigation.</p>
        <h1>Converter guide</h1>
        <p>Read the <a href="guide.html"><strong>full guide</strong></a>.</p>
        <table>
          <tr><th rowspan="2">Format</th><th colspan="2">Output</th></tr>
          <tr><td>Text</td><td>Structure</td></tr>
        </table>
        <svg width="16" height="16" aria-label="Sample icon">
          <circle cx="8" cy="8" r="7" />
        </svg>
      </body>
    </html>
  ''';

  final result = convertHtml(
    html,
    options: const ConversionOptions(
      outputFormat: OutputFormat.markdown,
      linkStyle: LinkStyle.reference,
      baseUrl: 'https://example.com/docs/',
      compactTables: true,
      excludeSelectors: ['.navigation'],
      includeDocumentStructure: true,
      extractMetadata: true,
      extractImages: true,
      captureSvg: true,
    ),
    metadataConfig: const MetadataConfig(),
    imageConfig: const InlineImageConfig(
      filenamePrefix: 'guide_',
      captureSvg: true,
      inferDimensions: true,
    ),
  );

  print(result.content);
  print('Title: ${result.metadata?.title}');
  print('Nodes: ${result.document?.nodes.length ?? 0}');

  for (final table in result.tables) {
    print('Table: ${table.grid.rows} x ${table.grid.cols}');
    for (final cell in table.grid.cells) {
      print(
        '  (${cell.row}, ${cell.col}) ${cell.content} '
        '[rowSpan=${cell.rowSpan}, colSpan=${cell.colSpan}]',
      );
    }
  }

  for (final image in result.inlineImages) {
    print('Image: ${image.filename} (${image.format})');
  }

  for (final warning in result.warnings) {
    print('Warning [${warning.rawKind}]: ${warning.message}');
  }
}
