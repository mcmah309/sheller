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
    String data;
    if(Platform.isWindows){
      data = '{"id":1, "name":"lorem ipsum", "address":"dolor set amet"}';
    }
    else if(Platform.isLinux || Platform.isMacOS){
      data = '{\\"id\\":1, \\"name\\":\\"lorem ipsum\\", \\"address\\":\\"dolor set amet\\"}';
    }
    else {
      throw "Platform not supported.";
    }
    final Map<String, dynamic> w = await $('echo $data')();
    expect(w.entries.length, 3);
  });

  test('List<double>', () async {
    final List<double> d = await $('echo 1 2   3').spaces();
    expect(d.length, 3);
  });

  test('file system', () async {
    if(Platform.isWindows){
      final List<FileSystemEntity> _ = await $(r'dir /b /ad').lines();
    }
    else if(Platform.isLinux || Platform.isMacOS){
      final List<FileSystemEntity> _ = await $(r'find "$(pwd)" -maxdepth 1 -type d').lines();
    }
    else {
      throw "Platform not supported.";
    }
  });

  test('Writing to file', () async {
    await ($("echo 1") > File("./temp"));
    await $("echo 2 > ./temp2")();
    await ($("echo 3") >> File("./temp"));
    await $("echo 4 >> ./temp2")();

    expect(File("./temp").readAsLinesSync(), ["1", "3"]);
    expect(File("./temp2").readAsLinesSync(), ["2", "4"]);
  });

  test('Echo empty', () async {
    final command = 'echo ""';
    final String x = await $(command)();
    expect(x, "");
  });

  test('String python truthy', () async {
    bool x = await $('echo ""')();
    expect(x, false);
    x = await $('echo " "')();
    expect(x, true);
  });
}
