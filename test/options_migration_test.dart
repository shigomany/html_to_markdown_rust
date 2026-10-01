import 'dart:convert';

import 'package:html_to_markdown_rust/html_to_markdown_rust.dart';
import 'package:test/test.dart';

void main() {
  group('3.x option schema', () {
    test(
      'serializes conversion options with upstream names and enum values',
      () {
        const options = ConversionOptions(
          headingStyle: HeadingStyle.setext,
          newlineStyle: NewlineStyle.trailingSpaces,
          codeBlockStyle: CodeBlockStyle.tilde,
          highlightStyle: HighlightStyle.htmlMark,
          whitespaceMode: WhitespaceMode.preserve,
          skipImages: true,
          skipLinks: true,
          preprocessing: PreprocessingOptions(
            preset: PreprocessingPreset.none,
            removeNavigation: true,
            removeForms: true,
          ),
        );

        final json = jsonDecode(options.toJsonString()) as Map<String, dynamic>;
        expect(json['heading_style'], 'underlined');
        expect(json['newline_style'], 'spaces');
        expect(json['code_block_style'], 'tildes');
        expect(json['highlight_style'], 'html');
        expect(json['whitespace_mode'], 'strict');
        expect(json['skip_images'], isTrue);
        expect(json['skip_links'], isTrue);
        expect(json, isNot(contains('headingStyle')));
        expect(json['preprocessing'], {
          'enabled': false,
          'preset': 'minimal',
          'remove_navigation': true,
          'remove_forms': true,
        });
      },
    );

    test('legacy enum values map to supported upstream equivalents', () {
      const options = ConversionOptions(
        newlineStyle: NewlineStyle.preserve,
        highlightStyle: HighlightStyle.asterisk,
        whitespaceMode: WhitespaceMode.condense,
      );

      expect(options.toJson()['newline_style'], 'spaces');
      expect(options.toJson()['highlight_style'], 'bold');
      expect(options.toJson()['whitespace_mode'], 'normalized');
    });

    test('metadata and inline image configs use snake case', () {
      expect(
        const MetadataConfig(maxStructuredDataSize: 42).toJson(),
        containsPair('max_structured_data_size', 42),
      );
      expect(
        const InlineImageConfig(filenamePrefix: 'asset_').toJson(),
        containsPair('filename_prefix', 'asset_'),
      );
    });

    test('validates the unified structured-data size limit', () {
      expect(
        const MetadataConfig().toJson()['max_structured_data_size'],
        1000000,
      );
      expect(
        const MetadataConfig(maxStructuredDataSize: 1000000)
            .toJson()['max_structured_data_size'],
        1000000,
      );
      expect(
        () => const MetadataConfig(maxStructuredDataSize: -1).toJson(),
        throwsRangeError,
      );
      expect(
        () =>
            const MetadataConfig(maxStructuredDataSize: 2 * 1024 * 1024)
                .toJson(),
        throwsRangeError,
      );
    });
  });

  group('3.x result schema', () {
    test('parses external links and nested image dimensions', () {
      final metadata = DocumentMetadata.fromJson({
        'document': <String, dynamic>{},
        'links': [
          {
            'href': 'https://example.com',
            'text': 'Example',
            'link_type': 'external',
          },
        ],
        'images': [
          {
            'src': 'image.png',
            'dimensions': {'width': 320, 'height': 180},
          },
        ],
      });

      expect(metadata.links!.single.isExternal, isTrue);
      expect(metadata.images!.single.width, 320);
      expect(metadata.images!.single.height, 180);
    });

    test('decodes JSON-LD object and array raw_json entries', () {
      final metadata = DocumentMetadata.fromJson({
        'document': <String, dynamic>{},
        'structured_data': [
          {
            'data_type': 'json_ld',
            'raw_json': '{"@type":"Article","name":"One"}',
          },
          {
            'data_type': 'json_ld',
            'raw_json': '[{"@type":"Thing"},{"@type":"Person"}]',
          },
        ],
      });

      expect(metadata.structuredData, hasLength(3));
      expect(metadata.structuredData!.first['@type'], 'Article');
      expect(metadata.structuredData![1]['@type'], 'Thing');
      expect(metadata.structuredData![2]['@type'], 'Person');
    });

    test('parses upstream inline image source names', () {
      final dataUri = InlineImage.fromJson({
        'data': '',
        'format': 'png',
        'source': 'img_data_uri',
      });
      final svg = InlineImage.fromJson({
        'data': '',
        'format': 'svg',
        'source': 'svg_element',
      });

      expect(dataUri.source, InlineImageSource.dataUri);
      expect(svg.source, InlineImageSource.svgElement);
    });
  });

  group('FFI migration behavior', () {
    test('applies heading, bullet, and preprocessing setters', () {
      final markdown = htmlToMarkdown(
        '<nav>Menu</nav><h1>Title</h1><ul><li>Item</li></ul>',
        const ConversionOptions(
          headingStyle: HeadingStyle.setext,
          bullets: '*',
          preprocessing: PreprocessingOptions(
            enabled: true,
            preset: PreprocessingPreset.standard,
            removeNavigation: true,
          ),
        ),
      );

      expect(markdown, matches(RegExp(r'Title\n=+')));
      expect(markdown, contains('* Item'));
      expect(markdown, isNot(contains('Menu')));
    });

    test('extracts JSON-LD, external links, and image dimensions', () {
      final result = htmlToMarkdownWithMetadata('''
        <script type="application/ld+json">
          {"@context":"https://schema.org","@type":"Article"}
        </script>
        <a href="https://example.com">Example</a>
        <img src="image.png" width="64" height="32" alt="Image">
        ''', metadataConfig: const MetadataConfig());

      expect(result.metadata!.structuredData!.single['@type'], 'Article');
      expect(result.metadata!.links!.single.isExternal, isTrue);
      expect(result.metadata!.images!.single.width, 64);
      expect(result.metadata!.images!.single.height, 32);
    });

    test('a small structured-data limit drops oversized JSON-LD', () {
      final result = htmlToMarkdownWithMetadata(
        '<script type="application/ld+json">{"@type":"Article"}</script>',
        metadataConfig: const MetadataConfig(maxStructuredDataSize: 1),
      );

      expect(result.metadata?.structuredData, isEmpty);
    });

    test('honors disabled metadata categories', () {
      final result = htmlToMarkdownWithMetadata(
        '''
        <title>Hidden title</title>
        <meta name="description" content="Hidden description">
        <meta name="keywords" content="hidden, keywords">
        <h1>Hidden header</h1>
        <a href="https://example.com">Hidden link</a>
        <img src="hidden.png" alt="Hidden image">
        <script type="application/ld+json">{"@type":"Thing"}</script>
        ''',
        metadataConfig: const MetadataConfig(
          extractTitle: false,
          extractDescription: false,
          extractKeywords: false,
          extractHeaders: false,
          extractLinks: false,
          extractImages: false,
          extractStructuredData: false,
        ),
      );

      expect(result.metadata?.title, isNull);
      expect(result.metadata?.description, isNull);
      expect(result.metadata?.keywords, isEmpty);
      expect(result.metadata?.headers, isEmpty);
      expect(result.metadata?.links, isEmpty);
      expect(result.metadata?.images, isEmpty);
      expect(result.metadata?.structuredData, isEmpty);
    });

    test('captures SVG bytes with configured filename prefix', () {
      final result = htmlToMarkdownWithInlineImages(
        '<svg width="17" height="23"><rect width="17" height="23"/></svg>',
        imageConfig: const InlineImageConfig(
          filenamePrefix: 'asset_',
          captureSvg: true,
          inferDimensions: true,
        ),
      );

      expect(result.inlineImages, hasLength(1));
      expect(result.inlineImages.single.source, InlineImageSource.svgElement);
      expect(result.inlineImages.single.filename, startsWith('asset_'));
      expect(
        utf8.decode(result.inlineImages.single.dataBytes),
        contains('<svg'),
      );
      expect(result.inlineImages.single.width, isNull);
      expect(result.inlineImages.single.height, isNull);
    });

    test('captureSvg false excludes inline SVG elements', () {
      final result = htmlToMarkdownWithInlineImages(
        '<svg><rect width="1" height="1"/></svg>',
        imageConfig: const InlineImageConfig(captureSvg: false),
      );

      expect(result.inlineImages, isEmpty);
    });

    test('inferDimensions controls raster pixel dimensions', () {
      const html =
          '<img src="data:image/png;base64,'
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=" '
          'alt="dot">';

      final inferred = htmlToMarkdownWithInlineImages(
        html,
        imageConfig: const InlineImageConfig(inferDimensions: true),
      );
      final notInferred = htmlToMarkdownWithInlineImages(
        html,
        imageConfig: const InlineImageConfig(inferDimensions: false),
      );

      expect(inferred.inlineImages, hasLength(1));
      expect(inferred.inlineImages.single.width, 1);
      expect(inferred.inlineImages.single.height, 1);
      expect(notInferred.inlineImages, hasLength(1));
      expect(notInferred.inlineImages.single.width, isNull);
      expect(notInferred.inlineImages.single.height, isNull);
    });

    test('skipLinks keeps formatted link text and drops destination', () {
      final markdown = htmlToMarkdown(
        '<p>Read <a href="https://example.com"><strong>this</strong> now</a>.</p>',
        const ConversionOptions(skipLinks: true),
      );

      expect(markdown, contains('**this** now'));
      expect(markdown, isNot(contains('https://example.com')));
    });

    test('null and const options have parity across all public APIs', () {
      const html = '''
        <nav>Navigation</nav>
        <form><button>Submit</button></form>
        <p>First<br>Second</p>
        <ul><li>Outer<ul><li>Inner</li></ul></li></ul>
      ''';

      expect(
        htmlToMarkdown(html),
        htmlToMarkdown(html, const ConversionOptions()),
      );

      final defaultMetadata = htmlToMarkdownWithMetadata(html);
      final constMetadata = htmlToMarkdownWithMetadata(
        html,
        options: const ConversionOptions(),
      );
      expect(defaultMetadata.markdown, constMetadata.markdown);

      final defaultImages = htmlToMarkdownWithInlineImages(html);
      final constImages = htmlToMarkdownWithInlineImages(
        html,
        options: const ConversionOptions(),
      );
      expect(defaultImages.markdown, constImages.markdown);
    });
  });
}
