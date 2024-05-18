import 'dart:convert';
import 'dart:io';

import 'exceptions.dart';

class FileSystemEntityConverter extends Converter<String, FileSystemEntity> {
  const FileSystemEntityConverter();

  @override
  FileSystemEntity convert(String input) {
    if (FileSystemEntity.isDirectorySync(input)) {
      return Directory(input);
    } else if (FileSystemEntity.isFileSync(input)) {
      return File(input);
    } else if (FileSystemEntity.isLinkSync(input)) {
      return Link(input);
    }
    throw ShellResultConversionException(FileSystemEntity, input,
        addtionalMessage: "The input was not an existing FileSystemEntity.");
  }
}

//************************************************************************//

class FileConverter extends Converter<String, File> {
  const FileConverter();

  @override
  File convert(String input) {
    final file = File(input);
    if (file.existsSync()) {
      return file;
    }
    throw ShellResultConversionException(File, input,
        addtionalMessage: "The input was not an existing File.");
  }
}

//************************************************************************//

class DirectoryConverter extends Converter<String, Directory> {
  const DirectoryConverter();

  @override
  Directory convert(String input) {
    final directory = Directory(input);
    if (directory.existsSync()) {
      return directory;
    }
    throw ShellResultConversionException(Directory, input,
        addtionalMessage: "The input was not an existing Directory.");
  }
}

//************************************************************************//

class LinkConverter extends Converter<String, Link> {
  const LinkConverter();

  @override
  Link convert(String input) {
    final link = Link(input);
    if (link.existsSync()) {
      return link;
    }
    throw ShellResultConversionException(Link, input,
        addtionalMessage: "The input was not an existing Link.");
  }
}
