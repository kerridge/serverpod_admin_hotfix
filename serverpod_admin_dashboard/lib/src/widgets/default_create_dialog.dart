import 'package:flutter/material.dart';
import 'package:serverpod_admin_dashboard/src/controller/admin_dashboard.dart';
import 'package:serverpod_admin_dashboard/src/helpers/admin_resources.dart';
import 'package:serverpod_admin_dashboard/src/helpers/foreign_key_helper.dart';
import 'package:serverpod_admin_dashboard/src/widgets/foreign_key_dropdown.dart';

/// Default create dialog with modern design
class DefaultCreateDialog extends StatefulWidget {
  const DefaultCreateDialog({
    required this.resource,
    required this.onSubmit,
    required this.controller,
    super.key,
  });

  final AdminResource resource;
  final Future<bool> Function(Map<String, String> payload) onSubmit;
  final AdminDashboardController controller;

  @override
  State<DefaultCreateDialog> createState() => _DefaultCreateDialogState();
}

class _DefaultCreateDialogState extends State<DefaultCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _isoValues = {}; // Store ISO8601 values separately
  final Map<String, String?> _foreignKeyValues =
      {}; // Store selected foreign key values
  final Map<String, List<Map<String, String>>> _foreignKeyOptions =
      {}; // Cache foreign key options
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Only include non-primary columns for create
    for (final column in widget.resource.columns) {
      if (column.isPrimary) continue;
      _controllers[column.name] = TextEditingController();
      _isoValues[column.name] = '';
      if (column.foreignKeyTable != null) {
        _foreignKeyValues[column.name] = null;
        _loadForeignKeyOptions(column);
      }
    }
  }

  Future<void> _loadForeignKeyOptions(AdminColumn column) async {
    if (column.foreignKeyTable == null) return;

    final relatedResource = ForeignKeyHelper.findRelatedResource(
      widget.controller,
      column,
    );

    if (relatedResource == null) return;

    try {
      await widget.controller.loadRecords(relatedResource);

      if (mounted) {
        setState(() {
          _foreignKeyOptions[column.name] = widget.controller.records;
        });
      }
    } catch (_) {
      // Failed to load foreign key options, will show empty dropdown
      if (mounted) {
        setState(() {
          _foreignKeyOptions[column.name] = [];
        });
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Map<String, String> _buildPayload() {
    final payload = <String, String>{};

    for (final column in widget.resource.columns) {
      if (column.isPrimary) continue;

      if (column.foreignKeyTable != null) {
        // Use the selected foreign key value
        final selectedValue = _foreignKeyValues[column.name];
        if (selectedValue != null && selectedValue.isNotEmpty) {
          payload[column.name] = selectedValue;
        }
      } else if (_controllers.containsKey(column.name)) {
        final controller = _controllers[column.name]!;
        if (_isDateType(column)) {
          payload[column.name] = _isoValues[column.name] ?? '';
        } else {
          payload[column.name] = controller.text.trim();
        }
      }
    }

    return payload;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final payload = _buildPayload();

    final success = await widget.onSubmit(payload);
    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Failed to create record. Please try again.';
      });
    }
  }

  bool _isDateType(AdminColumn column) {
    final dataType = column.dataType.toLowerCase();
    return dataType.contains('date') || dataType.contains('time');
  }

  Future<String?> _pickDateTime(
    BuildContext context,
    String? currentValue,
    AdminColumn column,
  ) async {
    final now = DateTime.now();
    final initial = currentValue != null && currentValue.isNotEmpty
        ? DateTime.tryParse(currentValue)?.toLocal() ?? now
        : now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return null;

    final isDateTime = column.dataType.toLowerCase().contains('datetime');

    if (isDateTime) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initial),
      );
      if (pickedTime == null) return null;

      final dateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      return dateTime.toUtc().toIso8601String();
    } else {
      // Date only
      final dateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
      );
      return dateTime.toUtc().toIso8601String();
    }
  }

  String _formatDateValue(String? value, AdminColumn column) {
    if (value == null || value.isEmpty) return '';
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;

    final local = parsed.toLocal();
    final isDateTime = column.dataType.toLowerCase().contains('datetime');

    if (isDateTime) {
      final year = local.year.toString().padLeft(4, '0');
      final month = local.month.toString().padLeft(2, '0');
      final day = local.day.toString().padLeft(2, '0');
      final hour = local.hour.toString().padLeft(2, '0');
      final minute = local.minute.toString().padLeft(2, '0');
      return '$year-$month-$day $hour:$minute';
    } else {
      final year = local.year.toString().padLeft(4, '0');
      final month = local.month.toString().padLeft(2, '0');
      final day = local.day.toString().padLeft(2, '0');
      return '$year-$month-$day';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: theme.dividerColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Create ${widget.resource.tableName}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      ...widget.resource.columns
                          .where((col) => !col.isPrimary)
                          .map((column) {
                        final isDate = _isDateType(column);
                        final isForeignKey = column.foreignKeyTable != null;

                        // Foreign key dropdown
                        if (isForeignKey) {
                          final options = _foreignKeyOptions[column.name] ?? [];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ForeignKeyDropdown(
                              column: column,
                              controller: widget.controller,
                              options: options,
                              value: _foreignKeyValues[column.name],
                              onChanged: (value) {
                                setState(() {
                                  _foreignKeyValues[column.name] = value;
                                });
                              },
                            ),
                          );
                        }

                        // Regular text field
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: TextFormField(
                            controller: _controllers[column.name],
                            readOnly: isDate,
                            maxLines: null,
                            minLines: 1,
                            onTap: isDate
                                ? () async {
                                    final currentIso = _isoValues[column.name];
                                    final picked = await _pickDateTime(
                                      context,
                                      currentIso,
                                      column,
                                    );
                                    if (picked != null && mounted) {
                                      _isoValues[column.name] = picked;
                                      _controllers[column.name]!.text =
                                          _formatDateValue(picked, column);
                                      setState(() {});
                                    }
                                  }
                                : null,
                            textInputAction: TextInputAction.newline,
                            decoration: InputDecoration(
                              labelText: column.name,
                              hintText: isDate
                                  ? 'Tap to select date'
                                  : 'Enter ${column.name}',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor:
                                  theme.colorScheme.surfaceContainerHighest,
                              suffixIcon: isDate
                                  ? IconButton(
                                      icon: const Icon(
                                          Icons.calendar_today_outlined),
                                      onPressed: () async {
                                        final currentIso =
                                            _isoValues[column.name];
                                        final picked = await _pickDateTime(
                                          context,
                                          currentIso,
                                          column,
                                        );
                                        if (picked != null && mounted) {
                                          _isoValues[column.name] = picked;
                                          _controllers[column.name]!.text =
                                              _formatDateValue(picked, column);
                                          setState(() {});
                                        }
                                      },
                                    )
                                  : null,
                            ),
                            validator: (value) {
                              if (isForeignKey) {
                                // Foreign key validation is handled in dropdown
                                return null;
                              }
                              if (value == null || value.trim().isEmpty) {
                                return 'This field is required';
                              }
                              if (isDate && value.isNotEmpty) {
                                // Check if we have a valid ISO value stored
                                final isoValue = _isoValues[column.name];
                                if (isoValue == null || isoValue.isEmpty) {
                                  return 'Please select a date';
                                }
                                if (DateTime.tryParse(isoValue) == null) {
                                  return 'Invalid date';
                                }
                              }
                              return null;
                            },
                          ),
                        );
                      }),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: theme.colorScheme.error,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            // Actions
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.dividerColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_circle),
                    label: Text(_isSubmitting ? 'Creating...' : 'Create'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
