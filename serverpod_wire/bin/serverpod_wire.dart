#!/usr/bin/env dart

import 'dart:io';
import 'package:serverpod_wire/src/commands/scaffold_command.dart';

void main(List<String> arguments) async {
  if (arguments.isEmpty || arguments.contains('--help') || arguments.contains('-h')) {
    print(_usage);
    exit(0);
  }

  try {
    if (arguments.length >= 3 && 
        arguments[0] == 'generate' && 
        arguments[1] == 'scaffold') {
      final modelName = arguments[2];
      final fields = arguments.skip(3).toList();
      
      if (fields.isEmpty) {
        print('Error: At least one field is required');
        print('Usage: serverpod_wire generate scaffold <ModelName> <field1:type> [field2:type] ...');
        exit(1);
      }
      
      await ScaffoldCommand().execute(modelName: modelName, fields: fields);
    } else {
      print(_usage);
      exit(1);
    }
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}

const String _usage = '''
Serverpod Wire - CRUD Boilerplate Generator

Usage:
  serverpod_wire generate scaffold <ModelName> <field1:type> [field2:type] ...

Example:
  serverpod_wire generate scaffold Product name:String price:double inStock:bool

Options:
  -h, --help    Show this help message

For more information, visit: https://github.com/your-org/serverpod_wire
''';

