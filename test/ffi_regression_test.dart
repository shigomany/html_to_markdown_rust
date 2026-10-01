import 'package:html_to_markdown_rust/html_to_markdown_rust.dart';
import 'package:test/test.dart';

void main() {
  const options = ConversionOptions(headingStyle: HeadingStyle.setext);

  test('htmlToMarkdown uses UTF-8 byte length and applies options', () {
    final markdown = htmlToMarkdown(
      '<h1>Заголовок 😀</h1><p>tail Ω после emoji</p>',
      options,
    );

    expect(markdown, matches(RegExp(r'Заголовок 😀\n=+')));
    expect(markdown, contains('tail Ω после emoji'));
  });

  test('htmlToMarkdown keeps text after an embedded NUL', () {
    final markdown = htmlToMarkdown('<p>before\u0000 after 😀 хвост</p>');

    expect(markdown, contains('after 😀 хвост'));
  });

  test('htmlToMarkdownWithMetadata preserves multibyte trailing content', () {
    final result = htmlToMarkdownWithMetadata(
      '<h1>Заголовок 😀</h1><p>tail Ω после emoji</p>',
      options: options,
      metadataConfig: const MetadataConfig(extractHeaders: true),
    );

    expect(result.markdown, matches(RegExp(r'Заголовок 😀\n=+')));
    expect(result.markdown, contains('tail Ω после emoji'));
    expect(result.metadata?.headers?.single.text, equals('Заголовок 😀'));
  });

  test('htmlToMarkdownWithMetadata keeps text after an embedded NUL', () {
    final result = htmlToMarkdownWithMetadata(
      '<p>before\u0000 after 😀 хвост</p>',
      metadataConfig: const MetadataConfig(extractHeaders: false),
    );

    expect(result.markdown, contains('after 😀 хвост'));
  });

  test(
    'htmlToMarkdownWithInlineImages preserves multibyte trailing content',
    () {
      final result = htmlToMarkdownWithInlineImages(
        '<h1>Заголовок 😀</h1><p>tail Ω после emoji</p>',
        options: options,
        imageConfig: const InlineImageConfig(filenamePrefix: 'regression_'),
      );

      expect(result.markdown, matches(RegExp(r'Заголовок 😀\n=+')));
      expect(result.markdown, contains('tail Ω после emoji'));
      expect(result.inlineImages, isEmpty);
    },
  );

  test('htmlToMarkdownWithInlineImages keeps text after an embedded NUL', () {
    final result = htmlToMarkdownWithInlineImages(
      '<p>before\u0000 after 😀 хвост</p>',
      imageConfig: const InlineImageConfig(filenamePrefix: 'regression_'),
    );

    expect(result.markdown, contains('after 😀 хвост'));
  });
}
