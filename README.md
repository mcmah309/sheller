# sheller

[![Pub Version](https://img.shields.io/pub/v/sheller.svg)](https://pub.dev/packages/sheller)
[![Dart Package Docs](https://img.shields.io/badge/documentation-pub.dev-blue.svg)](https://pub.dev/documentation/sheller/latest/)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)
[![Build Status](https://github.com/mcmah309/sheller/actions/workflows/dart.yml/badge.svg)](https://github.com/mcmah309/sheller/actions)

Sheller brings ergonomic scripting to Dart by providing utilities for interacting with shells and converting output to Dart types. Allowing users to replace most or all of their scripts (e.g. bash or python) with Dart. e.g.
```dart
List<File> files = $("cd $dir && find . -maxdepth 1 -type f").lines();
```

### Table of Contents
1. [Example](#examples)
2. [Valid Conversion Types](#valid-conversion-types)
3. [Custom Conversion Types](#custom-conversion-types)
4. [Real Use Case - Protobuf Package Generation Script](#real-use-case---protobuf-package-generation-script)

### Example
With Sheller you can easily write sync or async Dart scripts that interact with the host platform on `Linux`, `MacOs`, or `Windows`.
```dart
import 'sheller/sync.dart';
// import 'sheller/async.dart'; // alternative

// Linux
void main() {
  // run process and print stdout to terminal
  print($("netstat")());
  // run process and convert to Dart type
  int number = $("echo 1")();
  assert(number == 1);
  // built in support for types like json
  String data ='{\\"id\\":1, \\"name\\":\\"lorem ipsum\\", \\"address\\":\\"dolor set amet\\"}';
  Map<String, dynamic> json = $('echo $data')();
  assert(json.entries.length == 3);
  // split by spaces then convert
  List<double> doubleList = $('echo 1  2   3').spaces();
  assert(doubleList.length == 3);
  // The class
  $ shellClassInstance = $("echo 1");
  int id = shellClassInstance.pid;
  int exitCode = shellClassInstance.exitCode;
  int convertedResult = shellClassInstance();
  assert(convertedResult == 1);
  // split by lines then convert
  List<File> files = $("find . -maxdepth 1 -type f").lines();
  // Writing to a file
  $("echo 1") > File("./temp");
  // Appending to a file
  $("echo 2") >> File("./temp");
}
```

### Valid Conversion Types
Built in conversions for `stdout` of successful shells to
```dart
int
double
num
BigInt
String
bool // empty is false, non-empty is true.
Map<String, dynamic>
Object
FileSystemEntity
Directory
File
Link
```

### Custom Conversion Types
Easily add your own custom conversion types to convert the output of the shell to a dart type. e.g.
```dart
class IntConverter extends Converter<String, int> {
  const IntConverter();

  @override
  int convert(String input) {
    int? result = int.tryParse(input);
    if (result == null) {
      throw ShellConversionException(int, input);
    }
    return 99999;
  }
}

void main() {
  ShellConfig.addConverter(const IntConverter());
  int number = $("echo 1")();
  assert(number == 99999);
}
```

### Real Use Case - Protobuf Package Generation Script
```dart
void main() async {
  const protoFilesDir = "../../proto";
  const outputDir = "../generated";
  const outputSrcDir = "../generated/lib/src";
  if(Directory(outputDir).existsSync()){
    Directory(outputDir).deleteSync(recursive: true);
  }
  Directory(outputSrcDir).createSync(recursive: true);

  final protoFiles = Directory(protoFilesDir)
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith(".proto"))
      .map((file) => file.path)
      .toList();

  final generateDartProtoFilesCommand = "protoc -I=$protoFilesDir --dart_out=grpc:$outputSrcDir ${protoFiles.join(' ')}";
  print($(generateDartProtoFilesCommand)());

  // Contains desired pubspec.yaml
  const toCopyOver = "./to_copy_over";
  print($("cp -r $toCopyOver/* $outputDir")());

  final generateBarrelFileCommand = "cd $outputDir && dart pub run index_generator";
  print($(generateBarrelFileCommand)());
  print("Done.");
}
```