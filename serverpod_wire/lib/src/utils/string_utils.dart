/// Utility functions for string transformations
class StringUtils {
  /// Convert PascalCase to camelCase
  /// Example: "ModelName" -> "modelName"
  static String toCamelCase(String input) {
    if (input.isEmpty) return input;
    return input[0].toLowerCase() + input.substring(1);
  }

  /// Convert PascalCase to snake_case
  /// Example: "ModelName" -> "model_name"
  static String toSnakeCase(String input) {
    if (input.isEmpty) return input;
    
    final buffer = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      final char = input[i];
      if (char == char.toUpperCase() && i > 0) {
        buffer.write('_');
      }
      buffer.write(char.toLowerCase());
    }
    return buffer.toString();
  }

  /// Validate model name (must be PascalCase and start with uppercase)
  static bool isValidModelName(String name) {
    if (name.isEmpty) return false;
    if (!RegExp(r'^[A-Z]').hasMatch(name)) return false;
    if (!RegExp(r'^[A-Za-z0-9_]+$').hasMatch(name)) return false;
    return true;
  }

  /// Parse field definition string "name:type" into a Map
  static Map<String, String> parseField(String fieldDef) {
    final parts = fieldDef.split(':');
    if (parts.length != 2) {
      throw FormatException('Invalid field format: $fieldDef. Expected "name:type"');
    }
    
    final name = parts[0].trim();
    final type = parts[1].trim();
    
    if (name.isEmpty || type.isEmpty) {
      throw FormatException('Field name and type cannot be empty: $fieldDef');
    }
    
    return {'name': name, 'type': type};
  }

  /// Convert Dart type to Serverpod YAML type
  static String toServerpodType(String dartType) {
    final typeMap = {
      'String': 'string',
      'int': 'int',
      'double': 'double',
      'bool': 'bool',
      'DateTime': 'DateTime',
    };
    return typeMap[dartType] ?? dartType.toLowerCase();
  }

  /// Check if a type is nullable in Dart
  static bool isNullableType(String type) {
    return type.endsWith('?');
  }

  /// Remove nullable marker from type
  static String removeNullable(String type) {
    return type.replaceAll('?', '');
  }
}

