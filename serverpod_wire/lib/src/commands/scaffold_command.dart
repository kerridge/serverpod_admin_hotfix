import 'dart:io';
import 'package:path/path.dart' as path;
import '../utils/string_utils.dart';
import '../utils/path_resolver.dart';
import '../templating/template_loader.dart';
import '../templating/template_renderer.dart';

/// Command to generate CRUD scaffold from templates
class ScaffoldCommand {
  final TemplateLoader _loader = TemplateLoader();
  final TemplateRenderer _renderer = TemplateRenderer();

  Future<void> execute({required String modelName, required List<String> fields}) async {
    print('🚀 Generating scaffold for $modelName...\n');

    // Validate model name
    if (!StringUtils.isValidModelName(modelName)) {
      throw ArgumentError(
        'Invalid model name: $modelName. Model name must be PascalCase and start with uppercase letter.',
      );
    }

    // Parse fields
    final parsedFields = <Map<String, String>>[];
    for (final field in fields) {
      try {
        parsedFields.add(StringUtils.parseField(field));
      } catch (e) {
        throw ArgumentError('Error parsing field "$field": $e');
      }
    }

    // Generate string representations
    final modelNameCamel = StringUtils.toCamelCase(modelName);
    final modelSnake = StringUtils.toSnakeCase(modelName);

    final fieldDeclarations = _generateFieldDeclarations(parsedFields);
    final fieldInputs = _generateFieldInputs(parsedFields);
    final fieldAssignments = _generateFieldAssignments(parsedFields, modelNameCamel);
    final constructorFields = _generateConstructorFields(parsedFields);
    final fieldWidgets = _generateFieldWidgets(parsedFields);
    final fieldsString = _generateFieldsString(parsedFields);
    final yamlColumns = _generateYamlColumns(parsedFields);

    // Build context with Flutter-specific field assignments
    final flutterFieldAssignments = _generateFlutterFieldAssignments(parsedFields, modelNameCamel);
    final flutterFieldInputs = _generateFlutterFieldInputs(parsedFields);
    final testFieldValues = _generateTestFieldValues(parsedFields);
    
    // Build context
    final context = TemplateRenderer.buildContext(
      modelName: modelName,
      modelNameCamel: modelNameCamel,
      modelSnake: modelSnake,
      fieldDeclarations: fieldDeclarations,
      fieldInputs: fieldInputs,
      fieldAssignments: fieldAssignments,
      constructorFields: constructorFields,
      fieldWidgets: fieldWidgets,
      fields: fieldsString,
      yamlColumns: yamlColumns,
      flutterFieldAssignments: flutterFieldAssignments,
      flutterFieldInputs: flutterFieldInputs,
      testFieldValues: testFieldValues,
    );

    // Detect context and resolve paths
    final currentDir = Directory.current.path;
    final isInServer = PathResolver.isInServerDirectory();
    final isInFlutter = PathResolver.isInFlutterDirectory();
    final dirName = path.basename(currentDir);
    
    if (isInServer) {
      print('📍 Detected: Running from server directory ($dirName)\n');
    } else if (isInFlutter) {
      print('📍 Detected: Running from Flutter directory ($dirName)\n');
    } else {
      print('📍 Detected: Running from project root ($dirName)\n');
    }

    final serverPath = PathResolver.getServerPath();
    final flutterPath = PathResolver.getFlutterPath();

    if (serverPath == null) {
      throw Exception(
        'Could not find server package.\n'
        'Current directory: $currentDir\n'
        'Please run this command from:\n'
        '  - A server package directory (ending with "_server" or "server"),\n'
        '  - A Flutter package directory (ending with "_flutter"), or\n'
        '  - The Serverpod project root directory.',
      );
    }

    print('📂 Server package: ${path.relative(serverPath)}\n');

    // Step 1: Generate YAML schema first
    print('📋 Generating YAML schema...');
    await _generateYamlSchema(serverPath, modelSnake, modelName, context);
    print('   ✓ YAML schema generated\n');

    // Step 2: Run serverpod generate
    print('🔄 Running serverpod generate...');
    await _runServerpodGenerate(serverPath);
    print('   ✓ serverpod generate completed\n');

    // Step 3: Run serverpod create-migration
    print('🔄 Running serverpod create-migration...');
    await _runServerpodCreateMigrations(serverPath);
    print('   ✓ serverpod create-migration completed\n');

    // Step 4: Generate server endpoint (after model is generated)
    print('📁 Generating server endpoint...');
    try {
      await _generateServerFiles(serverPath, modelSnake, context);
      print('   ✓ Server endpoint generated\n');
    } catch (e) {
      print('   ❌ Error generating endpoint: $e\n');
      rethrow;
    }

    // Step 5: Generate Flutter files
    if (flutterPath != null) {
      print('📂 Flutter package: ${path.relative(flutterPath)}\n');
      print('📱 Generating Flutter files...');
      try {
        await _generateFlutterFiles(flutterPath, modelSnake, context);
        print('   ✓ Flutter files generated\n');
      } catch (e) {
        print('   ❌ Error generating Flutter files: $e\n');
        // Don't rethrow - endpoint is more critical
      }
    } else {
      print('⚠️  Flutter package not found. Skipping Flutter file generation.\n');
    }

    // Print completion message
    print('✅ Everything is complete! Your new models are ready to use.\n');
  }

