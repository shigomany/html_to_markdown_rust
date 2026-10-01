import 'package:html_to_markdown_rust/src/conversion_options.dart';

/// The complete output of a conversion, including optional extracted data.
class HtmlConversionResult {
  /// Converted text in the format selected by the conversion options.
  final String content;

  /// Semantic document tree, when document structure collection was enabled.
  final DocumentStructure? document;

  /// Metadata extracted from the source document, when enabled.
  final DocumentMetadata? metadata;

  /// Tables collected while building [document].
  final List<TableData> tables;

  /// Inline images extracted from data URIs or SVG elements.
  final List<InlineImage> inlineImages;

  /// Non-fatal diagnostics emitted by the converter.
  final List<ProcessingWarning> warnings;

  /// Creates a complete conversion result.
  const HtmlConversionResult({
    required this.content,
    this.document,
    this.metadata,
    this.tables = const [],
    this.inlineImages = const [],
    this.warnings = const [],
  });

  /// Decodes the native converter's JSON representation.
  factory HtmlConversionResult.fromJson(Map<String, dynamic> json) =>
      HtmlConversionResult(
        content: json['content'] as String? ?? '',
        document: switch (json['document']) {
          final Map value => DocumentStructure.fromJson(
            Map<String, dynamic>.from(value),
          ),
          _ => null,
        },
        metadata: switch (json['metadata']) {
          final Map value => DocumentMetadata.fromJson(
            Map<String, dynamic>.from(value),
          ),
          _ => null,
        },
        tables: _mapList(json['tables'], TableData.fromJson),
        inlineImages: _mapList(json['inline_images'], InlineImage.fromJson),
        warnings: _mapList(json['warnings'], ProcessingWarning.fromJson),
      );
}

/// A flat semantic document tree with index-based relationships.
class DocumentStructure {
  /// Nodes in document reading order.
  final List<DocumentNode> nodes;

  /// Original document format, normally `html`.
  final String? sourceFormat;

  /// Creates a document structure.
  const DocumentStructure({required this.nodes, this.sourceFormat});

  /// Decodes a document structure from JSON.
  factory DocumentStructure.fromJson(Map<String, dynamic> json) =>
      DocumentStructure(
        nodes: _mapList(json['nodes'], DocumentNode.fromJson),
        sourceFormat: json['source_format'] as String?,
      );
}

/// A node in a [DocumentStructure].
class DocumentNode {
  /// Stable identifier assigned by the native converter.
  final String id;

  /// Typed semantic content carried by this node.
  final NodeContent content;

  /// Index of the parent node, or `null` for a root.
  final int? parent;

  /// Indices of child nodes in reading order.
  final List<int> children;

  /// Inline formatting ranges, expressed as UTF-8 byte offsets.
  ///
  /// The Rust 3.15.1 structure collector currently leaves this list empty.
  final List<TextAnnotation> annotations;

  /// Source attributes retained by the converter.
  final Map<String, String>? attributes;

  /// Creates a document node.
  const DocumentNode({
    required this.id,
    required this.content,
    this.parent,
    this.children = const [],
    this.annotations = const [],
    this.attributes,
  });

  /// Decodes a document node from JSON.
  factory DocumentNode.fromJson(Map<String, dynamic> json) => DocumentNode(
    id: json['id'] as String,
    content: NodeContent.fromJson(_jsonMap(json['content'], 'content')),
    parent: json['parent'] as int?,
    children: (json['children'] as List<dynamic>? ?? const []).cast<int>(),
    annotations: _mapList(json['annotations'], TextAnnotation.fromJson),
    attributes: switch (json['attributes']) {
      final Map value => value.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      ),
      _ => null,
    },
  );
}

/// Semantic content of a [DocumentNode].
sealed class NodeContent {
  /// Creates node content.
  const NodeContent();

