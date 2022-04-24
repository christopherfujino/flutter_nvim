import 'dart:io' as io;

/// Asynchronously run a [Process] with inherited STDIO.
Future<void> stream(
  String executable, {
  List<String> args = const <String>[],
  Map<String, String>? env,
  String? workingDirectory,
}) async {
  final process = await io.Process.start(
    executable,
    args,
    mode: io.ProcessStartMode.inheritStdio,
    environment: env,
    workingDirectory: workingDirectory,
  );
  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    throw Exception(
      'Command "$executable ${args.join(' ')}" failed with code $exitCode',
    );
  }
}

/// Root //flutter_nvim [io.Directory].
///
/// This assumes the entrypoint is a dart file in //flutter_nvim/tools.
io.Directory get repoRoot {
  final io.File script = io.File.fromUri(io.Platform.script);
  return script
      // flutter_nvim/tools/
      .parent
      // flutter_nvim/
      .parent;
}

/// Synchronously verify that a [io.File] exists.
///
/// Will throw an [Exception] if the file does not exist.
void checkFile(io.File file) {
  if(!file.existsSync()) {
    throw Exception('The file ${file.absolute.path} does not exist!');
  }
}

/// Synchronously verify that a path exists on disk.
///
/// Will throw an [Exception] if the path does not exist.
void checkPath(String path) {
  final type = io.FileSystemEntity.typeSync(path);
  final io.FileSystemEntity entity;
  if (type == io.FileSystemEntityType.file) {
    entity = io.File(path);
  } else if (type == io.FileSystemEntityType.directory) {
    entity = io.Directory(path);
  } else {
    throw Exception('Unknown FileSystemEntityType $type');
  }
  if (!entity.existsSync()) {
    throw Exception('The path $path does not exist on disk!');
  }
}

String joinPath(List<String> parts) {
  return parts.join(io.Platform.pathSeparator);
}
