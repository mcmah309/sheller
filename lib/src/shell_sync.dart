import 'dart:io' as io;
import 'dart:typed_data';

import 'exceptions.dart';
import 'shell_base.dart' as base;
import 'utils.dart';

//************************************************************************//

/// A host platform process that run non-interactively to completion.
class $ implements base.$ {
  @override
  int get exitCode => _rawResult.exitCode;

  @override
  int get pid => _rawResult.pid;

  @override
  Uint8List get stderr => _rawResult.stderr as Uint8List;

  @override
  String get stderrAsString {
    if (_stderrString != null) {
      return _stderrString!;
    }
    _stderrString = const io.SystemEncoding().decode(_rawResult.stderr);
    return _stderrString!;
  }

  @override
  Uint8List get stdout => _rawResult.stdout as Uint8List;

  @override
  String get stdoutAsString {
    if (_stdoutString != null) {
      return _stdoutString!;
    }
    _stdoutString = const io.SystemEncoding().decode(_rawResult.stdout);
    return _stdoutString!;
  }

  late final io.ProcessResult _rawResult;
  String? _stringResult;
  String? _stderrString;
  String? _stdoutString;
  late final String Function(io.ProcessResult) _processResult;

  $(String cmd, [base.ShellConfig shellConfig = const base.ShellConfig()]) {
    final workingDirectory =
        shellConfig.workingDirectory ?? io.Directory.current.path;
    final platformConfig = createPlatformExecutableAndArgs(cmd);
    _rawResult = io.Process.runSync(
      platformConfig.executable,
      platformConfig.args,
      workingDirectory: workingDirectory,
      environment: shellConfig.environment,
      includeParentEnvironment: shellConfig.includeParentEnvironment,
      runInShell: platformConfig.runInshell,
      stdoutEncoding: null,
      stderrEncoding: null,
    );
    _processResult = (io.ProcessResult e) {
      if (e.exitCode != 0) {
        throw ShellException(platformConfig.executable, platformConfig.args,
            workingDirectory, e.exitCode, e.pid, e.stdout, e.stderr);
      }
      return stdoutAsString;
    };
  }

  @override
  T call<T extends Object>() {
    final converter = base.ShellConfig.getConverter<T>();
    return converter.convert(text());
  }

  @override
  String text() {
    _stringResult ??= _processResult(_rawResult);
    return _stringResult!.replaceAll(base.$.trailingNewLineExp, "");
  }

  @override
  List<T> spaces<T extends Object>() => _callWithRegExp<T>(base.$.spacesExp);

  @override
  List<T> lines<T extends Object>() => _callWithRegExp<T>(base.$.newLinesExp);

  @override
  List<T> whitespaces<T extends Object>() =>
      _callWithRegExp<T>(base.$.whitespacesExp);

  List<T> _callWithRegExp<T extends Object>(RegExp splitter) {
    final splits =
        text().replaceAll(base.$.trailingNewLineExp, "").split(splitter);
    final converter = base.ShellConfig.getConverter<T>();
    return splits.map((e) => converter.convert(e)).toList();
  }

  @override
  void operator >(io.File file) {
    file.writeAsBytesSync(stdout, mode: io.FileMode.writeOnly, flush: true);
  }

  @override
  void operator >>(io.File file) {
    file.writeAsBytesSync(stdout,
        mode: io.FileMode.writeOnlyAppend, flush: true);
  }
}
