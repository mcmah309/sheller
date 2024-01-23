import 'dart:io';

import 'package:sheller/sheller_sync.dart';

// Linux
void main() async {
  // int
  int number = $("echo 1")();
  assert(number == 1);
  // json
  String data =
      '{\\"id\\":1, \\"name\\":\\"lorem ipsum\\", \\"address\\":\\"dolor set amet\\"}';
  Map<String, dynamic> json = $('echo $data')();
  assert(json.entries.length == 3);
  // List<double>
  List<double> doubleList = $('echo 1 2 3').spaces();
  assert(doubleList.length == 3);
  // The class
  $ shellClass = $("echo 1");
  int id = shellClass.pid;
  int convertedResult = shellClass();
  assert(convertedResult == 1);
  // Writing to a file
  $("echo 1") > File("./temp"); // == $("echo 1 > ./temp")();
  // Appending to a file
  $("echo 2") >> File("./temp"); // == $("echo 2 >> ./temp")();
}