  /// Decodes the internally tagged native representation.
  factory NodeContent.fromJson(Map<String, dynamic> json) {
    return switch (json['node_type']) {
      'heading' => HeadingNodeContent(
        level: json['level'] as int,
        text: json['text'] as String,
      ),
      'paragraph' => ParagraphNodeContent(text: json['text'] as String),
      'list' => ListNodeContent(ordered: json['ordered'] as bool),
      'list_item' => ListItemNodeContent(text: json['text'] as String),
      'table' => TableNodeContent(
        grid: TableGrid.fromJson(_jsonMap(json['grid'], 'grid')),
      ),
      'image' => ImageNodeContent(
        description: json['description'] as String?,
        src: json['src'] as String?,
        imageIndex: json['image_index'] as int?,
      ),
      'code' => CodeNodeContent(
        text: json['text'] as String,
        language: json['language'] as String?,
      ),
      'quote' => const QuoteNodeContent(),
      'definition_list' => const DefinitionListNodeContent(),
      'definition_item' => DefinitionItemNodeContent(
        term: json['term'] as String,
        definition: json['definition'] as String,
      ),
      'raw_block' => RawBlockNodeContent(
        format: json['format'] as String,
        content: json['content'] as String,
      ),
      'metadata_block' => MetadataBlockNodeContent(
        entries: _mapList(json['entries'], MetadataEntry.fromJson),
      ),
      'group' => GroupNodeContent(
        label: json['label'] as String?,
        headingLevel: json['heading_level'] as int?,
        headingText: json['heading_text'] as String?,
      ),
      final value => UnknownNodeContent(
        nodeType: value?.toString() ?? 'unknown',
        rawJson: Map<String, dynamic>.unmodifiable(json),
      ),
    };
  }
}

/// Heading node content.
class HeadingNodeContent extends NodeContent {
  /// Heading level from 1 through 6.
  final int level;

  /// Heading text supplied by the native structure collector.
  final String text;

  /// Creates heading content.
  const HeadingNodeContent({required this.level, required this.text});
}

/// Paragraph node content.
class ParagraphNodeContent extends NodeContent {
  /// Paragraph content, which can contain rendered inline markup.
  final String text;

  /// Creates paragraph content.
  const ParagraphNodeContent({required this.text});
}

/// Ordered or unordered list container content.
class ListNodeContent extends NodeContent {
  /// Whether the list is ordered.
  final bool ordered;

  /// Creates list content.
  const ListNodeContent({required this.ordered});
}

/// List item content.
class ListItemNodeContent extends NodeContent {
  /// List item content, which can contain rendered inline markup.
  final String text;

  /// Creates list item content.
  const ListItemNodeContent({required this.text});
}

/// Table node content.
class TableNodeContent extends NodeContent {
  /// Structured table grid.
  final TableGrid grid;

  /// Creates table content.
  const TableNodeContent({required this.grid});
}

/// Image node content.
class ImageNodeContent extends NodeContent {
  /// Alt text or caption.
  final String? description;

  /// Image source URL.
  final String? src;

  /// Index into [HtmlConversionResult.inlineImages], when extracted.
  final int? imageIndex;

  /// Creates image content.
  const ImageNodeContent({this.description, this.src, this.imageIndex});
}

/// Code node content.
class CodeNodeContent extends NodeContent {
  /// Code text.
  final String text;

  /// Detected language, if available.
  final String? language;

  /// Creates code content.
  const CodeNodeContent({required this.text, this.language});
}

/// Block quote container content.
class QuoteNodeContent extends NodeContent {
  /// Creates quote content.
  const QuoteNodeContent();
}

/// Definition list container content.
class DefinitionListNodeContent extends NodeContent {
  /// Creates definition list content.
  const DefinitionListNodeContent();
}

/// Definition term and description content.
class DefinitionItemNodeContent extends NodeContent {
  /// Term being defined.
  final String term;

  /// Definition text.
  final String definition;

  /// Creates definition item content.
  const DefinitionItemNodeContent({
    required this.term,
    required this.definition,
  });
}

/// Raw source block content.
class RawBlockNodeContent extends NodeContent {
  /// Raw content format, such as `css` or `javascript`.
  final String format;

