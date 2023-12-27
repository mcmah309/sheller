import 'dart:convert';
import 'dart:io';

import 'base_type_converters.dart';
import 'exceptions.dart';
import 'file_system_converters.dart';


//************************************************************************//

/// Wrapper around [Process.run] that makes running a shell and converting the result back into a dart type more
/// convenient
class $ {
  static final RegExp _newLines = RegExp(r'\r?\n');
  static final RegExp _whitespaces = RegExp(r'\s+');
  static final RegExp _spaces = RegExp(r' ');


  late final Future<ProcessResult> rawResult;

  /// Returns the result as a [String]. Will throw a [ShellException] if the shell process did not exit with 0 as the
  /// status code.
  Future<String> get stringResult {
    if (_stringResult != null) {
      return _stringResult!;
    }
    _stringResult = rawResult.then(_processResultToString);
    return _stringResult!;
  }

  // Lazily evaluated so the Shell will not throw unless the Result as a string is requested
  Future<String>? _stringResult;
  late final String Function(ProcessResult) _processResultToString;

  $(String cmd, [ShellConfig shellConfig = const ShellConfig()]) {
    final workingDirectory = shellConfig.workingDirectory ?? Directory.current.path;
    final executable = Platform.isLinux ? "/bin/sh" : cmd;
    final args = Platform.isLinux ? ["-c", "''${cmd.replaceAll("'", "\\'")}''"] : <String>[];
    rawResult = Process.run(
      executable,
      args,
      workingDirectory: workingDirectory,
      environment: shellConfig.environment,
      includeParentEnvironment: shellConfig.includeParentEnvironment,
      runInShell: shellConfig.runInShell,
      stdoutEncoding: shellConfig.stdoutEncoding,
      stderrEncoding: shellConfig.stderrEncoding,
    );
    _processResultToString = (ProcessResult e) {
      if (e.exitCode != 0) {
        throw ShellException(
            executable, args, workingDirectory, e.exitCode, e.pid, e.stdout, e.stderr);
      }
      String stringResult = (e.stdout as String);
      if (shellConfig.trimResult) {
        stringResult = stringResult.trim();
      }
      return stringResult;
    };
  }

  /// Converts the shell result into the desired type [T]. Will throw a [ShellException] if the shell process did not
  /// exit with 0 as the status code. Will throw a [ShellResultConversionException] if cannot convert to the desired
  /// type [T].
  Future<T> call<T extends Object>([String? splitBy]) async {
    final converter = ShellConversionConfig.get<T>();
    return converter.convert(await stringResult);
  }

  /// Splits the output by spaces and converts each split into the desired type [T].
  /// Will throw a [ShellException] if the shell process did not
  /// exit with 0 as the status code. Will throw a [ShellResultConversionException] if cannot convert to the desired
  /// type [T].
  Future<List<T>> bySpaces<T extends Object>() => _callWithRegExp<T>(_spaces);

  /// Splits the output by newlines and converts each split into the desired type [T].
  /// Will throw a [ShellException] if the shell process did not
  /// exit with 0 as the status code. Will throw a [ShellResultConversionException] if cannot convert to the desired
  /// type [T].
  Future<List<T>>  byNewlines<T extends Object>() => _callWithRegExp<T>(_newLines);

  /// Splits the output by whitespaces and converts each split into the desired type [T].
  /// Will throw a [ShellException] if the shell process did not
  /// exit with 0 as the status code. Will throw a [ShellResultConversionException] if cannot convert to the desired
  /// type [T].
  Future<List<T>>  byWhitespaces<T extends Object>() => _callWithRegExp<T>(_whitespaces);

  Future<List<T>>  _callWithRegExp<T extends Object>(RegExp splitter) async {
    final splits = (await stringResult).split(splitter);
    final converter = ShellConversionConfig.get<T>();
    return splits.map((e) => converter.convert(e)).toList();
  }
}

//************************************************************************//

/// Configuration for conversions between shell results and dart types. Can be modified at runtime.
class ShellConversionConfig {
  static final Map<Object, Converter<String, Object>> _map = {
    int: const IntConverter(),
    double: const DoubleConverter(),
    num: const NumConverter(),
    BigInt: const BigIntConverter(),
    String: const StringConverter(),
    bool: const BoolConverter(),
    Object: const StringConverter(),
    Map<String, dynamic>: JsonConverter(),
    FileSystemEntity: const FileSystemEntityConverter(),
    Directory: const DirectoryConverter(),
    File: const FileConverter(),
    Link: const LinkConverter(),
  };

  static void add<T extends Object>(Converter<String, T> value) {
    _map[T] = value;
  }

  static Converter<String, T> get<T extends Object>() {
    assert(_map.containsKey(T),
        "ShellConversionMap does not contain a converter for ${T.toString()}");
    return _map[T] as Converter<String, T>;
  }

  static bool hasConverterFor<T extends Object>() {
    return _map.containsKey(T);
  }
}

/// Config for how the shell should behave
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
    this.stdoutEncoding = systemEncoding,
    this.stderrEncoding = systemEncoding,
    this.trimResult = true,
  });
}
