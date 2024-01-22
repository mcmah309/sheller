import 'dart:convert';

import 'exceptions.dart';

class IntConverter extends Converter<String, int> {
  const IntConverter();

  @override
  int convert(String input) {
    int? result = int.tryParse(input.trim());
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
    double? result = double.tryParse(input.trim());
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
    final trimmed = input.trim();
    return int.tryParse(trimmed) ?? double.tryParse(trimmed) ?? (throw ShellResultConversionException(num, input));
  }
}

class BigIntConverter extends Converter<String, BigInt> {
  const BigIntConverter();

  @override
  BigInt convert(String input) {
    try {
      return BigInt.parse(input.trim());
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
    return input.trim().isNotEmpty;
  }
}

//************************************************************************//

class JsonConverter extends Converter<String, Map<String, dynamic>> {
  const JsonConverter();

  @override
  Map<String, dynamic> convert(String input) {
    final trimmed = input.trim();
    try {
      return json.decode(trimmed);
    } catch (e1) {
      try {
        return json.decode(trimmed.replaceAll("\\", ""));
      } catch (e2) {
        throw ShellResultConversionException(Map<String, dynamic>, input);
      }
    }
  }
}