  Future<void> _generateServerFiles(
    String serverPath,
    String modelSnake,
    Map<String, String> context,
  ) async {
    try {
      // Generate endpoint only
      final endpointTemplate = _loader.loadTemplate('server/endpoint.dart.tpl');
      final endpointContent = _renderer.render(endpointTemplate, context);
      final endpointPath = PathResolver.getServerEndpointPath(serverPath, modelSnake);
      PathResolver.ensureDirectory(endpointPath);
      await File(endpointPath).writeAsString(endpointContent);
      print('   Created: ${path.relative(endpointPath)}');
    } catch (e) {
      print('   ERROR in _generateServerFiles: $e');
      rethrow;
    }
  }

  Future<void> _generateFlutterFiles(
    String flutterPath,
    String modelSnake,
    Map<String, String> context,
  ) async {
    try {
      // Generate list page
      final listTemplate = _loader.loadTemplate('flutter/list_page.dart.tpl');
      final listContent = _renderer.render(listTemplate, context);
      final listPath = PathResolver.getFlutterListPath(flutterPath, modelSnake);
      PathResolver.ensureDirectory(listPath);
      await File(listPath).writeAsString(listContent);
      print('   Created: ${path.relative(listPath)}');

      // Generate form page
      final formTemplate = _loader.loadTemplate('flutter/form_page.dart.tpl');
      final formContent = _renderer.render(formTemplate, context);
      final formPath = PathResolver.getFlutterFormPath(flutterPath, modelSnake);
      PathResolver.ensureDirectory(formPath);
      await File(formPath).writeAsString(formContent);
      print('   Created: ${path.relative(formPath)}');

      // Generate card widget
      final cardTemplate = _loader.loadTemplate('flutter/card_widget.dart.tpl');
      final cardContent = _renderer.render(cardTemplate, context);
      final cardPath = PathResolver.getFlutterCardPath(flutterPath, modelSnake);
      PathResolver.ensureDirectory(cardPath);
      await File(cardPath).writeAsString(cardContent);
      print('   Created: ${path.relative(cardPath)}');
    } catch (e) {
      print('   ERROR in _generateFlutterFiles: $e');
      rethrow;
    }
  }

  Future<void> _generateYamlSchema(
    String serverPath,
    String modelSnake,
    String modelName,
    Map<String, String> context,
  ) async {
    final yamlTemplate = _loader.loadTemplate('yaml/model.yaml.tpl');
    final yamlContent = _renderer.render(yamlTemplate, context);
    final yamlPath = PathResolver.getYamlModelPath(serverPath, modelSnake);
    PathResolver.ensureDirectory(yamlPath);
    await File(yamlPath).writeAsString(yamlContent);
    print('   Created: ${path.relative(yamlPath)}');
  }

