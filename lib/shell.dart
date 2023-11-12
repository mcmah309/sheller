import 'dart:convert';
import 'dart:io' as io;

Process<T> shell<T extends Object>(String cmd, [ShellConfig processConfig = const ShellConfig()]) {
  final converter = ShellConversionMap.get<T>();
  return Process._(cmd, processConfig, converter);
}

class ShellConversionMap {
  static final Map<Object, Converter<String, Object>> _map = {
    int: const IntConverter(),
    double: const DoubleConverter(),
    num: const NumConverter(),
    BigInt: const BigIntConverter(),
    String: const StringConverter(),
    bool: const BoolConverter(),
    List<String>: const ListStringConverter(),
    List<int>: const ListIntConverter(),
    List<double>: const ListDoubleConverter(),
    List<num>: const ListNumConverter(),
    List<BigInt>: const ListBigIntConverter(),
    List<bool>: const ListBoolConverter(),
    Map<String, dynamic>: JsonConverter(),
    Set<int>: const SetIntConverter(),
    Set<double>: const SetDoubleConverter(),
    Set<num>: const SetNumConverter(),
    Set<BigInt>: const SetBigIntConverter(),
    Set<String>: const SetStringConverter(),
    Set<bool>: const SetBoolConverter(),
  };

  static void add<T extends Object>(Converter<String, T> value) {
    _map[T] = value;
  }

  static Converter<String, T> get<T extends Object>() {
    assert(_map.containsKey(T), "ShellConversionMap does not contain a converter for ${T.toString()}");
    return _map[T] as Converter<String, T>;
  }
}

class ShellConfig {
  final String? workingDirectory;
  final Map<String, String>? environment;
  final bool includeParentEnvironment;
  final bool runInShell;
  final Encoding stdoutEncoding;
  final Encoding stderrEncoding;
  final bool trimResult;

  const ShellConfig({
    this.workingDirectory,
    this.environment,
    this.includeParentEnvironment = true,
    this.runInShell = true,
    this.stdoutEncoding = io.systemEncoding,
    this.stderrEncoding = io.systemEncoding,
    this.trimResult = true,
  });
}

class Process<T extends Object> {
  late final Future<T> result;

  Process._(String cmd, ShellConfig shellConfig, Converter<String, dynamic> converter) {
    result = io.Process.run(
      cmd,
      [],
      workingDirectory: shellConfig.workingDirectory ?? io.Directory.current.path,
      environment: shellConfig.environment,
      includeParentEnvironment: shellConfig.includeParentEnvironment,
      runInShell: shellConfig.runInShell,
      stdoutEncoding: shellConfig.stdoutEncoding,
      stderrEncoding: shellConfig.stderrEncoding,
    ).then((e) {
      if (e.exitCode != 0) {
        throw ShellException(e.exitCode, e.pid, e.stdout, e.stderr);
      }
      String stringResult = (e.stdout as String);
      if (shellConfig.trimResult) {
        stringResult = stringResult.trim();
      }
      return converter.convert(stringResult) as T;
    });
  }

  Future<T> call() {
    return result;
  }
}

class ShellException implements Exception {
  final int exitCode;
  final int pid;
  final String stdout;
  final String stderr;

  ShellException(this.exitCode, this.pid, this.stdout, this.stderr);

  @override
  String toString() {
    return """
    ShellException: The shell process $pid failed with
    
    Exit Code: $exitCode
    
    stdout: $stdout
    
    stderr: $stderr
    """;
  }
}

class ShellResultConversionException implements Exception {
  final String from;
  final Type to;

  ShellResultConversionException(this.to, this.from);

  @override
  String toString() {
    return """
    ShellResultConversionException: could not convert to $to from
    
    $from
    """;
  }
}

void main() async {
  final int y = await shell<int>("echo 1")();
  assert(y == 1);
  final String w = await shell<String>("echo 1")();
  assert(w == "1");
}

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

class DoubleConverter extends Converter<String, double> {
  const DoubleConverter();

