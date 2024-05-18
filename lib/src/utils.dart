import 'dart:io' as io;

(String, List<String>) createPlatformExecutableAndArgs(String cmd){
    final String executable;
    final List<String> args;
    if(io.Platform.isWindows){
      executable = "C:\\WINDOWS\\system32\\cmd.exe";
      args = ["/c", '"$cmd"'];
    }
    else if(io.Platform.isLinux || io.Platform.isMacOS){
      executable = "/bin/sh";
      args = ["-c", "''$cmd''"];
    }
    else {
      throw "Platform not supported.";
    }
    return (executable, args);
}