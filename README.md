# sheller

[![Pub Version](https://img.shields.io/pub/v/sheller.svg)](https://pub.dev/packages/sheller)
[![Dart Package Docs](https://img.shields.io/badge/documentation-pub.dev-blue.svg)](https://pub.dev/documentation/sheller/latest/)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

Ergonomic utilities for interacting with shells and converting output. Useful for writing Dart scripts.

```dart

List<File> files = shellSync("cd $outputDir && dart pub run index_generator && find . -maxdepth 1 -type f");
```
### Table of Contents

1. [Examples](#examples)
2. [Valid Conversion Types](#valid-conversion-types)
3. [Custom Conversion Types](#custom-conversion-types)
4. [Real Use Case - Protobuf Package Generation Script Example](#real-use-case---protobuf-package-generation-script-example)

### Examples

```dart  
// int async
int number = await shell("echo 1");
assert(number == 1);
// json
String data = '{"id":1, "name":"lorem ipsum", "address":"dolor set amet"}';
Map<String, dynamic> json = shellSync('echo $data');
assert(json.entries.length == 3);
// List<double>
List<double> doubleList = shellSync('echo 1 2 3');
assert(doubleList.length == 3);
// Class version
ShellSync shellClass = ShellSync("echo 1");
int id = shellClass.rawResult.pid; // shell.rawResult.runtimeType == ProcessResult
String stringResult = shellClass.stringResult; // == "1"
int convertedResult = shellClass(); // == 1
```

### Valid Conversion Types

```
int
double
num
BigInt
String
bool
List<String>
List<int>
List<double>
List<num>
List<BigInt>
List<bool>
Map<String, dynamic>
Set<int>
Set<double>
Set<num>
Set<BigInt>
Set<String>
Set<bool>
Object
FileSystemEntity
List<FileSystemEntity>
Set<FileSystemEntity>
Directory
List<Directory>
Set<Directory>
File
List<File>
Set<File>
Link
List<Link>
Set<Link>
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
  validate(() => Directory.current.path.split(osPathSeparator).last == "lib");
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
  print(shellSync(command));

  var toCopyOver = "../to_copy_over";
  Directory(toCopyOver).copyToSync(Directory(outputDir));

  final generateBarrelFileCommand = "cd $outputDir && dart pub run index_generator";
  print(shellSync(generateBarrelFileCommand));
}
```