import 'package:flutter/material.dart';

/// Action buttons widget for record rows.
/// Displays view, edit, and delete buttons.
class RecordsActionButtons extends StatelessWidget {
  const RecordsActionButtons({
    required this.record,
    this.onView,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final Map<String, String> record;
  final void Function(Map<String, String> record)? onView;
  final void Function(Map<String, String> record)? onEdit;
  final void Function(Map<String, String> record)? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onView != null)
          IconButton(
            tooltip: 'Show record',
            icon: const Icon(Icons.visibility_outlined),
            onPressed: () => onView!(record),
          ),
        if (onEdit != null)
          IconButton(
            tooltip: 'Edit record',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => onEdit!(record),
          ),
        if (onDelete != null)
          IconButton(
            tooltip: 'Delete record',
            icon: Icon(
              Icons.delete_outline,
              color: theme.colorScheme.error,
            ),
            onPressed: () => onDelete!(record),
          ),
      ],
    );
  }
}
