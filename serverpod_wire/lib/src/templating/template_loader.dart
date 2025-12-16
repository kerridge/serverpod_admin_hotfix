import 'dart:io';
import 'package:path/path.dart' as path;
import '../utils/path_resolver.dart';

/// Loads template files from the templates directory
class TemplateLoader {
  final String templatesPath;

  TemplateLoader() : templatesPath = PathResolver.getTemplatesPath();

  /// Load a template file
  String loadTemplate(String templatePath) {
    final fullPath = path.join(templatesPath, templatePath);
    final file = File(fullPath);
    
    if (!file.existsSync()) {
      throw FileSystemException('Template not found: $fullPath');
    }
    
    return file.readAsStringSync();
  }

  /// Check if a template exists
  bool templateExists(String templatePath) {
    final fullPath = path.join(templatesPath, templatePath);
    return File(fullPath).existsSync();
  }
}

