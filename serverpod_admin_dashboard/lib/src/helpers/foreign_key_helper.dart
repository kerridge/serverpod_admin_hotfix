import 'package:serverpod_admin_dashboard/src/controller/admin_dashboard.dart';
import 'package:serverpod_admin_dashboard/src/helpers/admin_resources.dart';

/// Helper class for foreign key operations in admin dialogs.
class ForeignKeyHelper {
  /// Finds the related resource for a foreign key column.
  /// Returns null if the resource cannot be found.
  static AdminResource? findRelatedResource(
    AdminDashboardController controller,
    AdminColumn column,
  ) {
    if (column.foreignKeyTable == null) return null;

    final foreignTableName = column.foreignKeyTable!;

    // Try exact match first
    try {
      return controller.resources.firstWhere(
        (r) => r.key == foreignTableName || r.tableName == foreignTableName,
      );
    } catch (_) {
      // Fallback to partial match
      try {
        return controller.resources.firstWhere(
          (r) =>
              r.key.contains(foreignTableName) ||
              r.tableName.contains(foreignTableName),
        );
      } catch (_) {
        return null;
      }
    }
  }

  /// Formats a foreign key option for display in a dropdown.
  /// Returns a readable string showing the record's primary key and
  /// a descriptive field if available.
  static String formatForeignKeyOption(
    Map<String, String> record,
    AdminResource resource,
  ) {
    final primaryColumn = _findPrimaryColumn(resource);
    final displayColumn = _findDisplayColumn(resource, primaryColumn);

    final primaryValue = record[primaryColumn.name] ?? '';
    final displayValue = record[displayColumn.name] ?? '';

    if (displayValue.isNotEmpty && displayValue != primaryValue) {
      return '$displayValue (ID: $primaryValue)';
    }
    return 'ID: $primaryValue';
  }

  /// Finds the primary key column for a resource.
  static AdminColumn _findPrimaryColumn(AdminResource resource) {
    return resource.columns.firstWhere(
      (col) => col.isPrimary,
      orElse: () => resource.columns.first,
    );
  }

  /// Finds a suitable display column for showing foreign key options.
  /// Prefers text/string columns that are not the primary key.
  static AdminColumn _findDisplayColumn(
    AdminResource resource,
    AdminColumn primaryColumn,
  ) {
    final textColumns = resource.columns.where(
      (col) =>
          !col.isPrimary &&
          (col.dataType.toLowerCase().contains('string') ||
              col.dataType.toLowerCase().contains('text')),
    );

    if (textColumns.isNotEmpty) {
      return textColumns.first;
    }

    // Fallback to first non-primary column
    final nonPrimaryColumns = resource.columns.where(
      (col) => !col.isPrimary,
    );

    return nonPrimaryColumns.isNotEmpty
        ? nonPrimaryColumns.first
        : primaryColumn;
  }

  /// Gets the primary key value from a record.
  static String? getPrimaryKeyValue(
    Map<String, String> record,
    AdminResource resource,
  ) {
    final primaryColumn = _findPrimaryColumn(resource);
    return record[primaryColumn.name];
  }
}