  @override
  double convert(String input) {
    double? result = double.tryParse(input);
    if (result == null) {
      throw ShellResultConversionException(double, input);
    }
    return result;
  }
}

class NumConverter extends Converter<String, num> {
  const NumConverter();

  @override
  num convert(String input) {
    return int.tryParse(input) ?? double.tryParse(input) ?? (throw ShellResultConversionException(num, input));
  }
}

class BigIntConverter extends Converter<String, BigInt> {
  const BigIntConverter();

  @override
  BigInt convert(String input) {
    try {
      return BigInt.parse(input);
    } catch (e) {
      throw ShellResultConversionException(BigInt, input);
    }
  }
}

//************************************************************************//

class StringConverter extends Converter<String, String> {
  const StringConverter();

  @override
  String convert(String input) {
    return input;
  }
}

class BoolConverter extends Converter<String, bool> {
  const BoolConverter();

  @override
  bool convert(String input) {
    if (input.toLowerCase() == 'true') {
      return true;
    } else if (input.toLowerCase() == 'false') {
      return false;
    }
    throw ShellResultConversionException(bool, input);
  }
}

//************************************************************************//

class ListStringConverter extends Converter<String, List<String>> {
  const ListStringConverter();

  @override
  List<String> convert(String input) {
    return input.split('\n');
  }
}

class ListIntConverter extends Converter<String, List<int>> {
  const ListIntConverter();

  @override
  List<int> convert(String input) {
    return input.split('\n').map((e) => const IntConverter().convert(e)).toList();
  }
}

class ListDoubleConverter extends Converter<String, List<double>> {
  const ListDoubleConverter();

  @override
  List<double> convert(String input) {
    return input.split('\n').map((e) => const DoubleConverter().convert(e)).toList();
  }
}

class ListNumConverter extends Converter<String, List<num>> {
  const ListNumConverter();

  @override
  List<num> convert(String input) {
    return input.split('\n').map((e) => const NumConverter().convert(e)).toList();
  }
}

class ListBigIntConverter extends Converter<String, List<BigInt>> {
  const ListBigIntConverter();

  @override
  List<BigInt> convert(String input) {
    return input.split('\n').map((e) => const BigIntConverter().convert(e)).toList();
  }
}

class ListBoolConverter extends Converter<String, List<bool>> {
  const ListBoolConverter();

  @override
  List<bool> convert(String input) {
    return input.split('\n').map((e) => const BoolConverter().convert(e)).toList();
  }
}

//************************************************************************//

class JsonConverter extends Converter<String, Map<String, dynamic>> {
  const JsonConverter();

  @override
  Map<String, dynamic> convert(String input) {
    return json.decode(input);
  }
}

//************************************************************************//

class SetStringConverter extends Converter<String, Set<String>> {
  const SetStringConverter();

  @override
  Set<String> convert(String input) {
    return input.split('\n').toSet();
  }
}

class SetIntConverter extends Converter<String, Set<int>> {
  const SetIntConverter();

  @override
  Set<int> convert(String input) {
    return input.split('\n').map((e) => const IntConverter().convert(e)).toSet();
  }
}

class SetDoubleConverter extends Converter<String, Set<double>> {
  const SetDoubleConverter();

  @override
  Set<double> convert(String input) {
    return input.split('\n').map((e) => const DoubleConverter().convert(e)).toSet();
  }
}

class SetNumConverter extends Converter<String, Set<num>> {
  const SetNumConverter();

  @override
  Set<num> convert(String input) {
    return input.split('\n').map((e) => const NumConverter().convert(e)).toSet();
  }
}

class SetBigIntConverter extends Converter<String, Set<BigInt>> {
  const SetBigIntConverter();

  @override
  Set<BigInt> convert(String input) {
    return input.split('\n').map((e) => const BigIntConverter().convert(e)).toSet();
  }
}

class SetBoolConverter extends Converter<String, Set<bool>> {
  const SetBoolConverter();

  @override
  Set<bool> convert(String input) {
    return input.split('\n').map((e) => const BoolConverter().convert(e)).toSet();
  }
}
