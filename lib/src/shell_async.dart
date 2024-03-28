import 'dart:io' as io;
import 'dart:typed_data';

import 'exceptions.dart';
import 'shell_base.dart' as base;

//************************************************************************//

/// Wrapper around [Process.run] that makes running a shell and converting the result back into a dart type more
/// convenient
class $ implements base.$ {
  @override
  Future<int> get exitCode {
    return _rawResult.then((value) => value.exitCode);
  }

  @override
  Future<int> get pid => _rawResult.then((value) => value.pid);

  @override
  Future<Uint8List> get stderr =>
      _rawResult.then((value) => value.stderr as Uint8List);

  @override
  Future<String> get stderrAsString async {
    if (_stderrString != null) {
      return _stderrString!;
    }
    final rawResult = await _rawResult;
    _stderrString = const io.SystemEncoding().decode(rawResult.stderr);
    return _stderrString!;
  }

  @override
  Future<Uint8List> get stdout =>
      _rawResult.then((value) => value.stdout as Uint8List);

  @override
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

  $(String cmd, [base.ShellConfig shellConfig = const base.ShellConfig()]) {
    final workingDirectory =
        shellConfig.workingDirectory ?? io.Directory.current.path;
    final executable = io.Platform.isLinux ? "/bin/sh" : cmd;
    final args = io.Platform.isLinux ? ["-c", "''$cmd''"] : <String>[];
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
        throw ShellException(executable, args, workingDirectory, e.exitCode,
            e.pid, e.stdout, e.stderr);
      }
      return stdoutAsString;
    };
  }

  @override
  Future<T> call<T extends Object>() async {
    final converter = base.ShellConversionConfig.get<T>();
    return converter.convert(await text());
  }

  @override
  Future<String> text() async {
    _stringResult ??= await _rawResult.then(_processResult);
    return _stringResult!.replaceAll(base.$.trailingNewLineExp, "");
  }

  @override
  Future<List<T>> spaces<T extends Object>() =>
      _callWithRegExp<T>(base.$.spacesExp);

  @override
  Future<List<T>> lines<T extends Object>() =>
      _callWithRegExp<T>(base.$.newLinesExp);

  @override
  Future<List<T>> whitespaces<T extends Object>() =>
      _callWithRegExp<T>(base.$.whitespacesExp);

  Future<List<T>> _callWithRegExp<T extends Object>(RegExp splitter) async {
    final splits = await text().then(
        (e) => e.replaceAll(base.$.trailingNewLineExp, "").split(splitter));
    final converter = base.ShellConversionConfig.get<T>();
    return splits.map((e) => converter.convert(e)).toList();
  }

  @override
  Future<void> operator >(io.File file) async {
    await file.writeAsBytes(await stdout,
        mode: io.FileMode.writeOnly, flush: true);
  }

  @override
  Future<void> operator >>(io.File file) async {
    await file.writeAsBytes(await stdout,
        mode: io.FileMode.writeOnlyAppend, flush: true);
  }
}
