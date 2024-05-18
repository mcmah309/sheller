import 'dart:io' as io;

import 'shell_base.dart';

PlatformConfig createPlatformExecutableAndArgs(String cmd){
    final String executable;
    final List<String> args;
    final bool runInShell;
    if(io.Platform.isWindows){
      // final result = io.Process.runSync("echo %WINDIR%", [], runInShell: true);
      // final out = result.stdout.toString().trim();
      // print("out: '$out'");
      executable = "C:\\Windows\\system32\\cmd.exe /c $cmd";
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