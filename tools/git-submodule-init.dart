import 'lib/utils.dart';

Future<void> main() async {
  final commands = [
    'submodule init',
    'submodule update',
  ];
  for (final command in commands) {
    print('About to run $command');
    await stream('git', args: command.split(' '));
  }
}
