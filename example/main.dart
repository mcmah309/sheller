import 'package:sheller/sheller.dart';

void main() async {
  // int
  int number = await shell("echo 1");
  assert(number == 1);
  // json
  String data = '{"id":1, "name":"lorem ipsum", "address":"dolor set amet"}';
  Map<String, dynamic> json = await shell('echo $data');
  assert(json.entries.length == 3);
  // List<double>
  List<double> doubleList = await shell('echo 1 2 3');
  assert(doubleList.length == 3);
  // Class version
  ShellSync shellClass = ShellSync("echo 1");
  int id = shellClass.rawResult.pid; // shell.rawResult.runtimeType == ProcessResult
  String stringResult = shellClass.stringResult; // == "1"
  int convertedResult = shellClass(); // == 1
}
