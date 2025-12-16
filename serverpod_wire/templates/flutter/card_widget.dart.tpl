import 'package:flutter/material.dart';
import 'package:{{model_snake}}_client/{{model_snake}}_client.dart';

class {{ModelName}}Card extends StatelessWidget {
  final {{ModelName}} {{modelName}};
  final VoidCallback? onTap;

  const {{ModelName}}Card({
    super.key,
    required this.{{modelName}},
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '{{ModelName}} #${{{modelName}}.id}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'ID: ${{{modelName}}.id}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

