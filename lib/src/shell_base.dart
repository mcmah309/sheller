import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'base_type_converters.dart';
import 'exceptions.dart';
import 'file_system_converters.dart';

//************************************************************************//

/// Wrapper around [Process.run] that makes running a shell and converting the result back into a dart type more
/// convenient
abstract class $Base {
  static final RegExp newLinesExp = RegExp(r'[\r?\n]+');
  static final RegExp whitespacesExp = RegExp(r'\s+');
  static final RegExp spacesExp = RegExp(r' +');

  static final RegExp trailingNewLineExp = RegExp(r'[\r?\n]$');

  /// Exit code of the process.
  FutureOr<int> get exitCode;

  /// Process id of the process.
  FutureOr<int> get pid;

  /// Raw stderr in bytes.
  FutureOr<Uint8List> get stderr;

  /// stderr as a [String].
  FutureOr<String> get stderrAsString;

  /// Raw stdout in bytes.
  FutureOr<Uint8List> get stdout;

  /// stdout as a [String]. Prefer [text] if you need to check the exit code.
  FutureOr<String> get stdoutAsString;

  /// Converts into the desired type [T].
  /// Will throw a [ShellException] if the shell process did not
  /// exit with 0 as the exit code. Will throw a [ShellResultConversionException] if cannot convert to the desired
  /// type [T].
  FutureOr<T> call<T extends Object>();

  /// Returns the shells stdout with any trailing newline stripped. Will throw a [ShellException] if the shell process did not
  /// exit with 0 as the exit code.
  FutureOr<String> text();

  /// Splits the output by spaces and converts each split into the desired type [T].
  /// Will throw a [ShellException] if the shell process did not
  /// exit with 0 as the exit code. Will throw a [ShellResultConversionException] if cannot convert to the desired
  /// type [T].
  FutureOr<List<T>> spaces<T extends Object>();

  /// Splits the output by newlines and converts each split into the desired type [T].
  /// Will throw a [ShellException] if the shell process did not
  /// exit with 0 as the exit code. Will throw a [ShellResultConversionException] if cannot convert to the desired
  /// type [T].
  FutureOr<List<T>> lines<T extends Object>();

  /// Splits the output by whitespaces and converts each split into the desired type [T].
  /// Will throw a [ShellException] if the shell process did not
  /// exit with 0 as the exit code. Will throw a [ShellResultConversionException] if cannot convert to the desired
  /// type [T].
  FutureOr<List<T>> whitespaces<T extends Object>();

  FutureOr<void> operator >(io.File file);

  FutureOr<void> operator >>(io.File file);
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
