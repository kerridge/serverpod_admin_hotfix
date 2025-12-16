import 'package:serverpod/serverpod.dart';
import '../generated/{{model_snake}}/{{model_snake}}.dart';

/// Endpoint for managing {{ModelName}} entities
class {{ModelName}}Endpoint extends Endpoint {
  /// Create a new {{modelName}}
  Future<{{ModelName}}> create{{ModelName}}(
    Session session,
    {{fieldInputs}}
  ) async {
    final {{modelName}} = {{ModelName}}(
      {{constructorFields}}
    );
    
    final created = await {{ModelName}}.db.insertRow(session, {{modelName}});
    return created;
  }

  /// Get all {{modelName}}s
  Future<List<{{ModelName}}>> getAll{{ModelName}}s(Session session) async {
    return await {{ModelName}}.db.find(
      session,
      orderBy: {{ModelName}}.t.id,
    );
  }

  /// Get a {{modelName}} by id
  Future<{{ModelName}}?> get{{ModelName}}ById(
    Session session,
    int id,
  ) async {
    return await {{ModelName}}.db.findById(session, id);
  }

  /// Update a {{modelName}}
  Future<{{ModelName}}?> update{{ModelName}}(
    Session session,
    int id,
    {{fieldInputs}}
  ) async {
    final {{modelName}} = await {{ModelName}}.db.findById(session, id);
    if ({{modelName}} == null) {
      return null;
    }
    
    {{fieldAssignments}}
    
    final updated = await {{ModelName}}.db.updateRow(session, {{modelName}});
    return updated;
  }

  /// Delete a {{modelName}}
  Future<bool> delete{{ModelName}}(
    Session session,
    int id,
  ) async {
    final deleted = await {{ModelName}}.db.deleteRow(session, id);
    return deleted;
  }
}

