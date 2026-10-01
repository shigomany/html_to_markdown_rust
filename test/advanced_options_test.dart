import 'package:html_to_markdown_rust/html_to_markdown_rust.dart';
import 'package:test/test.dart';

void main() {
  group('advanced option schema', () {
    test('serializes all advanced fields with upstream wire names', () {
      const options = ConversionOptions(
        headingStyle: HeadingStyle.atxClosed,
        highlightStyle: HighlightStyle.none,
        escapeAscii: true,
        codeLanguage: 'dart',
        autolinks: false,
        defaultTitle: true,
        brInTables: true,
        compactTables: true,
        extractMetadata: false,
        stripNewlines: true,
        wrap: true,
        wrapWidth: 72,
        convertAsInline: true,
        subSymbol: '~',
        supSymbol: '^',
        keepInlineImagesIn: ['span'],
        outputFormat: OutputFormat.djot,
        linkStyle: LinkStyle.reference,
        urlEscapeStyle: UrlEscapeStyle.percent,
        includeDocumentStructure: true,
        extractImages: true,
        maxImageSize: 1024,
        captureSvg: true,
        inferDimensions: false,
        maxDepth: 0,
        excludeSelectors: ['.ad'],
        baseUrl: 'https://example.com/docs/',
        tierStrategy: TierStrategy.tier2,
      );

      expect(options.toJson(), containsPair('heading_style', 'atxclosed'));
      expect(options.toJson(), containsPair('highlight_style', 'none'));
      expect(options.toJson(), containsPair('output_format', 'djot'));
      expect(options.toJson(), containsPair('link_style', 'reference'));
      expect(options.toJson(), containsPair('url_escape_style', 'percent'));
      expect(options.toJson(), containsPair('max_depth', 0));
      expect(options.toJson(), containsPair('tier_strategy', 'tier2'));
      expect(options.toJson(), containsPair('base_url', options.baseUrl));
    });

    test('validates numeric fields before invoking native code', () {
      expect(
        () => const ConversionOptions(listIndentWidth: -1).toJson(),
        throwsRangeError,
      );
      expect(
        () => const ConversionOptions(wrapWidth: -1).toJson(),
        throwsRangeError,
      );
      expect(
        () => const ConversionOptions(maxImageSize: -1).toJson(),
        throwsRangeError,
      );
      expect(
        () => const ConversionOptions(
          extractImages: true,
          maxImageSize: 0,
        ).toJson(),
        throwsRangeError,
      );
      expect(
        () => const ConversionOptions(maxDepth: -1).toJson(),
        throwsRangeError,
      );
      expect(const ConversionOptions(maxDepth: 4096).toJson(), isNotEmpty);
    });
  });

  group('advanced FFI behavior', () {
    test('supports markdown, Djot, and plain output', () {
      const html = '<h1>Title</h1><p><strong>Important</strong></p>';

      final markdown = htmlToMarkdown(
        html,
        const ConversionOptions(outputFormat: OutputFormat.markdown),
      );
      final djot = htmlToMarkdown(
        html,
        const ConversionOptions(outputFormat: OutputFormat.djot),
      );
      final plain = htmlToMarkdown(
        html,
        const ConversionOptions(outputFormat: OutputFormat.plain),
      );

      expect(markdown, contains('# Title'));
      expect(djot, contains('Title'));
      expect(plain, contains('Important'));
      expect(plain, isNot(contains('**')));
      expect(plain, isNot(contains('#')));
    });

    test('resolves base URLs and renders reference links', () {
      final markdown = htmlToMarkdown(
        '<a href="guide/start.html">Start</a>',
        const ConversionOptions(
          baseUrl: 'https://example.com/docs/',
          linkStyle: LinkStyle.reference,
        ),
      );

      expect(markdown, contains('[Start][1]'));
      expect(
        markdown,
        contains('[1]: https://example.com/docs/guide/start.html'),
      );
    });

    test('excludes CSS matches and emits compact tables', () {
      const html = '''
        <p class="remove">Secret</p><p>Visible</p>
        <table><tr><th>Name</th><th>Value</th></tr>
        <tr><td>A</td><td>Long value</td></tr></table>
      ''';
      final aligned = htmlToMarkdown(html);
      final compact = htmlToMarkdown(
        html,
        const ConversionOptions(
          compactTables: true,
          excludeSelectors: ['.remove'],
        ),
      );

      expect(compact, contains('Visible'));
      expect(compact, isNot(contains('Secret')));
      expect(compact, contains('| --- | --- |'));
      expect(compact.length, lessThan(aligned.length));
    });

    test('wraps long prose and applies new rendering enums', () {
      final markdown = htmlToMarkdown(
        '<h2>Closed</h2><p><mark>mark</mark> '
        'one two three four five six seven eight nine ten</p>',
        const ConversionOptions(
          headingStyle: HeadingStyle.atxClosed,
          highlightStyle: HighlightStyle.none,
          wrap: true,
          wrapWidth: 20,
          tierStrategy: TierStrategy.tier2,
        ),
      );

      expect(markdown, contains('## Closed ##'));
      expect(markdown, contains('mark'));
      expect(markdown, isNot(contains('==mark==')));
      expect(markdown.trimRight().split('\n').length, greaterThan(2));
      expect(
        markdown.trimRight().split('\n').where((line) => line.isNotEmpty),
        everyElement(hasLength(lessThanOrEqualTo(20))),
      );
    });
  });

  group('metadata contracts', () {
    test('parses the complete upstream metadata model', () {
      final metadata = DocumentMetadata.fromJson({
        'document': {
          'title': 'Article',
          'author': 'Ada',
          'canonical_url': 'https://example.com/article',
          'base_href': 'https://example.com/',
          'language': 'en',
          'text_direction': 'ltr',
          'open_graph': {'title': 'Social title'},
          'twitter_card': {'card': 'summary'},
          'meta_tags': {'robots': 'index'},
        },
        'headers': [
          {
            'level': 1,
            'text': 'Article',
            'id': 'article',
            'depth': 2,
            'html_offset': 42,
          },
        ],
        'links': [
          {
            'href': 'mailto:author@example.com',
            'text': 'Email',
            'link_type': 'email',
            'rel': ['author'],
            'attributes': {'data-id': '7'},
          },
        ],
        'images': [
          {
            'src': 'data:image/png;base64,AA==',
            'image_type': 'data_uri',
            'attributes': {'loading': 'lazy'},
          },
        ],
        'structured_data': [
          {
            'data_type': 'json_ld',
            'raw_json': '{"@type":"Article"}',
            'schema_type': 'Article',
          },
        ],
      });

      expect(metadata.author, 'Ada');
      expect(metadata.textDirection, TextDirection.leftToRight);
      expect(metadata.openGraph['title'], 'Social title');
      expect(metadata.headers!.single.depth, 2);
      expect(metadata.headers!.single.htmlOffset, 42);
      expect(metadata.links!.single.linkType, LinkType.email);
      expect(metadata.links!.single.rel, ['author']);
      expect(metadata.images!.single.imageType, ImageType.dataUri);
      expect(
        metadata.structuredDataEntries!.single.dataType,
        StructuredDataType.jsonLd,
      );
      expect(metadata.structuredDataEntries!.single.schemaType, 'Article');
      expect(
        metadata.structuredDataEntries!.single.decoded['@type'],
        'Article',
      );
      expect(metadata.structuredData!.single['@type'], 'Article');
    });

    test('extracts rich metadata through FFI', () {
      final result = htmlToMarkdownWithMetadata('''
        <html lang="en" dir="rtl"><head>
          <title>Article</title>
          <meta name="author" content="Ada">
          <meta property="og:title" content="Social title">
          <script type="application/ld+json">{"@type":"Article"}</script>
        </head><body>
          <h1 id="article">Article</h1>
          <a href="mailto:author@example.com" rel="author">Email</a>
          <img src="photo.png" loading="lazy">
        </body></html>
      ''');

      final metadata = result.metadata!;
      expect(metadata.author, 'Ada');
      expect(metadata.language, 'en');
      expect(metadata.textDirection, TextDirection.rightToLeft);
      expect(metadata.openGraph['title'], 'Social title');
      expect(metadata.links!.single.linkType, LinkType.email);
      expect(metadata.images!.single.imageType, ImageType.relative);
      expect(metadata.structuredDataEntries!.single.schemaType, 'Article');
    });
  });
}
