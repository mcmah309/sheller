import 'dart:io';

import 'package:sheller/sheller.dart';
import 'package:test/test.dart';

void main() {
  test('Shell lazily throws error', () async {
    final shell = $("exit 1");
    await Future.delayed(Duration(seconds: 1));
    expect(() async => await shell(), throwsA(isA<ShellException>()));
  });

  test('int', () async {
    final int y = await $("echo 1")();
    expect(y, 1);
  });

  test('json', () async {
    String data = Platform.isWindows ? '{"id":1, "name":"lorem ipsum", "address":"dolor set amet"}' : '{\\"id\\":1, \\"name\\":\\"lorem ipsum\\", \\"address\\":\\"dolor set amet\\"}';
    final Map<String, dynamic> w = await $('echo $data')();
    expect(w.entries.length, 3);
  });

  test('List<double>', () async {
    final List<double> d = await $('echo 1 2   3').spaces();
    expect(d.length, 3);
  });

  test('file system', () async {
    final command = Platform.isWindows ? 'dir /b /ad' : 'find "\$(pwd)" -maxdepth 1 -type d';
    final List<FileSystemEntity> _ = await $(command).lines();
  });
}
