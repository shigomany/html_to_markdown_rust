import 'package:html_to_markdown_rust/html_to_markdown_rust.dart';
import 'package:test/test.dart';

void main() {
  test('image warnings retain the source index after a successful image', () {
    final result = htmlToMarkdownWithInlineImages('''
      <svg><circle r="1"/></svg>
      <img src="data:image/png;base64,!!!" alt="invalid">
      ''');

    expect(result.inlineImages, hasLength(1));
    expect(result.warnings, hasLength(1));
    expect(result.warnings.single.index, 2);
    expect(result.warnings.single.message, contains('inline image 2:'));
  });

  test('configured image size limits prevent extraction', () {
    final result = htmlToMarkdownWithInlineImages(
      '<svg><circle r="1"/></svg>',
      imageConfig: const InlineImageConfig(maxDecodedSizeBytes: 1),
    );

    expect(result.inlineImages, isEmpty);
    expect(result.warnings, isNotEmpty);
    expect(result.warnings.first.index, 1);
  });
}
