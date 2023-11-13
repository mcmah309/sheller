import 'dart:io';

import 'package:sheller/sheller.dart';
import 'package:test/test.dart';

void main() {
  test('Shell lazily throws error', () async {
    final shell = Shell("exit 1");
    await shell.rawResult;
    await Future.delayed(Duration(seconds: 1));
    expect(() async => await shell.stringResult, throwsA(isA<ShellException>()));
  });

  test('int', () async {
    final int y = await shell("echo 1");
    expect(y, 1);
  });

  test('json', () async {
    String data = '{"id":1, "name":"lorem ipsum", "address":"dolor set amet"}';
    final Map<String, dynamic> w = await shell('echo $data');
    expect(w.entries.length, 3);
  });

  test('List<double>', () async {
    final List<double> d = await shell('echo 1 2 3');
    expect(d.length, 3);
  });

  test('sync', () {
    final int y = shellSync("echo 1");
    expect(y, 1);
  });

  test('file system', () {
    final command = Platform.isWindows ? 'dir /b /ad' : 'ls -d */';
    final List<FileSystemEntity> y = shellSync(command);
  });
}
