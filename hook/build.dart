import 'dart:io';

import 'package:hooks/hooks.dart';
import 'package:logging/logging.dart';
import 'package:native_toolchain_rust/native_toolchain_rust.dart';

void main(List<String> args) async {
  final logger = Logger('html_to_markdown_rust');
  logger.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  try {
    await build(args, (input, output) async {
      const builder = RustBuilder(assetName: 'src/bindings.g.dart');
      await builder.run(input: input, output: output, logger: logger);
    });
  } on Object catch (e, st) {
    logger.warning('Failed to build native assets: \n$e');
    logger.warning('Stack trace: \n$st');
    exit(1);
  }
}
