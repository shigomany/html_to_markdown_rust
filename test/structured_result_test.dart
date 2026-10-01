import 'dart:convert';

import 'package:html_to_markdown_rust/html_to_markdown_rust.dart';
import 'package:test/test.dart';

void main() {
  group('convertHtml structured result', () {
    test('returns a connected tree and sparse table cells', () {
      final result = convertHtml(
        '<h1 id="intro">Введение</h1>'
        '<p>Привет <strong>世界🌍</strong>, откройте '
        '<a href="https://example.com" title="Docs">документацию</a>.</p>'
        '<table>'
        '<tr><th rowspan="2">Name</th><th colspan="2">Values</th></tr>'
        '<tr><td>One</td><td>Two</td></tr>'
        '</table>',
        options: const ConversionOptions(includeDocumentStructure: true),
      );

      final document = result.document;
      expect(document, isNotNull);
      expect(document!.sourceFormat, 'html');
      expect(document.nodes, isNotEmpty);

      for (var index = 0; index < document.nodes.length; index++) {
        final node = document.nodes[index];
        if (node.parent case final parent?) {
          expect(parent, inInclusiveRange(0, document.nodes.length - 1));
          expect(document.nodes[parent].children, contains(index));
        }
        for (final child in node.children) {
          expect(child, inInclusiveRange(0, document.nodes.length - 1));
          expect(document.nodes[child].parent, index);
        }
      }

      final paragraph = document.nodes
          .map((node) => node.content)
          .whereType<ParagraphNodeContent>()
          .single;
      expect(paragraph.text, contains('世界🌍'));
      expect(paragraph.text, contains('документацию'));

      expect(result.tables, hasLength(1));
      final grid = result.tables.single.grid;
      expect(grid.rows, 2);
      expect(grid.cols, 3);
      final nameCell = grid.cells.firstWhere((cell) => cell.content == 'Name');
      expect(nameCell.row, 0);
      expect(nameCell.col, 0);
      expect(nameCell.rowSpan, 2);
      expect(nameCell.colSpan, 1);
      expect(nameCell.isHeader, isTrue);
      final valuesCell = grid.cells.firstWhere(
        (cell) => cell.content == 'Values',
      );
      expect(valuesCell.colSpan, 2);
      expect(valuesCell.isHeader, isTrue);
      expect(grid.cells.firstWhere((cell) => cell.content == 'One').col, 1);
      expect(grid.cells.firstWhere((cell) => cell.content == 'Two').col, 2);

      final documentGrid = document.nodes
          .map((node) => node.content)
          .whereType<TableNodeContent>()
          .single
          .grid;
      expect(
        documentGrid.cells.map((cell) => (cell.row, cell.col, cell.content)),
        grid.cells.map((cell) => (cell.row, cell.col, cell.content)),
      );
    });

    test('collects metadata and inline images in the same conversion', () {
      final result = convertHtml(
        '''
        <html>
          <head>
            <title>Structured result</title>
            <meta name="description" content="One native pass">
          </head>
          <body>
            <svg width="17" height="23"><rect width="17" height="23"/></svg>
            <img alt="pixel" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=">
          </body>
        </html>
        ''',
        options: const ConversionOptions(
          extractMetadata: true,
          extractImages: false,
          captureSvg: true,
          inferDimensions: true,
        ),
        metadataConfig: const MetadataConfig(),
        imageConfig: const InlineImageConfig(
          filenamePrefix: 'asset_',
          captureSvg: true,
          inferDimensions: true,
        ),
      );

      expect(result.metadata?.title, 'Structured result');
      expect(result.metadata?.description, 'One native pass');
      expect(result.inlineImages, hasLength(2));
      final svg = result.inlineImages.firstWhere(
        (image) => image.source == InlineImageSource.svgElement,
      );
      expect(svg.filename, startsWith('asset_'));
      expect(svg.dataBytes, isNotEmpty);
      final png = result.inlineImages.firstWhere(
        (image) => image.format == InlineImageFormat.png,
      );
      expect(png.source, InlineImageSource.dataUri);
      expect(png.width, 1);
      expect(png.height, 1);
      expect(png.dataBytes, isNotEmpty);
    });

    test('leaves optional payloads absent when collection is disabled', () {
      final result = convertHtml(
        '<title>Ignored</title><h1>Heading</h1><table><tr><td>A</td></tr></table>',
        options: const ConversionOptions(
          extractMetadata: false,
          includeDocumentStructure: false,
          extractImages: false,
          outputFormat: OutputFormat.plain,
        ),
      );

      expect(result.content, contains('Heading'));
      expect(result.content, isNot(contains('#')));
      expect(result.document, isNull);
      expect(result.metadata, isNull);
      expect(result.tables, isEmpty);
      expect(result.inlineImages, isEmpty);
    });

    test('reports malformed inline images as processing warnings', () {
      final result = convertHtml(
        '<img src="data:image/png;base64,!!!" alt="broken">',
        options: const ConversionOptions(extractImages: true),
      );

      expect(
        result.warnings.map((warning) => warning.kind),
        contains(WarningKind.imageExtractionFailed),
      );
      expect(result.inlineImages, isEmpty);
    });

    test('reports when DOM traversal reaches maxDepth', () {
      final result = convertHtml(
        '<main><section><div><p>Too deep</p></div></section></main>',
        options: const ConversionOptions(
          includeDocumentStructure: true,
          maxDepth: 1,
        ),
      );

      expect(
        result.warnings.map((warning) => warning.kind),
        contains(WarningKind.depthLimitExceeded),
      );
    });
  });

  test('annotation ranges are decoded as UTF-8 byte offsets', () {
    const text = 'Привет 世界🌍';
    final start = utf8.encode('Привет ').length;
    final end = utf8.encode(text).length;
    final annotation = TextAnnotation.fromJson({
      'start': start,
      'end': end,
      'kind': {
        'annotation_type': 'link',
        'url': 'https://example.com',
        'title': 'Docs',
      },
    });

    final bytes = utf8.encode(text);
    expect(
      utf8.decode(bytes.sublist(annotation.start, annotation.end)),
      '世界🌍',
    );
    expect(annotation.kind, isA<LinkAnnotation>());
    expect((annotation.kind as LinkAnnotation).url, 'https://example.com');
    expect((annotation.kind as LinkAnnotation).title, 'Docs');
  });

  group('TableGrid coordinate normalization', () {
    test('skips mixed active spans and expires them by row', () {
      final grid = TableGrid.fromJson({
        'rows': 3,
        'cols': 3,
        'cells': [
          _cell('A', row: 0, col: 0, rowSpan: 2),
          _cell('B', row: 0, col: 1, rowSpan: 3, colSpan: 2),
          _cell('C', row: 1, col: 0),
          _cell('D', row: 2, col: 0),
          _cell('E', row: 2, col: 1),
        ],
      });

      expect(grid.cells.map((cell) => (cell.content, cell.row, cell.col)), [
        ('A', 0, 0),
        ('B', 0, 1),
        ('C', 1, 3),
        ('D', 2, 0),
        ('E', 2, 3),
      ]);
      expect(grid.cols, 4);
    });

    test('keeps already valid native coordinates unchanged', () {
      final grid = TableGrid.fromJson({
        'rows': 2,
        'cols': 3,
        'cells': [
          _cell('A', row: 0, col: 0, rowSpan: 2),
          _cell('B', row: 0, col: 1, colSpan: 2),
          _cell('C', row: 1, col: 1),
          _cell('D', row: 1, col: 2),
        ],
      });

      expect(grid.cells.map((cell) => cell.col), [0, 1, 1, 2]);
      expect(grid.cols, 3);
    });

    test('preserves spans beyond the final row and expands column count', () {
      final grid = TableGrid.fromJson({
        'rows': 2,
        'cols': 2,
        'cells': [
          _cell('A', row: 0, col: 0, rowSpan: 3),
          _cell('B', row: 0, col: 1),
          _cell('C', row: 1, col: 0, rowSpan: 5, colSpan: 2),
        ],
      });

      final trailing = grid.cells.last;
      expect(trailing.col, 1);
      expect(trailing.rowSpan, 5);
      expect(trailing.colSpan, 2);
      expect(grid.rows, 2);
      expect(grid.cols, 3);
    });
  });

  test('unknown warning kinds remain observable', () {
    final warning = ProcessingWarning.fromJson({
      'message': 'new warning',
      'kind': 'future_warning',
    });

    expect(warning.kind, WarningKind.unknown);
    expect(warning.rawKind, 'future_warning');
  });

  test('unknown node and annotation variants preserve their payloads', () {
    final node = NodeContent.fromJson({
      'node_type': 'future_node',
      'value': 42,
    });
    final annotation = AnnotationKind.fromJson({
      'annotation_type': 'future_annotation',
      'value': 'kept',
    });

    expect(node, isA<UnknownNodeContent>());
    expect((node as UnknownNodeContent).nodeType, 'future_node');
    expect(node.rawJson['value'], 42);
    expect(annotation, isA<UnknownAnnotation>());
    expect(
      (annotation as UnknownAnnotation).annotationType,
      'future_annotation',
    );
    expect(annotation.rawJson['value'], 'kept');
  });
}

Map<String, Object> _cell(
  String content, {
  required int row,
  required int col,
  int rowSpan = 1,
  int colSpan = 1,
}) => {
  'content': content,
  'row': row,
  'col': col,
  'row_span': rowSpan,
  'col_span': colSpan,
  'is_header': false,
};