  /// Unmodified raw content.
  final String content;

  /// Creates raw block content.
  const RawBlockNodeContent({required this.format, required this.content});
}

/// Metadata key-value block content.
class MetadataBlockNodeContent extends NodeContent {
  /// Metadata entries in source order.
  final List<MetadataEntry> entries;

  /// Creates metadata block content.
  const MetadataBlockNodeContent({required this.entries});
}

/// Section grouping content generated from a heading hierarchy.
class GroupNodeContent extends NodeContent {
  /// Optional section label.
  final String? label;

  /// Heading level that created the group.
  final int? headingLevel;

  /// Heading text that created the group.
  final String? headingText;

  /// Creates group content.
  const GroupNodeContent({this.label, this.headingLevel, this.headingText});
}

/// Node content emitted by a newer native converter version.
class UnknownNodeContent extends NodeContent {
  /// Native `node_type` value.
  final String nodeType;

  /// Complete native payload for forward-compatible inspection.
  final Map<String, dynamic> rawJson;

  /// Creates unknown node content.
  const UnknownNodeContent({required this.nodeType, required this.rawJson});
}

/// A metadata key-value pair.
class MetadataEntry {
  /// Metadata key.
  final String key;

  /// Metadata value.
  final String value;

  /// Creates a metadata entry.
  const MetadataEntry({required this.key, required this.value});

  /// Decodes a metadata entry from JSON.
  factory MetadataEntry.fromJson(Map<String, dynamic> json) =>
      MetadataEntry(key: json['key'] as String, value: json['value'] as String);
}

/// An inline annotation over a UTF-8 byte range.
class TextAnnotation {
  /// Inclusive UTF-8 byte offset.
  final int start;

  /// Exclusive UTF-8 byte offset.
  final int end;

  /// Formatting or semantic meaning of the range.
  final AnnotationKind kind;

  /// Creates a text annotation.
  const TextAnnotation({
    required this.start,
    required this.end,
    required this.kind,
  });

  /// Decodes a text annotation from JSON.
  factory TextAnnotation.fromJson(Map<String, dynamic> json) => TextAnnotation(
    start: json['start'] as int,
    end: json['end'] as int,
    kind: AnnotationKind.fromJson(_jsonMap(json['kind'], 'kind')),
  );
}

/// Kind of inline annotation.
sealed class AnnotationKind {
  /// Creates an annotation kind.
  const AnnotationKind();

  /// Decodes the internally tagged native representation.
  factory AnnotationKind.fromJson(Map<String, dynamic> json) {
    return switch (json['annotation_type']) {
      'bold' => const BoldAnnotation(),
      'italic' => const ItalicAnnotation(),
      'underline' => const UnderlineAnnotation(),
      'strikethrough' => const StrikethroughAnnotation(),
      'code' => const CodeAnnotation(),
      'subscript' => const SubscriptAnnotation(),
      'superscript' => const SuperscriptAnnotation(),
      'highlight' => const HighlightAnnotation(),
      'link' => LinkAnnotation(
        url: json['url'] as String,
        title: json['title'] as String?,
      ),
      final value => UnknownAnnotation(
        annotationType: value?.toString() ?? 'unknown',
        rawJson: Map<String, dynamic>.unmodifiable(json),
      ),
    };
  }
}

/// Bold text annotation.
class BoldAnnotation extends AnnotationKind {
  /// Creates a bold annotation.
  const BoldAnnotation();
}

/// Italic text annotation.
class ItalicAnnotation extends AnnotationKind {
  /// Creates an italic annotation.
  const ItalicAnnotation();
}

/// Underlined text annotation.
class UnderlineAnnotation extends AnnotationKind {
  /// Creates an underline annotation.
  const UnderlineAnnotation();
}

/// Struck-through text annotation.
class StrikethroughAnnotation extends AnnotationKind {
  /// Creates a strikethrough annotation.
  const StrikethroughAnnotation();
}