  Future<void> _runServerpodGenerate(String serverPath) async {
    final process = await Process.start(
      'serverpod',
      ['generate'],
      workingDirectory: serverPath,
      mode: ProcessStartMode.normal,
    );

    // Stream output
    process.stdout.transform(const SystemEncoding().decoder).listen((data) {
      print('   $data');
    });
    
    process.stderr.transform(const SystemEncoding().decoder).listen((data) {
      print('   $data');
    });

    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      // Don't fail the whole process if generate fails - user might have syntax errors to fix
      print('   ⚠️  serverpod generate completed with warnings/errors');
      print('   ⚠️  Please fix any syntax errors in your endpoint files and run "serverpod generate" manually');
    }
  }

  Future<void> _runServerpodCreateMigrations(String serverPath) async {
    final process = await Process.start(
      'serverpod',
      ['create-migration'],
      workingDirectory: serverPath,
      mode: ProcessStartMode.normal,
    );

    // Stream output
    process.stdout.transform(const SystemEncoding().decoder).listen((data) {
      print('   $data');
    });
    
    process.stderr.transform(const SystemEncoding().decoder).listen((data) {
      print('   $data');
    });

    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      print('   ⚠️  serverpod create-migration completed with warnings/errors');
      print('   ⚠️  This is usually fine if no migrations are needed');
    }
  }

  String _generateFieldDeclarations(List<Map<String, String>> fields) {
    return fields.map((f) {
      final name = f['name']!;
      final type = f['type']!;
      final nullable = StringUtils.isNullableType(type);
      final cleanType = nullable ? StringUtils.removeNullable(type) : type;
      final defaultValue = _getDefaultValue(cleanType, nullable);
      return '  ${nullable ? '$cleanType?' : cleanType} _$name = $defaultValue;';
    }).join('\n');
  }

  String _generateFieldInputs(List<Map<String, String>> fields) {
    return fields.map((f) {
      final name = f['name']!;
      final type = f['type']!;
      return 'required $type $name,';
    }).join('\n    ');
  }

  String _generateFieldAssignments(List<Map<String, String>> fields, String modelNameCamel) {
    return fields.map((f) {
      final name = f['name']!;
      return '$modelNameCamel.$name = $name;';
    }).join('\n    ');
  }

  String _generateConstructorFields(List<Map<String, String>> fields) {
    return fields.map((f) {
      final name = f['name']!;
      return '$name: $name,';
    }).join('\n      ');
  }

  String _generateFlutterFieldAssignments(List<Map<String, String>> fields, String modelNameCamel) {
    return fields.map((f) {
      final name = f['name']!;
      return '_$name = $modelNameCamel.$name;';
    }).join('\n      ');
  }

  String _generateFlutterFieldInputs(List<Map<String, String>> fields) {
    return fields.map((f) {
      final name = f['name']!;
      return '_$name,';
    }).join('\n        ');
  }

  String _generateFieldWidgets(List<Map<String, String>> fields) {
    return fields.map((f) {
      final name = f['name']!;
      final type = f['type']!;
      final label = _capitalizeFirst(name);
      
      if (type == 'bool') {
        return '''
        CheckboxListTile(
          title: Text('$label'),
          value: _${name},
          onChanged: (value) => setState(() => _${name} = value ?? false),
        ),''';
      } else if (type == 'int' || type == 'double') {
        return '''
        TextField(
          decoration: InputDecoration(labelText: '$label'),
          keyboardType: TextInputType.number,
          onChanged: (value) => _${name} = $type.tryParse(value) ?? _${name},
        ),''';
      } else if (type == 'DateTime') {
        return '''
        ListTile(
          title: Text('$label'),
          subtitle: Text(_${name}?.toString() ?? 'Not set'),
          trailing: Icon(Icons.calendar_today),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _${name} ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              setState(() => _${name} = date);
            }
          },
        ),''';
      } else {
        return '''
        TextField(
          decoration: InputDecoration(labelText: '$label'),
          onChanged: (value) => _${name} = value,
        ),''';
      }
    }).join('\n');
  }

  String _generateFieldsString(List<Map<String, String>> fields) {
    return fields.map((f) => '${f['name']}: ${f['type']}').join(', ');
  }

  String _generateYamlColumns(List<Map<String, String>> fields) {
    return fields.map((f) {
      final name = f['name']!;
      final type = f['type']!;
      final cleanType = StringUtils.removeNullable(type);
      
      // Convert Dart types to Serverpod types
      String serverpodType;
      switch (cleanType) {
        case 'String':
          serverpodType = 'String';
          break;
        case 'int':
          serverpodType = 'int';
          break;
        case 'double':
          serverpodType = 'double';
          break;
        case 'bool':
          serverpodType = 'bool';
          break;
        case 'DateTime':
          serverpodType = 'DateTime';
          break;
        default:
          serverpodType = cleanType;
      }
      
      // Format: fieldName: Type or fieldName: Type? for nullable
      final nullable = StringUtils.isNullableType(type);
      final typeStr = nullable ? '$serverpodType?' : serverpodType;
      return '  $name: $typeStr';
    }).join('\n');
  }

  String _generateTestFieldValues(List<Map<String, String>> fields) {
    return fields.map((f) {
      final name = f['name']!;
      final type = f['type']!;
      final cleanType = StringUtils.removeNullable(type);
      
      String defaultValue;
      switch (cleanType) {
        case 'String':
          defaultValue = "'test $name'";
          break;
        case 'int':
          defaultValue = '1';
          break;
        case 'double':
          defaultValue = '1.0';
          break;
        case 'bool':
          defaultValue = 'true';
          break;
        case 'DateTime':
          defaultValue = 'DateTime.now()';
          break;
        default:
          defaultValue = 'null';
      }
      
      return '$name: $defaultValue';
    }).join(',\n        ');
  }

  String _capitalizeFirst(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }
  
  String _getDefaultValue(String type, bool nullable) {
    if (nullable) return 'null';
    
    switch (type) {
      case 'String':
        return "''";
      case 'int':
        return '0';
      case 'double':
        return '0.0';
      case 'bool':
        return 'false';
      case 'DateTime':
        return 'null'; // Always nullable for DateTime in forms
      default:
        return 'null';
    }
  }
}

