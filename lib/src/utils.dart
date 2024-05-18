import 'dart:io' as io;

import 'shell_base.dart';

PlatformConfig createPlatformExecutableAndArgs(String cmd){
    final String executable;
    final List<String> args;
    final bool runInShell;
    if(io.Platform.isWindows){
      executable = "C:\\WINDOWS\\system32\\cmd.exe $cmd";
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