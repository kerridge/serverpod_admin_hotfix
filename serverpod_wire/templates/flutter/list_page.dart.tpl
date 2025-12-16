import 'package:flutter/material.dart';
import 'package:{{model_snake}}_client/{{model_snake}}_client.dart';
import '{{model_snake}}_form.dart';

class {{ModelName}}ListPage extends StatefulWidget {
  const {{ModelName}}ListPage({super.key});

  @override
  State<{{ModelName}}ListPage> createState() => _{{ModelName}}ListPageState();
}

class _{{ModelName}}ListPageState extends State<{{ModelName}}ListPage> {
  late Future<List<{{ModelName}}>> _{{modelName}}sFuture;

  @override
  void initState() {
    super.initState();
    _{{modelName}}sFuture = _load{{ModelName}}s();
  }

  Future<List<{{ModelName}}>> _load{{ModelName}}s() async {
    // TODO: Replace with your actual client instance
    // final client = YourServerpodClient();
    // return await client.{{modelName}}.getAll{{ModelName}}s();
    return [];
  }

  Future<void> _refresh() async {
    setState(() {
      _{{modelName}}sFuture = _load{{ModelName}}s();
    });
  }

  Future<void> _delete{{ModelName}}({{ModelName}} {{modelName}}) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete {{ModelName}}'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // TODO: Replace with your actual client instance
      // final client = YourServerpodClient();
      // await client.{{modelName}}.delete{{ModelName}}({{modelName}}.id!);
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('{{ModelName}}s'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<{{ModelName}}>>(
        future: _{{modelName}}sFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final {{modelName}}s = snapshot.data ?? [];

          if ({{modelName}}s.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inbox, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No {{modelName}}s found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const {{ModelName}}FormPage(),
                        ),
                      ).then((_) => _refresh());
                    },
                    child: const Text('Create First {{ModelName}}'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: {{modelName}}s.length,
              itemBuilder: (context, index) {
                final {{modelName}} = {{modelName}}s[index];
                return ListTile(
                  title: Text('{{ModelName}} #${{{modelName}}.id}'),
                  subtitle: Text('ID: ${{{modelName}}.id}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _delete{{ModelName}}({{modelName}}),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => {{ModelName}}FormPage({{modelName}}: {{modelName}}),
                      ),
                    ).then((_) => _refresh());
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const {{ModelName}}FormPage(),
            ),
          ).then((_) => _refresh());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

