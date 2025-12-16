import 'dart:io';
import 'package:path/path.dart' as path;

/// Resolves paths for generated files in the Serverpod project structure
class PathResolver {
  /// Check if current directory is a server package
  static bool isInServerDirectory() {
    final currentDir = Directory.current.path;
    final dirName = path.basename(currentDir);
    return dirName == 'server' || dirName.endsWith('_server');
  }

  /// Check if current directory is a Flutter package
  static bool isInFlutterDirectory() {
    final currentDir = Directory.current.path;
    final dirName = path.basename(currentDir);
    return dirName == 'client' || 
           dirName == 'flutter' || 
           dirName.endsWith('_flutter');
  }

  /// Get the server package path (intelligently detects current context)
  static String? getServerPath() {
    final currentDir = Directory.current.path;
    final dirName = path.basename(currentDir);
    
    // Strategy 1: If we're already in a server directory, return it immediately
    if (dirName == 'server' || dirName.endsWith('_server')) {
      return currentDir;
    }
    
    // Strategy 2: Search in current directory for server packages
    try {
      final currentDirObj = Directory(currentDir);
      if (currentDirObj.existsSync()) {
        final entries = currentDirObj.listSync(recursive: false);
        for (var entry in entries) {
          if (entry is Directory) {
            try {
              final name = path.basename(entry.path);
              if (name == 'server' || name.endsWith('_server')) {
                // Found a server directory - verify it has pubspec.yaml or lib structure
                final pubspecPath = path.join(entry.path, 'pubspec.yaml');
                final libPath = path.join(entry.path, 'lib');
                if (File(pubspecPath).existsSync() || Directory(libPath).existsSync()) {
                  return entry.path;
                }
              }
            } catch (e) {
              // Skip this entry
              continue;
            }
          }
        }
      }
    } catch (e) {
      // Continue to next strategy
    }
    
    // Strategy 3: If we're in a Flutter/client directory, search parent
    if (isInFlutterDirectory()) {
      try {
        final parentPath = path.dirname(currentDir);
        final parentDir = Directory(parentPath);
        if (parentDir.existsSync()) {
          final entries = parentDir.listSync(recursive: false);
          for (var entry in entries) {
            if (entry is Directory) {
              final name = path.basename(entry.path);
              if (name == 'server' || name.endsWith('_server')) {
                final pubspecPath = path.join(entry.path, 'pubspec.yaml');
                final libPath = path.join(entry.path, 'lib');
                if (File(pubspecPath).existsSync() || Directory(libPath).existsSync()) {
                  return entry.path;
                }
              }
            }
          }
        }
      } catch (e) {
        // Continue
      }
    }
    
    // Strategy 4: Search parent directory
    try {
      final parentPath = path.dirname(currentDir);
      final parentDir = Directory(parentPath);
      if (parentDir.existsSync() && parentPath != currentDir) {
        final entries = parentDir.listSync(recursive: false);
        for (var entry in entries) {
          if (entry is Directory) {
            final name = path.basename(entry.path);
            if (name == 'server' || name.endsWith('_server')) {
              final pubspecPath = path.join(entry.path, 'pubspec.yaml');
              final libPath = path.join(entry.path, 'lib');
              if (File(pubspecPath).existsSync() || Directory(libPath).existsSync()) {
                return entry.path;
              }
            }
          }
        }
      }
    } catch (e) {
      // Continue
    }
    
    return null;
  }

  /// Get Flutter app path (intelligently detects current context)
  static String? getFlutterPath() {
    final currentDir = Directory.current.path;
    
    // If we're already in a Flutter directory, use current directory
    if (isInFlutterDirectory()) {
      final pubspec = File(path.join(currentDir, 'pubspec.yaml'));
      if (pubspec.existsSync()) {
        return currentDir;
      }
    }
    
    // If we're in server directory, go up one level and search
    if (isInServerDirectory()) {
      try {
        final parentDir = Directory(path.dirname(currentDir));
        final entries = parentDir.listSync(recursive: false);
        
        for (var entry in entries) {
          if (entry is Directory) {
            final name = path.basename(entry.path);
            if (name == 'client' || name == 'flutter' || name.endsWith('_flutter')) {
              final pubspec = File(path.join(entry.path, 'pubspec.yaml'));
              if (pubspec.existsSync()) {
                return entry.path;
              }
            }
          }
        }
      } catch (e) {
        // Continue
      }
    }
    
    // Search from current directory
    try {
      final currentDirObj = Directory(currentDir);
      if (currentDirObj.existsSync()) {
        final entries = currentDirObj.listSync(recursive: false);
        
        for (var entry in entries) {
          if (entry is Directory) {
            final name = path.basename(entry.path);
            if (name == 'client' || name == 'flutter' || name.endsWith('_flutter')) {
              final pubspec = File(path.join(entry.path, 'pubspec.yaml'));
              if (pubspec.existsSync()) {
                return entry.path;
              }
            }
          }
        }
      }
    } catch (e) {
      // Continue
    }
    
    return null;
  }

  /// Get path to templates directory (relative to package root)
  static String getTemplatesPath() {
    // Try multiple approaches to find templates
    try {
      final scriptFile = File(Platform.script.toFilePath());
      if (scriptFile.existsSync()) {
        var dir = scriptFile.parent; // bin/
        dir = dir.parent; // package root
        final templatesPath = path.join(dir.path, 'templates');
        if (Directory(templatesPath).existsSync()) {
          return templatesPath;
        }
      }
    } catch (_) {
      // Ignore errors
    }
    
    // Check parent directories from script location
    try {
      final scriptFile = File(Platform.script.toFilePath());
      if (scriptFile.existsSync()) {
        var dir = scriptFile.parent;
        for (int i = 0; i < 5 && dir.path != dir.parent.path; i++) {
          final templatesDir = Directory(path.join(dir.path, 'templates'));
          if (templatesDir.existsSync()) {
            return templatesDir.path;
          }
          dir = dir.parent;
        }
      }
    } catch (_) {
      // Ignore errors
    }
    
    // Default fallback
    return path.join(Directory.current.path, 'templates');
  }

  /// Resolve server endpoint path (in endpoints folder)
  static String getServerEndpointPath(String serverPath, String modelSnake) {
    return path.join(serverPath, 'lib', 'src', 'endpoints', '${modelSnake}_endpoint.dart');
  }

  /// Resolve YAML model path (in model folder as .spy file)
  static String getYamlModelPath(String serverPath, String modelSnake) {
    return path.join(serverPath, 'lib', 'src', modelSnake, '${modelSnake}.spy');
  }

  /// Resolve Flutter list page path
  static String getFlutterListPath(String flutterPath, String modelSnake) {
    return path.join(flutterPath, 'lib', 'pages', modelSnake, '${modelSnake}_list.dart');
  }

  /// Resolve Flutter form page path
  static String getFlutterFormPath(String flutterPath, String modelSnake) {
    return path.join(flutterPath, 'lib', 'pages', modelSnake, '${modelSnake}_form.dart');
  }

  /// Resolve Flutter card widget path
  static String getFlutterCardPath(String flutterPath, String modelSnake) {
    return path.join(flutterPath, 'lib', 'widgets', '${modelSnake}_card.dart');
  }

  /// Ensure directory exists
  static void ensureDirectory(String filePath) {
    final dir = Directory(path.dirname(filePath));
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  }
}

