import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

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


  /// Exit code of the process.
  Future<int> get exitCode => _rawResult.then((value) => value.exitCode);
  
  /// Process id of the process.
  Future<int> get pid => _rawResult.then((value) => value.pid);
  
  /// Raw stderr in bytes.
  Future<Uint8List> get stderr => _rawResult.then((value) => value.stderr as Uint8List);

  /// stderr as a [String].
  Future<String> get stderrAsString async {
    if (_stderrString != null) {
      return _stderrString!;
    }
    final rawResult = await _rawResult;
    _stderrString = const io.SystemEncoding().decode(rawResult.stderr);
    return _stderrString!;
  }
  
  /// Raw stdout in bytes.
  Future<Uint8List> get stdout => _rawResult.then((value) => value.stdout as Uint8List);

  /// stdout as a [String]. Prefer [text] if you need to check the exit code.
  Future<String> get stdoutAsString async {
    if (_stdoutString != null) {
      return _stdoutString!;
    }
    final rawResult = await _rawResult;
    _stdoutString = const io.SystemEncoding().decode(rawResult.stdout);
    return _stdoutString!;
  }


  late final Future<io.ProcessResult> _rawResult;
  String? _stringResult;
  String? _stderrString;
  String? _stdoutString;
  late final Future<String> Function(io.ProcessResult) _processResult;


  $(String cmd, [ShellConfig shellConfig = const ShellConfig()]) {
    final workingDirectory = shellConfig.workingDirectory ?? io.Directory.current.path;
    final executable = io.Platform.isLinux ? "/bin/sh" : cmd;
    final args = io.Platform.isLinux ? ["-c", "''${cmd.replaceAll("'", "\\'")}''"] : <String>[];
    _rawResult = io.Process.run(
      executable,
      args,
      workingDirectory: workingDirectory,
      environment: shellConfig.environment,
      includeParentEnvironment: shellConfig.includeParentEnvironment,
      runInShell: shellConfig.runInShell,
      stdoutEncoding: null,
      stderrEncoding: null,
    );
    _processResult = (io.ProcessResult e) async {
      if (e.exitCode != 0) {
        throw ShellException(executable, args, workingDirectory, e.exitCode, e.pid, e.stdout, e.stderr);
      }
      return stdoutAsString;
    };
  }

  /// True if the shell process exited with 0 as the exit code.
  Future<bool> isSuccess() async {
    return await exitCode == 0;
  }

  /// Converts into the desired type [T].
  /// Will throw a [ShellException] if the shell process did not
  /// exit with 0 as the status code. Will throw a [ShellResultConversionException] if cannot convert to the desired
  /// type [T].
  Future<T> call<T extends Object>() async {
    final converter = ShellConversionConfig.get<T>();
    return converter.convert(await text());
  }

  /// Returns the shells stdout. Will throw a [ShellException] if the shell process did not
  /// exit with 0 as the status code.
  Future<String> text() async {
    _stringResult ??= await _rawResult.then(_processResult);
    return _stringResult!;
  }

  /// Splits the output by spaces and converts each split into the desired type [T].
  /// Will throw a [ShellException] if the shell process did not
  /// exit with 0 as the status code. Will throw a [ShellResultConversionException] if cannot convert to the desired
  /// type [T].
  Future<List<T>> spaces<T extends Object>() => _callWithRegExp<T>(_spaces);

  /// Splits the output by newlines and converts each split into the desired type [T].
  /// Will throw a [ShellException] if the shell process did not
  /// exit with 0 as the status code. Will throw a [ShellResultConversionException] if cannot convert to the desired
  /// type [T].
  Future<List<T>>  lines<T extends Object>() => _callWithRegExp<T>(_newLines);

  /// Splits the output by whitespaces and converts each split into the desired type [T].
  /// Will throw a [ShellException] if the shell process did not
  /// exit with 0 as the status code. Will throw a [ShellResultConversionException] if cannot convert to the desired
  /// type [T].
  Future<List<T>>  whitespaces<T extends Object>() => _callWithRegExp<T>(_whitespaces);

  Future<List<T>>  _callWithRegExp<T extends Object>(RegExp splitter) async {
    final splits = await text().then((e) => e.split(splitter).where((e) => e.isNotEmpty));
    final converter = ShellConversionConfig.get<T>();
    return splits.map((e) => converter.convert(e)).toList();
  }


  Future<void> operator > (io.File file) async {
    await file.writeAsBytes(await stdout, mode: io.FileMode.writeOnly, flush: true);
  }

  Future<void> operator >> (io.File file) async {
    await file.writeAsBytes(await stdout, mode: io.FileMode.writeOnlyAppend, flush: true);
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
    io.FileSystemEntity: const FileSystemEntityConverter(),
    io.Directory: const DirectoryConverter(),
    io.File: const FileConverter(),
    io.Link: const LinkConverter(),
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

  const ShellConfig({
    this.workingDirectory,
    this.environment,
    this.includeParentEnvironment = true,
    this.runInShell = true,
  });
}