/// Inline code annotation.
class CodeAnnotation extends AnnotationKind {
  /// Creates an inline code annotation.
  const CodeAnnotation();
}

/// Subscript annotation.
class SubscriptAnnotation extends AnnotationKind {
  /// Creates a subscript annotation.
  const SubscriptAnnotation();
}

/// Superscript annotation.
class SuperscriptAnnotation extends AnnotationKind {
  /// Creates a superscript annotation.
  const SuperscriptAnnotation();
}

/// Highlight annotation.
class HighlightAnnotation extends AnnotationKind {
  /// Creates a highlight annotation.
  const HighlightAnnotation();
}

/// Hyperlink annotation.
class LinkAnnotation extends AnnotationKind {
  /// Link destination exactly as found in the source.
  final String url;

  /// Optional source title attribute.
  final String? title;

  /// Creates a hyperlink annotation.
  const LinkAnnotation({required this.url, this.title});
}

/// Annotation emitted by a newer native converter version.
class UnknownAnnotation extends AnnotationKind {
  /// Native `annotation_type` value.
  final String annotationType;

  /// Complete native payload for forward-compatible inspection.
  final Map<String, dynamic> rawJson;

  /// Creates an unknown annotation.
  const UnknownAnnotation({
    required this.annotationType,
    required this.rawJson,
  });
}

/// A top-level table and its rendered output.
class TableData {
  /// Structured cell grid.
  final TableGrid grid;

  /// Rendered Markdown for this table.
  final String markdown;

  /// Creates table data.
  const TableData({required this.grid, required this.markdown});

  /// Decodes table data from JSON.
  factory TableData.fromJson(Map<String, dynamic> json) => TableData(
    grid: TableGrid.fromJson(_jsonMap(json['grid'], 'grid')),
    markdown: json['markdown'] as String,
  );
}

/// Sparse grid representation of an HTML table.
class TableGrid {
  /// Total row count.
  final int rows;

  /// Total column count.
  final int cols;

  /// Origin cells ordered by row and column.
  final List<GridCell> cells;

  /// Creates a table grid.
  const TableGrid({
    required this.rows,
    required this.cols,
    required this.cells,
  });

  /// Decodes a table grid and reserves columns covered by earlier row spans.
  factory TableGrid.fromJson(Map<String, dynamic> json) {
    final cells = _normalizeGridCells(
      _mapList(json['cells'], GridCell.fromJson),
    );
    final nativeCols = json['cols'] as int;
    final normalizedCols = cells.fold(
      nativeCols,
      (maximum, cell) =>
          _max(maximum, cell.col + _placementWidth(cell.colSpan)),
    );
    return TableGrid(
      rows: json['rows'] as int,
      cols: normalizedCols,
      cells: cells,
    );
  }
}

/// An origin cell in a sparse [TableGrid].
class GridCell {
  /// Cell content, which can contain rendered inline markup.
  final String content;

  /// Zero-based row position.
  final int row;

  /// Zero-based column position.
  final int col;

  /// Number of rows occupied by this cell.
  final int rowSpan;

  /// Number of columns occupied by this cell.
  final int colSpan;

  /// Whether the source element was a `th`.
  final bool isHeader;

  /// Creates a grid cell.
  const GridCell({
    required this.content,
    required this.row,
    required this.col,
    this.rowSpan = 1,
    this.colSpan = 1,
    this.isHeader = false,
  });

  /// Decodes a grid cell from JSON.
  factory GridCell.fromJson(Map<String, dynamic> json) => GridCell(
    content: json['content'] as String,
    row: json['row'] as int,
    col: json['col'] as int,
    rowSpan: json['row_span'] as int? ?? 1,
    colSpan: json['col_span'] as int? ?? 1,
    isHeader: json['is_header'] as bool? ?? false,
  );
}

/// Category of a non-fatal processing warning.
enum WarningKind {
  /// An inline image could not be extracted.
  imageExtractionFailed,

  /// The input encoding required a UTF-8 fallback.
  encodingFallback,

  /// Input was truncated by a size limit.
  truncatedInput,

