class HtmlTestData {
  static String get simpleHtml => '''
    <h1>Hello World</h1>
    <p>This is a simple paragraph.</p>
  ''';

  static String get complexHtml => '''
    <html>
      <head>
        <title>Complex HTML Document</title>
      </head>
      <body>
        <h1>Main Heading</h1>
        <h2>Sub Heading</h2>
        <p>This is a <strong>bold</strong> paragraph with <em>italic</em> text and a <a href="https://example.com">link</a>.</p>
        <ul>
          <li>List item 1</li>
          <li>List item 2</li>
          <li>List item 3</li>
        </ul>
        <ol>
          <li>Ordered item 1</li>
          <li>Ordered item 2</li>
        </ol>
        <blockquote>This is a blockquote.</blockquote>
        <code>This is inline code.</code>
        <pre><code>This is a code block.</code></pre>
        <table>
          <thead>
            <tr>
              <th>Header 1</th>
              <th>Header 2</th>
              <th>Header 3</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>Cell 1</td>
              <td>Cell 2</td>
              <td>Cell 3</td>
            </tr>
            <tr>
              <td>Cell 4</td>
              <td>Cell 5</td>
              <td>Cell 6</td>
            </tr>
          </tbody>
        </table>
        <hr>
        <img src="image.jpg" alt="An image">
      </body>
    </html>
  ''';

  static String get nestedHtml => '''
    <article>
      <header>
        <h1>Article Title</h1>
        <meta name="author" content="John Doe">
      </header>
      <section>
        <h2>Introduction</h2>
        <p>This is the introduction paragraph.</p>
        <div>
          <p>Nested div content.</p>
          <p>Another paragraph in the div.</p>
        </div>
      </section>
      <section>
        <h2>Main Content</h2>
        <div>
          <h3>Subsection</h3>
          <ul>
            <li>
              <span>Item 1 with <em>nested</em> element</span>
            </li>
            <li>
              <span>Item 2 with <strong>nested</strong> element</span>
            </li>
          </ul>
        </div>
        <div>
          <h3>Another Subsection</h3>
          <p>Content with <a href="#">nested <strong>link</strong></a>.</p>
          <blockquote>
            <p>A nested blockquote with <em>emphasis</em>.</p>
          </blockquote>
        </div>
      </section>
    </article>
  ''';

  static String get largeHtml => generateLargeHtml(50);

  static String generateLargeHtml(int sections) {
    final buffer = StringBuffer();
    buffer.writeln('<!DOCTYPE html>');
    buffer.writeln('<html>');
    buffer.writeln('<head>');
    buffer.writeln('  <title>Large HTML Document</title>');
    buffer.writeln('</head>');
    buffer.writeln('<body>');

    for (int i = 1; i <= sections; i++) {
      buffer.writeln('  <section>');
      buffer.writeln('    <h1>Section $i</h1>');
      buffer.writeln('    <p>This is section $i with some content.</p>');

      buffer.writeln('    <h2>Subsection $i.1</h2>');
      buffer.writeln(
        '    <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.</p>',
      );

      buffer.writeln('    <ul>');
      for (int j = 1; j <= 5; j++) {
        buffer.writeln('      <li>List item $i.$j</li>');
      }
      buffer.writeln('    </ul>');

      buffer.writeln('    <h2>Subsection $i.2</h2>');
      buffer.writeln(
        '    <p>Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.</p>',
      );
      buffer.writeln(
        '    <blockquote>This is a blockquote in section $i.</blockquote>',
      );

      if (i % 5 == 0) {
        buffer.writeln('    <table>');
        buffer.writeln('      <thead>');
        buffer.writeln('        <tr>');
        buffer.writeln('          <th>Column 1</th>');
        buffer.writeln('          <th>Column 2</th>');
        buffer.writeln('          <th>Column 3</th>');
        buffer.writeln('        </tr>');
        buffer.writeln('      </thead>');
        buffer.writeln('      <tbody>');
        for (int k = 1; k <= 3; k++) {
          buffer.writeln('        <tr>');
          buffer.writeln('          <td>Data $i-$k-1</td>');
          buffer.writeln('          <td>Data $i-$k-2</td>');
          buffer.writeln('          <td>Data $i-$k-3</td>');
          buffer.writeln('        </tr>');
        }
        buffer.writeln('      </tbody>');
        buffer.writeln('    </table>');
      }

      if (i % 3 == 0) {
        buffer.writeln('    <h2>Code Example $i</h2>');
        buffer.writeln('    <pre><code>');
        buffer.writeln('function example$i() {');
        buffer.writeln('  return "This is code section $i";');
        buffer.writeln('}');
        buffer.writeln('</code></pre>');
      }

      buffer.writeln('  </section>');
      buffer.writeln('  <hr>');
    }

    buffer.writeln('</body>');
    buffer.writeln('</html>');

    return buffer.toString();
  }

  static int get simpleHtmlLength => simpleHtml.length;
  static int get complexHtmlLength => complexHtml.length;
  static int get nestedHtmlLength => nestedHtml.length;
  static int get largeHtmlLength => largeHtml.length;
}
