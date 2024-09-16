import 'dart:convert';

import 'exceptions.dart';

class IntConverter extends Converter<String, int> {
  const IntConverter();

  @override
  int convert(String input) {
    int? result = int.tryParse(input);
    if (result == null) {
      throw ShellConversionException(int, input);
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
      throw ShellConversionException(double, input);
    }
    return result;
  }
}

class NumConverter extends Converter<String, num> {
  const NumConverter();

  @override
  num convert(String input) {
    return int.tryParse(input) ??
        double.tryParse(input) ??
        (throw ShellConversionException(num, input));
  }
}

class BigIntConverter extends Converter<String, BigInt> {
  const BigIntConverter();

  @override
  BigInt convert(String input) {
    try {
      return BigInt.parse(input);
    } catch (e) {
      throw ShellConversionException(BigInt, input);
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
    return input.isNotEmpty;
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
        final result = json.decode(input.replaceAll("\\", ""));
        throw ShellConversionException(Map<String, dynamic>, input,
            addtionalMessage:
                "Looks like this may be an escaping character issue. As removing all backslashes from the input string and trying again worked with the following result:\n $result");
      } catch (e2) {
        throw ShellConversionException(Map<String, dynamic>, input,
            addtionalMessage:
                "Converting to json failed with the following error:\n$e1");
      }
    }
  }
}
