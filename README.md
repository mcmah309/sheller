# sheller

[![Pub Version](https://img.shields.io/pub/v/sheller.svg)](https://pub.dev/packages/sheller)
[![Dart Package Docs](https://img.shields.io/badge/documentation-pub.dev-blue.svg)](https://pub.dev/documentation/sheller/latest/)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

Ergonomic scripting in Dart. Utilities for interacting with shells and converting output to Dart types.

```dart
List<File> files = await $("cd $dir && find . -maxdepth 1 -type f").lines();
```
### Table of Contents

1. [Example](#examples)
2. [Valid Conversion Types](#valid-conversion-types)
3. [Custom Conversion Types](#custom-conversion-types)
4. [Real Use Case - Protobuf Package Generation Script Example](#real-use-case---protobuf-package-generation-script-example)

### Example
With Sheller you can esaily write Dart scripts that interact with the host platform.
```dart  
// Linux
void main() async {
  // int
  int number = await $("echo 1")();
  assert(number == 1);
  // json
  String data ='{\\"id\\":1, \\"name\\":\\"lorem ipsum\\", \\"address\\":\\"dolor set amet\\"}';
  Map<String, dynamic> json = await $('echo $data')();
  assert(json.entries.length == 3);
  // List<double>
  List<double> doubleList = await $('echo 1 2 3').spaces();
  assert(doubleList.length == 3);
  // The class
  $ shellClass = $("echo 1");
  int id = await shellClass.pid;
  int convertedResult = await shellClass();
  assert(convertedResult == 1);
  // Writing to a file
  await ($("echo 1") > File("./temp")); // == await $("echo 1 > ./temp")();
  // Appending to a file
  await ($("echo 2") >> File("./temp")); // == await $("echo 2 >> ./temp")();
}
```

### Valid Conversion Types
Convert `stdout` of successful shells to
```
int
double
num
BigInt
String
bool (empty is true)
Map<String, dynamic>
Object
FileSystemEntity
Directory
File
Link
```

### Custom Conversion Types

```dart
class IntConverter extends Converter<String, int> {
  const IntConverter();

  @override
  int convert(String input) {
    int? result = int.tryParse(input);
    if (result == null) {
      throw ShellResultConversionException(int, input);
    }
    return result;
  }
}

ShellConversionConfig.add(const IntConverter());
```

### Real Use Case - Protobuf Package Generation Script Example
```dart
Future<void> main() async {
  String osPathSeparator = path.separator;
  assert(Directory.current.path.split(osPathSeparator).last == "lib");
  var protoFilesDir = "../../../proto";
  var outputDir = "../../generated";
  var outputSrcDir = "../../generated/lib/src";
  Directory(outputDir).deleteSync(recursive: true);
  Directory(outputSrcDir).createSync(recursive: true);

  var protoFiles = Directory(protoFilesDir)
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith(".proto"))
      .map((file) => file.path)
      .toList();

  var command = "protoc -I=$protoFilesDir --dart_out=grpc:$outputSrcDir ${protoFiles.join(' ')} google/protobuf/empty.proto";
  print(await $(command)());

  var toCopyOver = "../to_copy_over";
  // Contains desired pubspec.yaml
  Directory(toCopyOver).copyToSync(Directory(outputDir));

  final generateBarrelFileCommand = "cd $outputDir && dart pub run index_generator";
  print(await $(generateBarrelFileCommand)());
}
```