  /// Malformed HTML was repaired on a best-effort basis.
  malformedHtml,

  /// Potentially unsafe content was sanitized.
  sanitizationApplied,

  /// DOM traversal stopped at the configured depth limit.
  depthLimitExceeded,

  /// A newer native warning category not known by this package version.
  unknown,
}

/// A non-fatal converter diagnostic.
class ProcessingWarning {
  /// Human-readable warning message.
  final String message;

  /// Parsed warning category.
  final WarningKind kind;

  /// Native snake-case warning category, retained for forward compatibility.
  final String rawKind;

  /// Creates a processing warning.
  const ProcessingWarning({
    required this.message,
    required this.kind,
    required this.rawKind,
  });

  /// Decodes a processing warning from JSON.
  factory ProcessingWarning.fromJson(Map<String, dynamic> json) {
    final rawKind = json['kind'] as String? ?? 'unknown';
    return ProcessingWarning(
      message: json['message'] as String? ?? '',
      kind: switch (rawKind) {
        'image_extraction_failed' => WarningKind.imageExtractionFailed,
        'encoding_fallback' => WarningKind.encodingFallback,
        'truncated_input' => WarningKind.truncatedInput,
        'malformed_html' => WarningKind.malformedHtml,
        'sanitization_applied' => WarningKind.sanitizationApplied,
        'depth_limit_exceeded' => WarningKind.depthLimitExceeded,
        _ => WarningKind.unknown,
      },
      rawKind: rawKind,
    );
  }
}

List<T> _mapList<T>(dynamic value, T Function(Map<String, dynamic>) decode) =>
    (value as List<dynamic>? ?? const [])
        .map((entry) => decode(_jsonMap(entry, 'list entry')))
        .toList(growable: false);

Map<String, dynamic> _jsonMap(dynamic value, String field) {
  if (value is Map) return Map<String, dynamic>.from(value);
  throw FormatException('Expected $field to be a JSON object.');
}

List<GridCell> _normalizeGridCells(List<GridCell> cells) {
  if (cells.isEmpty) return cells;

  // Rust 3.15.1 assigns columns independently within each source row. Reserve
  // columns from earlier row spans without constructing a dense visual grid.
  final normalized = <GridCell>[];
  final activeSpans = <_OccupiedSpan>[];
  var currentRow = -1;
  var cursor = 0;
  var rowOccupancy = <_OccupiedSpan>[];

  for (final cell in cells) {
    if (cell.row != currentRow) {
      currentRow = cell.row;
      activeSpans.removeWhere((span) => span.untilRow <= currentRow);
      rowOccupancy = List<_OccupiedSpan>.of(activeSpans);
      cursor = 0;
    }

    final width = _placementWidth(cell.colSpan);
    var column = _max(cell.col, cursor);
    while (true) {
      final overlapping = rowOccupancy.where(
        (span) => column < span.end && column + width > span.start,
      );
      if (overlapping.isEmpty) break;
      column = overlapping.fold(column, (next, span) => _max(next, span.end));
    }

    final placed = column == cell.col
        ? cell
        : GridCell(
            content: cell.content,
            row: cell.row,
            col: column,
            rowSpan: cell.rowSpan,
            colSpan: cell.colSpan,
            isHeader: cell.isHeader,
          );
    normalized.add(placed);

    final occupied = _OccupiedSpan(
      start: column,
      end: column + width,
      untilRow: currentRow + _max(cell.rowSpan, 1),
    );
    // The cursor already reserves preceding cells in the current row.
    if (cell.rowSpan > 1) activeSpans.add(occupied);
    cursor = column + width;
  }

  return List<GridCell>.unmodifiable(normalized);
}

int _placementWidth(int colSpan) => _max(colSpan, 1);

int _max(int left, int right) => left > right ? left : right;

class _OccupiedSpan {
  final int start;
  final int end;
  final int untilRow;

  const _OccupiedSpan({
    required this.start,
    required this.end,
    required this.untilRow,
  });
}
