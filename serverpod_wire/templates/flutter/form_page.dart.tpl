import 'package:flutter/material.dart';
import 'package:{{model_snake}}_client/{{model_snake}}_client.dart';

class {{ModelName}}FormPage extends StatefulWidget {
  final {{ModelName}}? {{modelName}};

  const {{ModelName}}FormPage({super.key, this.{{modelName}}});

  @override
  State<{{ModelName}}FormPage> createState() => _{{ModelName}}FormPageState();
}

class _{{ModelName}}FormPageState extends State<{{ModelName}}FormPage> {
{{fieldDeclarations}}

  @override
  void initState() {
    super.initState();
    if (widget.{{modelName}} != null) {
      final {{modelName}} = widget.{{modelName}}!;
      {{flutterFieldAssignments}}
    }
  }

  Future<void> _save() async {
    if (widget.{{modelName}} == null) {
      // Create new
      // TODO: Replace with your actual client instance
      // final client = YourServerpodClient();
      // await client.{{modelName}}.create{{ModelName}}(
      //   {{flutterFieldInputs}}
      // );
    } else {
      // Update existing
      // TODO: Replace with your actual client instance
      // final client = YourServerpodClient();
      // await client.{{modelName}}.update{{ModelName}}(
      //   widget.{{modelName}}!.id!,
      //   {{flutterFieldInputs}}
      // );
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.{{modelName}} == null ? 'Create {{ModelName}}' : 'Edit {{ModelName}}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
{{fieldWidgets}}
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

