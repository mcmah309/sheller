import 'dart:convert';
import 'dart:io';

import 'exceptions.dart';
import 'shell.dart';

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
    throw ShellResultConversionException(FileSystemEntity, input);
  }
}

class ListFileSystemEntityConverter extends Converter<String, List<FileSystemEntity>> {
  const ListFileSystemEntityConverter();

  @override
  List<FileSystemEntity> convert(String input) {
    return input
        .split(ShellConversionConfig.splitter)
        .map((e) => const FileSystemEntityConverter().convert(e))
        .toList();
  }
}

class SetFileSystemEntityConverter extends Converter<String, Set<FileSystemEntity>> {
  const SetFileSystemEntityConverter();

  @override
  Set<FileSystemEntity> convert(String input) {
    return input.split(ShellConversionConfig.splitter).map((e) => const FileSystemEntityConverter().convert(e)).toSet();
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
    throw ShellResultConversionException(File, input);
  }
}

class ListFileConverter extends Converter<String, List<File>> {
  const ListFileConverter();

  @override
  List<File> convert(String input) {
    return input.split(ShellConversionConfig.splitter).map((e) => const FileConverter().convert(e)).toList();
  }
}

class SetFileConverter extends Converter<String, Set<File>> {
  const SetFileConverter();

  @override
  Set<File> convert(String input) {
    return input.split(ShellConversionConfig.splitter).map((e) => const FileConverter().convert(e)).toSet();
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
    throw ShellResultConversionException(Directory, input);
  }
}

class ListDirectoryConverter extends Converter<String, List<Directory>> {
  const ListDirectoryConverter();

  @override
  List<Directory> convert(String input) {
    return input.split(ShellConversionConfig.splitter).map((e) => const DirectoryConverter().convert(e)).toList();
  }
}

class SetDirectoryConverter extends Converter<String, Set<Directory>> {
  const SetDirectoryConverter();

  @override
  Set<Directory> convert(String input) {
    return input.split(ShellConversionConfig.splitter).map((e) => const DirectoryConverter().convert(e)).toSet();
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
    throw ShellResultConversionException(Link, input);
  }
}

class ListLinkConverter extends Converter<String, List<Link>> {
  const ListLinkConverter();

  @override
  List<Link> convert(String input) {
    return input.split(ShellConversionConfig.splitter).map((e) => const LinkConverter().convert(e)).toList();
  }
}

class SetLinkConverter extends Converter<String, Set<Link>> {
  const SetLinkConverter();

  @override
  Set<Link> convert(String input) {
    return input.split(ShellConversionConfig.splitter).map((e) => const LinkConverter().convert(e)).toSet();
  }
}
