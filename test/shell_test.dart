import 'dart:io';

import 'package:sheller/async.dart';
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
    final Map<String, dynamic> json;
    if (Platform.isWindows) {
      json = await $(
          'echo {"id":1, "name":"lorem ipsum", "address":"dolor set amet"}')();
    } else if (Platform.isLinux || Platform.isMacOS) {
      json = await $(
          'echo {\\"id\\":1, \\"name\\":\\"lorem ipsum\\", \\"address\\":\\"dolor set amet\\"}')();
    } else {
      throw "Platform not supported.";
    }
    expect(json.entries.length, 3);
  });

  test('List<double>', () async {
    final List<double> d = await $('echo 1 2   3').spaces();
    expect(d.length, 3);
  });

  test('file system', () async {
    if (Platform.isWindows) {
      final List<FileSystemEntity> _ = await $(r'dir /b /ad').lines();
    } else if (Platform.isLinux || Platform.isMacOS) {
      final List<FileSystemEntity> _ =
          await $(r'find "$(pwd)" -maxdepth 1 -type d').lines();
    } else {
      throw "Platform not supported.";
    }
  });

  test('Writing to file', () async {
    await ($("echo 1") > File("./temp"));
    await $("echo 2 > ./temp2")();
    await ($("echo 3") >> File("./temp"));
    await $("echo 4 >> ./temp2")();

    expect(File("./temp").readAsLinesSync(), ["1", "3"]);
    if (Platform.isWindows) {
      expect(File("./temp2").readAsLinesSync(), ["2 ", "4 "]);
    } else if (Platform.isLinux || Platform.isMacOS) {
      expect(File("./temp2").readAsLinesSync(), ["2", "4"]);
    }
  });

  test('Echo empty', () async {
    final command = 'echo ""';
    final String x = await $(command)();
    if (Platform.isWindows) {
      expect(x, '""');
    } else if (Platform.isLinux || Platform.isMacOS) {
      expect(x, '');
    }
  });

  test('String python truthy', () async {
    $ shell = $('echo ""');
    bool truthy = await shell();
    String text = await shell.text();
    if (Platform.isWindows) {
      expect(truthy, true);
      expect(text, '""');
    } else if (Platform.isLinux || Platform.isMacOS) {
      expect(truthy, false);
      expect(text, '');
    }
    shell = $('echo " "');
    truthy = await shell();
    text = await shell.text();
    if (Platform.isWindows) {
      expect(truthy, true);
      expect(text, '" "');
    } else if (Platform.isLinux || Platform.isMacOS) {
      expect(truthy, true);
      expect(text, ' ');
    }
  });
}
