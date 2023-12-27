// ignore_for_file: unused_local_variable

import 'dart:io';

import 'package:sheller/sheller.dart';

void main() async {
  // int
  int number = await $("echo 1")();
  assert(number == 1);
  // json
  String data = Platform.isWindows ? '{"id":1, "name":"lorem ipsum", "address":"dolor set amet"}' : '{\\"id\\":1, \\"name\\":\\"lorem ipsum\\", \\"address\\":\\"dolor set amet\\"}';
  Map<String, dynamic> json = await $('echo $data')();
  assert(json.entries.length == 3);
  // List<double>
  List<double> doubleList = await $('echo 1 2 3')();
  assert(doubleList.length == 3);
  // Class version
  $ shellClass = $("echo 1");
  int id = (await shellClass.rawResult).pid;
  int convertedResult = await shellClass(); // == 1
}
