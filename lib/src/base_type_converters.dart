import 'dart:convert';

import 'exceptions.dart';
import 'shell.dart';

class IntConverter extends Converter<String, int> {
  const IntConverter();

  @override
  int convert(String input) {
    int? result = int.tryParse(input);
    if (result == null) {
      throw ShellResultConversionException(int, input);
    }
    return result;
  }
}

class DoubleConverter extends Converter<String, double> {
  const DoubleConverter();

  @override
  double convert(String input) {
    double? result = double.tryParse(input);
    if (result == null) {
      throw ShellResultConversionException(double, input);
    }
    return result;
  }
}

class NumConverter extends Converter<String, num> {
  const NumConverter();

  @override
  num convert(String input) {
    return int.tryParse(input) ?? double.tryParse(input) ?? (throw ShellResultConversionException(num, input));
  }
}

class BigIntConverter extends Converter<String, BigInt> {
  const BigIntConverter();

  @override
  BigInt convert(String input) {
    try {
      return BigInt.parse(input);
    } catch (e) {
      throw ShellResultConversionException(BigInt, input);
    }
  }
}

class StringConverter extends Converter<String, String> {
  const StringConverter();

  @override
  String convert(String input) {
    return input;
  }
}

class BoolConverter extends Converter<String, bool> {
  const BoolConverter();

  @override
  bool convert(String input) {
    if (input.toLowerCase() == 'true') {
      return true;
    } else if (input.toLowerCase() == 'false') {
      return false;
    }
    throw ShellResultConversionException(bool, input);
  }
}

//************************************************************************//

class ListStringConverter extends Converter<String, List<String>> {
  const ListStringConverter();

  @override
  List<String> convert(String input) {
    return input.split(ShellConversionConfig.splitter);
  }
}

class ListIntConverter extends Converter<String, List<int>> {
  const ListIntConverter();

  @override
  List<int> convert(String input) {
    return input.split(ShellConversionConfig.splitter).map((e) => const IntConverter().convert(e)).toList();
  }
}

class ListDoubleConverter extends Converter<String, List<double>> {
  const ListDoubleConverter();

  @override
  List<double> convert(String input) {
    return input.split(ShellConversionConfig.splitter).map((e) => const DoubleConverter().convert(e)).toList();
  }
}

class ListNumConverter extends Converter<String, List<num>> {
  const ListNumConverter();

  @override
  List<num> convert(String input) {
    return input.split(ShellConversionConfig.splitter).map((e) => const NumConverter().convert(e)).toList();
  }
}

class ListBigIntConverter extends Converter<String, List<BigInt>> {
  const ListBigIntConverter();

  @override
  List<BigInt> convert(String input) {
    return input.split(ShellConversionConfig.splitter).map((e) => const BigIntConverter().convert(e)).toList();
  }
}

class ListBoolConverter extends Converter<String, List<bool>> {
  const ListBoolConverter();

  @override
  List<bool> convert(String input) {
    return input.split(ShellConversionConfig.splitter).map((e) => const BoolConverter().convert(e)).toList();
  }
}

//************************************************************************//

class JsonConverter extends Converter<String, Map<String, dynamic>> {
  const JsonConverter();

  @override
  Map<String, dynamic> convert(String input) {
    try {
      return json.decode(input);
    } catch (e1) {
      try {
        return json.decode(input.replaceAll("\\", ""));
      } catch (e2) {
        throw ShellResultConversionException(Map<String, dynamic>, input);
      }
    }
  }
}

//************************************************************************//

class SetStringConverter extends Converter<String, Set<String>> {
  const SetStringConverter();

  @override
  Set<String> convert(String input) {
    return input.split(ShellConversionConfig.splitter).toSet();
  }
}

class SetIntConverter extends Converter<String, Set<int>> {
  const SetIntConverter();

  @override
  Set<int> convert(String input) {
    return input.split(ShellConversionConfig.splitter).map((e) => const IntConverter().convert(e)).toSet();
  }
}

class SetDoubleConverter extends Converter<String, Set<double>> {
  const SetDoubleConverter();

  @override
  Set<double> convert(String input) {
    return input.split(ShellConversionConfig.splitter).map((e) => const DoubleConverter().convert(e)).toSet();
  }
}

class SetNumConverter extends Converter<String, Set<num>> {
  const SetNumConverter();

  @override
  Set<num> convert(String input) {
    return input.split(ShellConversionConfig.splitter).map((e) => const NumConverter().convert(e)).toSet();
  }
}

class SetBigIntConverter extends Converter<String, Set<BigInt>> {
  const SetBigIntConverter();

  @override
  Set<BigInt> convert(String input) {
    return input.split(ShellConversionConfig.splitter).map((e) => const BigIntConverter().convert(e)).toSet();
  }
}

class SetBoolConverter extends Converter<String, Set<bool>> {
  const SetBoolConverter();

  @override
  Set<bool> convert(String input) {
    return input.split(ShellConversionConfig.splitter).map((e) => const BoolConverter().convert(e)).toSet();
  }
}
