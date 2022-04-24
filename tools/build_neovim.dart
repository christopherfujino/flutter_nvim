import 'lib/utils.dart' as utils;

Future<void> main() async {
  print('Making NeoVim...');
  final neovimPath = utils.joinPath(<String>[
    utils.repoRoot.absolute.path,
    'third_party',
    'neovim',
  ]);
  await utils.stream(
    'make',
    env: {'CMAKE_BUILD_TYPE': 'RelWithDebInfo'},
    workingDirectory: neovimPath,
  );


  final binPath = utils.joinPath(<String>[neovimPath, 'build', 'bin', 'nvim']);
  print('checking the existence of $binPath...');
  utils.checkPath(binPath);
}
