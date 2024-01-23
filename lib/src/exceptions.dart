import 'dart:io';
import 'dart:typed_data';

/// An [Exception] that happened inside the shell
class ShellException implements Exception {
  final String executable;
  final List<String> args;
  final String workingDirectory;
  final int exitCode;
  final int pid;
  final Uint8List stdout;
  final Uint8List stderr;

  ShellException(this.executable, this.args, this.workingDirectory,
      this.exitCode, this.pid, this.stdout, this.stderr);

  @override
  String toString() {
    String std;
    try {
      std = """
  stdout system encoding: ${const SystemEncoding().decode(stdout)}

  stderr system encoding: ${const SystemEncoding().decode(stderr)}

  stdout bytes: $stdout

  stderr bytes: $stderr
            """;
    } catch (e) {
      std = """
  stdout bytes: $stdout

  stderr bytes: $stderr
      """;
    }

    return """
ShellException: The shell process failed.

  PID: $pid

  Executable: $executable

  Arguments: $args

  Working directory at start: $workingDirectory

  Exit code: $exitCode

$std
    """;
  }
}

/// An [Exception] that happen when converting the shell result to the desired result type
class ShellResultConversionException implements Exception {
  final String from;
  final Type to;
  final String? addtionalMessage;

  ShellResultConversionException(this.to, this.from, {this.addtionalMessage});

  @override
  String toString() {
    String value = """
    ShellResultConversionException: could not convert to '$to' from '$from'
    """;
    if (addtionalMessage != null) {
      value += """

      $addtionalMessage
      """;
    }
    return value;
  }
}
