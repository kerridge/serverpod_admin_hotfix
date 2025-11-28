import 'package:flutter/material.dart';
import 'package:serverpod_admin_dashboard/src/helpers/admin_resources.dart';
import 'package:serverpod_admin_dashboard/src/widgets/records_body.dart';

class RecordsPane extends StatefulWidget {
  const RecordsPane({
    required this.resource,
    required this.records,
    required this.isLoading,
    required this.errorMessage,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    this.onView,
    this.totalRecords,
    this.searchQuery,
    this.onSearchChanged,
    this.onClearSearch,
    super.key,
  });

  final AdminResource? resource;
  final List<Map<String, String>> records;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onAdd;
  final void Function(Map<String, String> record)? onEdit;
  final void Function(Map<String, String> record)? onDelete;
  final void Function(Map<String, String> record)? onView;
  final int? totalRecords;
  final String? searchQuery;
  final void Function(String)? onSearchChanged;
  final VoidCallback? onClearSearch;

  @override
  State<RecordsPane> createState() => _RecordsPaneState();
}

class _RecordsPaneState extends State<RecordsPane> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery ?? '');
  }

  @override
  void didUpdateWidget(RecordsPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only sync controller when resource changes (clear search on resource change)
    if (oldWidget.resource?.key != widget.resource?.key) {
      _searchController.clear();
    }
    // Don't sync controller text on searchQuery changes - let the TextField manage its own state
    // The searchQuery prop is just for external updates (like clearing), not for syncing during typing
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.resource == null) {
      return Center(
        child: Text(
          'Select a resource to view its records.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              color: theme.colorScheme.primary.withOpacity(0.06),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.resource!.tableName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Chip(
                          label: Text(
                            widget.totalRecords != null &&
                                    widget.totalRecords != widget.records.length
                                ? '${widget.records.length} of ${widget.totalRecords} records'
                                : '${widget.records.length} records',
                            style: theme.textTheme.labelLarge,
                          ),
                          avatar: const Icon(Icons.table_rows, size: 18),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (widget.onSearchChanged != null)
                      SizedBox(
                        width: 300,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            suffixIcon: (widget.searchQuery ?? '').isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 20),
                                    onPressed: () {
                                      _searchController.clear();
                                      widget.onClearSearch?.call();
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    style: IconButton.styleFrom(
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color:
                                    theme.colorScheme.outline.withOpacity(0.3),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color:
                                    theme.colorScheme.outline.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            isDense: true,
                          ),
                          onChanged: widget.onSearchChanged,
                        ),
                      ),
                    if (widget.onSearchChanged != null)
                      const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: widget.onAdd,
                      icon: const Icon(Icons.add),
                      label: Text('Add ${widget.resource!.tableName}'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: RecordsBody(
                resource: widget.resource!,
                records: widget.records,
                isLoading: widget.isLoading,
                errorMessage: widget.errorMessage,
                onEdit: widget.onEdit,
                onDelete: widget.onDelete,
                onView: widget.onView,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
