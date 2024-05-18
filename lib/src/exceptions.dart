import 'dart:io';
import 'dart:typed_data';

import 'package:sheller/src/shell_base.dart';

/// An [Exception] that happened inside the shell
class ShellException implements Exception {
  final String executable;
  final List<String> args;
  final String workingDirectory;
  final int exitCode;
  final int pid;
  final Uint8List stdout;
  final Uint8List stderr;

  ShellException(this.executable, this.args, this.workingDirectory, this.exitCode, this.pid,
      this.stdout, this.stderr);

  @override
  String toString() {
    String std;
    if (ShellConfig.includeRawBytesOnException) {
      try {
        std = """
  stdout system encoding: ${const SystemEncoding().decode(stdout)}

  stderr system encoding: ${const SystemEncoding().decode(stderr)}

  stdout bytes: $stdout

  stderr bytes: $stderr
            """;
      } catch (e) {
        std = """
  Could not decode stdout and stderr bytes to system encoding.

  stdout bytes: $stdout

  stderr bytes: $stderr
      """;
      }
    } else {
      try {
        std = """
  stdout system encoding: ${const SystemEncoding().decode(stdout)}

  stderr system encoding: ${const SystemEncoding().decode(stderr)}
            """;
      } catch (e) {
        std = "Could not decode stdout and stderr bytes to system encoding.";
      }
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

/// An [Exception] that happens when a converter is missing.
class ShellerMissingConverterException implements Exception {
  final Type type;

  ShellerMissingConverterException(this.type);

  @override
  String toString() {
    return "ShellerMissingConverterException: A converter has not been added for type `$type`.";
  }
}
