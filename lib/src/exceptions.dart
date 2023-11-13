/// An [Exception] that happened inside the shell
class ShellException implements Exception {
  final int exitCode;
  final int pid;
  final String stdout;
  final String stderr;

  ShellException(this.exitCode, this.pid, this.stdout, this.stderr);

  @override
  String toString() {
    return """
    ShellException: The shell process with PID $pid failed with
    
    Exit Code: $exitCode
    
    stdout: $stdout
    
    stderr: $stderr
    """;
  }
}

/// An [Exception] that happen when converting the shell result to the desired result type
class ShellResultConversionException implements Exception {
  final String from;
  final Type to;

  ShellResultConversionException(this.to, this.from);

  @override
  String toString() {
    return """
    ShellResultConversionException: could not convert to '$to' from '$from'
    """;
  }
}
