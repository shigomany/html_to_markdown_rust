import 'package:html_to_markdown_rust/html_to_markdown_rust.dart';

void main() {
  const html = '''
<h1>Markdown Test</h1>
<p>This is a <strong>bold</strong> text and this is <em>italic</em>.</p>
<ul>
  <li>Item 1</li>
  <li>Item 2</li>
</ul>
<a href="https://example.com">Link</a>
''';

  // Basic conversion
  print('--- Basic Conversion ---');
  final markdown = htmlToMarkdown(html);
  print(markdown);

  // Conversion with options
  print('\n--- Conversion with Options ---');
  final options = ConversionOptions(
    headingStyle: HeadingStyle.setext,
    strongEmSymbol: '_',
    bullets: '*',
  );
  final markdownWithOptions = htmlToMarkdown(html, options);
  print(markdownWithOptions);

  // Conversion with metadata
  print('\n--- Conversion with Metadata ---');
  final result = htmlToMarkdownWithMetadata(
    html,
    metadataConfig: MetadataConfig(),
  );
  print('Markdown:');
  print(result.markdown);
  print('Metadata:');
  print('Title: ${result.metadata?.title}');
  print('Links: ${result.metadata?.links?.map((l) => l.href).toList()}');

  // Conversion with inline images (simulated since no images in sample HTML)
  print('\n--- Conversion with Inline Images ---');
  const htmlWithImage =
      '<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=" alt="Red dot" />';
  final imageResult = htmlToMarkdownWithInlineImages(htmlWithImage);
  print('Markdown:');
  print(imageResult.markdown);
  print('Images found: ${imageResult.inlineImages.length}');
  if (imageResult.inlineImages.isNotEmpty) {
    final img = imageResult.inlineImages.first;
    print('Image 1 format: ${img.format}');
    print('Image 1 source: ${img.source}');
  }
}
