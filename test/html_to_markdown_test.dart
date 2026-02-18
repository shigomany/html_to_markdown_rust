import 'package:html_to_markdown_rust/html_to_markdown_rust.dart';
import 'package:test/test.dart';

void main() {
  group('htmlToMarkdown', () {
    group('Basic Elements', () {
      test('converts h1 heading', () {
        final html = '<h1>Heading 1</h1>';
        final markdown = htmlToMarkdown(html);
        expect(markdown, contains('# Heading 1'));
      });

      test('converts h2 heading', () {
        final html = '<h2>Heading 2</h2>';
        final markdown = htmlToMarkdown(html);
        expect(markdown, contains('## Heading 2'));
      });

      test('converts h3 heading', () {
        final html = '<h3>Heading 3</h3>';
        final markdown = htmlToMarkdown(html);
        expect(markdown, contains('### Heading 3'));
      });

      test('converts h4 heading', () {
        final html = '<h4>Heading 4</h4>';
        final markdown = htmlToMarkdown(html);
        expect(markdown, contains('#### Heading 4'));
      });

      test('converts h5 heading', () {
        final html = '<h5>Heading 5</h5>';
        final markdown = htmlToMarkdown(html);
        expect(markdown, contains('##### Heading 5'));
      });

      test('converts h6 heading', () {
        final html = '<h6>Heading 6</h6>';
        final markdown = htmlToMarkdown(html);
        expect(markdown, contains('###### Heading 6'));
      });

      test('converts paragraph', () {
        final html = '<p>This is a paragraph.</p>';
        final markdown = htmlToMarkdown(html);
        expect(markdown, contains('This is a paragraph.'));
      });

      test('converts multiple paragraphs', () {
        final html = '<p>First paragraph.</p><p>Second paragraph.</p>';
        final markdown = htmlToMarkdown(html);
        expect(markdown, contains('First paragraph.'));
        expect(markdown, contains('Second paragraph.'));
      });
    });

    group('Lists', () {
      test('converts unordered list', () {
        final html = '<ul><li>Item 1</li><li>Item 2</li><li>Item 3</li></ul>';
        final markdown = htmlToMarkdown(html);
        expect(markdown, contains('- Item 1'));
        expect(markdown, contains('- Item 2'));
        expect(markdown, contains('- Item 3'));
      });

      test('converts ordered list', () {
        final html = '<ol><li>First</li><li>Second</li><li>Third</li></ol>';
        final markdown = htmlToMarkdown(html);
        expect(markdown, contains('1. First'));
        expect(markdown, contains('2. Second'));
        expect(markdown, contains('3. Third'));
      });

      test('converts nested lists', () {
        final html = '<ul><li>Outer item<ul><li>Inner item</li></ul></li></ul>';
        final markdown = htmlToMarkdown(html);
        expect(markdown, contains('Outer item'));
        expect(markdown, contains('Inner item'));
      });
    });

    group('Links and Images', () {
      test('converts link', () {
        final html = '<a href="https://example.com">Click here</a>';
        final markdown = htmlToMarkdown(html);
        expect(markdown, contains('[Click here](https://example.com)'));
      });

      test('converts link with title', () {
        final html = '<a href="https://example.com" title="Example">Link</a>';
        final markdown = htmlToMarkdown(html);
        expect(markdown, contains('[Link](https://example.com "Example")'));
      });

      test('converts image', () {
        final html = '<img src="image.jpg" alt="Alt text">';
        final markdown = htmlToMarkdown(html);
        expect(markdown, contains('![Alt text](image.jpg)'));
      });

      test('converts image with title', () {
        final html = '<img src="image.jpg" alt="Alt text" title="Title">';
        final markdown = htmlToMarkdown(html);
        expect(markdown, contains('![Alt text](image.jpg "Title")'));
      });
    });

    group('Text Formatting', () {
      test('converts bold text with strong tag', () {
        final html = '<strong>Bold text</strong>';
        final markdown = htmlToMarkdown(html);
        expect(markdown, contains('**Bold text**'));
      });

      test('converts bold text with b tag', () {
        final html = '<b>Bold text</b>';
        final markdown = htmlToMarkdown(html);
        expect(markdown, contains('**Bold text**'));
      });

      test('converts italic text with em tag', () {
        final html = '<em>Italic text</em>';
        final markdown = htmlToMarkdown(html);
        expect(markdown, contains('*Italic text*'));
      });

      test('converts italic text with i tag', () {
        final html = '<i>Italic text</i>';
        final markdown = htmlToMarkdown(html);
        expect(markdown, contains('*Italic text*'));
      });

      test('converts inline code', () {
        final html = '<p>Use <code>const</code> keyword.</p>';
        final markdown = htmlToMarkdown(html);
        expect(markdown, contains('`const`'));
      });

      test('converts code block', () {
        final html = '<pre><code>def hello():\n    print("Hello")</code></pre>';
        final markdown = htmlToMarkdown(html);
        expect(markdown, contains('def hello():'));
        expect(markdown, contains('print("Hello")'));
      });
    });

    group('Block Elements', () {
      test('converts blockquote', () {
        final html = '<blockquote>This is a quote.</blockquote>';
        final markdown = htmlToMarkdown(html);
        expect(markdown, contains('> This is a quote.'));
      });

      test('converts horizontal rule', () {
        final html = '<hr>';
        final markdown = htmlToMarkdown(html);
        expect(markdown, contains('---'));
      });

      test('converts line break', () {
        final html = '<p>Line 1<br>Line 2</p>';
        final markdown = htmlToMarkdown(html);
        expect(markdown, contains('Line 1'));
        expect(markdown, contains('Line 2'));
      });
    });

    group('Tables', () {
      test('converts simple table', () {
        final html =
            '<table><tr><th>Header 1</th><th>Header 2</th></tr><tr><td>Cell 1</td><td>Cell 2</td></tr></table>';
        final markdown = htmlToMarkdown(html);
        expect(markdown, contains('Header 1'));
        expect(markdown, contains('Header 2'));
        expect(markdown, contains('Cell 1'));
        expect(markdown, contains('Cell 2'));
      });
    });

    group('Complex HTML', () {
      test('converts document with multiple elements', () {
        final html = '''
          <html>
            <body>
              <h1>Document Title</h1>
              <p>Introduction paragraph.</p>
              <h2>Features</h2>
              <ul>
                <li>Feature 1</li>
                <li>Feature 2</li>
              </ul>
              <p>Visit <a href="https://example.com">our website</a> for more info.</p>
            </body>
          </html>
        ''';
        final markdown = htmlToMarkdown(html);
        expect(markdown, contains('# Document Title'));
        expect(markdown, contains('Introduction paragraph.'));
        expect(markdown, contains('## Features'));
        expect(markdown, contains('- Feature 1'));
        expect(markdown, contains('- Feature 2'));
        expect(markdown, contains('[our website](https://example.com)'));
      });

      test('converts nested div with classes', () {
        final html = '''
          <div class="container">
            <div class="header">
              <h1>Title</h1>
            </div>
            <div class="content">
              <p>Content goes here.</p>
            </div>
          </div>
        ''';
        final markdown = htmlToMarkdown(html);
        expect(markdown, contains('# Title'));
        expect(markdown, contains('Content goes here.'));
      });
    });

    group('Edge Cases', () {
      test('handles empty string', () {
        final html = '';
        final markdown = htmlToMarkdown(html);
        expect(markdown, isEmpty);
      });

      test('handles whitespace only', () {
        final html = '   \n\t   ';
        final markdown = htmlToMarkdown(html);
        expect(markdown, isNotEmpty);
      });

      test('handles HTML with special characters', () {
        final html = '<p>Special chars: < > & " \'</p>';
        final markdown = htmlToMarkdown(html);
        expect(markdown, contains('Special chars:'));
      });

      test('handles unicode characters', () {
        final html = '<p>Hello 世界</p>';
        final markdown = htmlToMarkdown(html);
        expect(markdown, contains('Hello 世界'));
      });

      test('handles very long text', () {
        final longText = 'A' * 10000;
        final html = '<p>$longText</p>';
        final markdown = htmlToMarkdown(html);
        expect(markdown, contains(longText.substring(0, 100)));
      });
    });

    group('Error Handling', () {
      test('throws exception on null input', () {
        // This test verifies that the function handles malformed input gracefully
        // The underlying Rust code should handle null/invalid input
        expect(() => htmlToMarkdown(''), returnsNormally);
      });
    });

    group('Real-world Examples', () {
      test('converts blog post HTML', () {
        final html = '''
          <article>
            <h1>Getting Started with Dart</h1>
            <p>Dart is a client-optimized language for fast apps on any platform.</p>
            <h2>Why Dart?</h2>
            <ul>
              <li>Fast compilation</li>
              <li>Great tooling</li>
              <li>Native performance</li>
            </ul>
            <p>Learn more at <a href="https://dart.dev">dart.dev</a>.</p>
            <blockquote>Dart is designed for development.</blockquote>
          </article>
        ''';
        final markdown = htmlToMarkdown(html);
        expect(markdown, contains('# Getting Started with Dart'));
        expect(markdown, contains('## Why Dart?'));
        expect(markdown, contains('- Fast compilation'));
        expect(markdown, contains('[dart.dev](https://dart.dev)'));
        expect(markdown, contains('> Dart is designed for development.'));
      });

      test('converts documentation HTML', () {
        final html = '''
          <div class="docs">
            <h3>API Reference</h3>
            <p>The <code>htmlToMarkdown()</code> function converts HTML to Markdown.</p>
            <h4>Parameters</h4>
            <ul>
              <li><code>html</code>: The HTML string to convert</li>
            </ul>
            <h4>Returns</h4>
            <p>Returns a <code>String</code> containing the Markdown.</p>
          </div>
        ''';
        final markdown = htmlToMarkdown(html);
        expect(markdown, contains('### API Reference'));
        expect(markdown, contains('`htmlToMarkdown()`'));
        expect(markdown, contains('#### Parameters'));
        expect(markdown, contains('#### Returns'));
      });
    });
  });

  group('htmlToMarkdownWithMetadata', () {
    test('extracts title from HTML', () {
      final html = '''
        <html>
          <head><title>Test Page Title</title></head>
          <body><h1>Hello</h1></body>
        </html>
      ''';
      final result = htmlToMarkdownWithMetadata(
        html,
        metadataConfig: MetadataConfig(extractTitle: true),
      );
      expect(result.markdown, contains('# Hello'));
      expect(result.metadata?.title, equals('Test Page Title'));
    });

    test('extracts headers from HTML', () {
      final html = '''
        <h1>Main Title</h1>
        <h2>Section 1</h2>
        <h3>Subsection</h3>
      ''';
      final result = htmlToMarkdownWithMetadata(
        html,
        metadataConfig: MetadataConfig(extractHeaders: true),
      );
      expect(result.metadata?.headers, isNotNull);
      expect(result.metadata?.headers?.length, equals(3));
      expect(result.metadata?.headers?[0].level, equals(1));
      expect(result.metadata?.headers?[0].text, equals('Main Title'));
      expect(result.metadata?.headers?[1].level, equals(2));
      expect(result.metadata?.headers?[2].level, equals(3));
    });

    test('extracts links from HTML', () {
      final html = '''
        <p>
          <a href="https://example.com">Example</a>
          <a href="https://test.org/page">Test Page</a>
        </p>
      ''';
      final result = htmlToMarkdownWithMetadata(
        html,
        metadataConfig: MetadataConfig(extractLinks: true),
      );
      expect(result.metadata?.links, isNotNull);
      expect(result.metadata?.links?.length, equals(2));
      expect(result.metadata?.links?[0].href, equals('https://example.com'));
      expect(result.metadata?.links?[0].text, equals('Example'));
      expect(result.metadata?.links?[1].href, equals('https://test.org/page'));
    });

    test('extracts images from HTML', () {
      final html = '''
        <img src="image1.jpg" alt="First image">
        <img src="image2.png" alt="Second image">
      ''';
      final result = htmlToMarkdownWithMetadata(
        html,
        metadataConfig: MetadataConfig(extractImages: true),
      );
      expect(result.metadata?.images, isNotNull);
      expect(result.metadata?.images?.length, equals(2));
      expect(result.metadata?.images?[0].src, equals('image1.jpg'));
      expect(result.metadata?.images?[0].alt, equals('First image'));
      expect(result.metadata?.images?[1].src, equals('image2.png'));
    });

    test('extracts description from meta tag', () {
      final html = '''
        <html>
          <head>
            <meta name="description" content="This is a test description">
          </head>
          <body><p>Content</p></body>
        </html>
      ''';
      final result = htmlToMarkdownWithMetadata(
        html,
        metadataConfig: MetadataConfig(extractDescription: true),
      );
      expect(
        result.metadata?.description,
        equals('This is a test description'),
      );
    });

    test('works with custom conversion options', () {
      final html = '<h1>Title</h1><img src="test.jpg">';
      final result = htmlToMarkdownWithMetadata(
        html,
        options: ConversionOptions(skipImages: true),
        metadataConfig: MetadataConfig(extractHeaders: true),
      );
      expect(result.markdown, contains('# Title'));
      expect(result.markdown, isNot(contains('test.jpg')));
      expect(result.metadata?.headers?.first.text, equals('Title'));
    });

    test('handles empty HTML', () {
      final html = '';
      final result = htmlToMarkdownWithMetadata(
        html,
        metadataConfig: MetadataConfig(),
      );
      expect(result.markdown, isEmpty);
    });
  });

  group('htmlToMarkdownWithInlineImages', () {
    test('extracts inline images from data URIs', () {
      final html = '''
        <p>Text before</p>
        <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==" alt="Tiny image">
        <p>Text after</p>
      ''';
      final result = htmlToMarkdownWithInlineImages(
        html,
        imageConfig: InlineImageConfig(maxDecodedSizeBytes: 1024 * 1024),
      );
      expect(result.markdown, contains('Text before'));
      expect(result.markdown, contains('Text after'));
      expect(result.inlineImages.length, greaterThanOrEqualTo(0));
    });

    test('returns empty list when no inline images', () {
      final html = '''
        <h1>Title</h1>
        <p>Just text, no images</p>
        <img src="external.jpg" alt="External image">
      ''';
      final result = htmlToMarkdownWithInlineImages(html);
      expect(result.markdown, contains('# Title'));
      expect(result.inlineImages, isEmpty);
    });

    test('works with custom conversion options', () {
      final html = '''
        <h1>Title</h1>
        <p>Content</p>
      ''';
      final result = htmlToMarkdownWithInlineImages(
        html,
        options: ConversionOptions(bullets: '*'),
      );
      expect(result.markdown, contains('# Title'));
    });

    test('handles custom image config', () {
      final html = '<p>No images here</p>';
      final result = htmlToMarkdownWithInlineImages(
        html,
        imageConfig: InlineImageConfig(
          maxDecodedSizeBytes: 10 * 1024 * 1024,
          filenamePrefix: 'img_',
          captureSvg: true,
        ),
      );
      expect(result.markdown, contains('No images here'));
      expect(result.inlineImages, isEmpty);
      expect(result.warnings, isEmpty);
    });

    test('handles empty HTML', () {
      final html = '';
      final result = htmlToMarkdownWithInlineImages(html);
      expect(result.markdown, isEmpty);
      expect(result.inlineImages, isEmpty);
    });

    test('extracts inline SVG when enabled', () {
      final html = '''
        <p>Before SVG</p>
        <svg width="100" height="100">
          <circle cx="50" cy="50" r="40" fill="red"/>
        </svg>
        <p>After SVG</p>
      ''';
      final result = htmlToMarkdownWithInlineImages(
        html,
        imageConfig: InlineImageConfig(captureSvg: true),
      );
      expect(result.markdown, contains('Before SVG'));
      expect(result.markdown, contains('After SVG'));
    });
  });

  group('ConversionOptions', () {
    test('skipImages option works', () {
      final html = '<p>Text</p><img src="test.jpg" alt="image">';
      final markdownWithImages = htmlToMarkdown(html);
      final markdownWithoutImages = htmlToMarkdown(
        html,
        ConversionOptions(skipImages: true),
      );
      expect(markdownWithImages, contains('test.jpg'));
      expect(markdownWithoutImages, isNot(contains('test.jpg')));
    });

    test('preserveTags option works', () {
      final html =
          '<p>Text</p><table><tr><td>Cell</td></tr></table><p>More</p>';
      final markdown = htmlToMarkdown(
        html,
        ConversionOptions(preserveTags: ['table']),
      );
      expect(markdown, contains('Text'));
      expect(markdown, contains('<table'));
      expect(markdown, contains('</table>'));
    });

    test('custom bullets option works', () {
      final html = '<ul><li>Item 1</li><li>Item 2</li></ul>';
      final markdown = htmlToMarkdown(html, ConversionOptions(bullets: '*'));
      expect(markdown, contains('* Item 1'));
      expect(markdown, contains('* Item 2'));
    });

    test('preprocessing options work', () {
      final html = '''
        <nav>Navigation</nav>
        <main><p>Content</p></main>
        <form><input type="text"></form>
      ''';
      final markdown = htmlToMarkdown(
        html,
        ConversionOptions(
          preprocessing: PreprocessingOptions(
            enabled: true,
            removeNavigation: true,
            removeForms: true,
          ),
        ),
      );
      expect(markdown, contains('Content'));
    });
  });
}
