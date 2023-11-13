import 'dart:convert';
import 'dart:io';

import 'base_type_converters.dart';
import 'exceptions.dart';
import 'file_system_converters.dart';

/// Convenience function for executing a shell and converting the result to a dart type
Future<T> shell<T extends Object>(String cmd, [ShellConfig shellConfig = const ShellConfig()]) {
  return Shell(cmd, shellConfig)();
}

/// Wrapper around [Process.run] that makes running a shell and converting the result back into a dart type more
/// convenient
class Shell {
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

  Shell(String cmd, [ShellConfig shellConfig = const ShellConfig()]) {
    rawResult = Process.run(
      cmd,
      [],
      workingDirectory: shellConfig.workingDirectory ?? Directory.current.path,
      environment: shellConfig.environment,
      includeParentEnvironment: shellConfig.includeParentEnvironment,
      runInShell: shellConfig.runInShell,
      stdoutEncoding: shellConfig.stdoutEncoding,
      stderrEncoding: shellConfig.stderrEncoding,
    );
    _processResultToString = (ProcessResult e) {
      if (e.exitCode != 0) {
        throw ShellException(e.exitCode, e.pid, e.stdout, e.stderr);
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
  Future<T> call<T extends Object>() {
    return stringResult.then((s) {
      final converter = ShellConversionConfig.get<T>();
      return converter.convert(s);
    });
  }
}

//************************************************************************//

/// Convenience function for executing a shell and converting the result to a dart type
T shellSync<T extends Object>(String cmd, [ShellConfig shellConfig = const ShellConfig()]) {
  return ShellSync(cmd, shellConfig)();
}

/// Wrapper around [Process.runSync] that makes running a shell and converting the result back into a dart type more
/// convenient
class ShellSync {
  late final ProcessResult rawResult;

  /// Returns the result as a [String]. Will throw a [ShellException] if the shell process did not exit with 0 as the
  /// status code.
  String get stringResult {
    if (_stringResult != null) {
      return _stringResult!;
    }
    _stringResult = _processResultToString(rawResult);
    return _stringResult!;
  }

  // Lazily evaluated so the Shell will not throw unless the Result as a string is requested
  String? _stringResult;
  late final String Function(ProcessResult) _processResultToString;

  ShellSync(String cmd, [ShellConfig shellConfig = const ShellConfig()]) {
    rawResult = Process.runSync(
      cmd,
      [],
      workingDirectory: shellConfig.workingDirectory ?? Directory.current.path,
      environment: shellConfig.environment,
      includeParentEnvironment: shellConfig.includeParentEnvironment,
      runInShell: shellConfig.runInShell,
      stdoutEncoding: shellConfig.stdoutEncoding,
      stderrEncoding: shellConfig.stderrEncoding,
    );
    _processResultToString = (ProcessResult e) {
      if (e.exitCode != 0) {
        throw ShellException(e.exitCode, e.pid, e.stdout, e.stderr);
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
  T call<T extends Object>() {
    final converter = ShellConversionConfig.get<T>();
    return converter.convert(stringResult);
  }
}

//************************************************************************//

/// Configuration for conversions between shell results and dart types. Can be modified at runtime.
class ShellConversionConfig {
  /// regex splitter used by List and Set converters. Splits by whitespace. Consider changing to
  /// ```
  /// RegExp(r'\r?\n')
  /// ```
  /// If you prefer just newlines
  static RegExp splitter = RegExp(r'\s+');
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
    Object: const StringConverter(),
    FileSystemEntity: const FileSystemEntityConverter(),
    List<FileSystemEntity>: const ListFileSystemEntityConverter(),
    Set<FileSystemEntity>: const SetFileSystemEntityConverter(),
    Directory: const DirectoryConverter(),
    List<Directory>: const ListDirectoryConverter(),
    Set<Directory>: const SetDirectoryConverter(),
    File: const FileConverter(),
    List<File>: const ListFileConverter(),
    Set<File>: const SetFileConverter(),
    Link: const LinkConverter(),
    List<Link>: const ListLinkConverter(),
    Set<Link>: const SetLinkConverter(),
  };

  static void add<T extends Object>(Converter<String, T> value) {
    _map[T] = value;
  }

  static Converter<String, T> get<T extends Object>() {
    assert(_map.containsKey(T), "ShellConversionMap does not contain a converter for ${T.toString()}");
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