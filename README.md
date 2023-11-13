# sheller

Convenience utilities for interacting with and converting shell output. Useful for writing dart scripts.

### Example

```dart

List<Directory> files = shellSync("cd $outputDir && dart pub run index_generator && ls -d */");
```

### More Examples

```dart
// int
int y = await shell("echo 1");
expect(y, 1);
// json
String data = '{"id":1, "name":"lorem ipsum", "address":"dolor set amet"}';
Map<String, dynamic> w = await shell('echo $data');
expect(w.entries.length, 3);
// List<double>
List<double> d = await shell('echo 1 2 3');
expect(d.length, 3);
// Class version
ShellSync shellClass = ShellSync("echo 1");
int id = shell.rawResult.pid; // shell.rawResult.runtimeType == ProcessResult
String stringResult = shell.stringResult; // == "1"
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