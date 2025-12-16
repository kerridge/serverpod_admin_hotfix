/// Renders templates by replacing placeholders with actual values
class TemplateRenderer {
  /// Render a template string by replacing placeholders
  String render(String template, Map<String, String> context) {
    String result = template;
    
    context.forEach((key, value) {
      final placeholder = '{{$key}}';
      result = result.replaceAll(placeholder, value);
    });
    
    return result;
  }

  /// Build context map from model data
  static Map<String, String> buildContext({
    required String modelName,
    required String modelNameCamel,
    required String modelSnake,
    required String fieldDeclarations,
    required String fieldInputs,
    required String fieldAssignments,
    required String constructorFields,
    required String fieldWidgets,
    required String fields,
    required String yamlColumns,
    required String flutterFieldAssignments,
    required String flutterFieldInputs,
    required String testFieldValues,
  }) {
    return {
      'ModelName': modelName,
      'modelName': modelNameCamel,
      'model_snake': modelSnake,
      'fieldDeclarations': fieldDeclarations,
      'fieldInputs': fieldInputs,
      'fieldAssignments': fieldAssignments,
      'constructorFields': constructorFields,
      'fieldWidgets': fieldWidgets,
      'fields': fields,
      'yamlColumns': yamlColumns,
      'flutterFieldAssignments': flutterFieldAssignments,
      'flutterFieldInputs': flutterFieldInputs,
      'testFieldValues': testFieldValues,
    };
  }
}

