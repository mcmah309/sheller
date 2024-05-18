import 'dart:io' as io;

// Dev Note: Escape characters are added to commands by [io.Process]. We don't want that. And there are some existing bugs related to how they are added.
// Related issues:
// https://github.com/dart-lang/sdk/issues/42571
// https://github.com/dart-lang/sdk/issues/50076
PlatformConfig createPlatformExecutableAndArgs(String cmd){
    final String executable;
    final List<String> args;
    final bool runInShell;
    if(io.Platform.isWindows){
      executable = "C:\\Windows\\system32\\cmd.exe /c \"$cmd\"";
      args = const [];
      runInShell = false;
    }
    else if(io.Platform.isLinux || io.Platform.isMacOS){
      executable = "/bin/sh";
      args = ["-c", "''$cmd''"];
      runInShell = false;
    }
    else {
      throw "Platform not supported.";
    }
    return PlatformConfig(executable, args, runInShell);
}

class PlatformConfig {
  final String executable;
  final List<String> args;
  final bool runInshell;

  PlatformConfig(this.executable, this.args, this.runInshell);
}