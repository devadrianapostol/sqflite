import 'package:sqflite_common/src/utils.dart';
import 'package:sqflite_common/src/utils.dart' as impl;

/// helper to get the first int value in a query
/// Useful for COUNT(*) queries
int? firstIntValue(List<Map<String, Object?>> list) {
  if (list.isNotEmpty) {
    final firstRow = list.first;
    if (firstRow.isNotEmpty) {
      return parseInt(firstRow.values.first);
    }
  }
  return null;
}

/// Utility to encode a blob to allow blob query using
/// `'hex(blob_field) = ?', Sqlite.hex([1,2,3])`
String hex(List<int> bytes) {
  final buffer = StringBuffer();
  for (var part in bytes) {
    if (part & 0xff != part) {
      throw FormatException('$part is not a byte integer');
    }
    buffer.write('${part < 16 ? '0' : ''}${part.toRadixString(16)}');
  }
  return buffer.toString().toUpperCase();
}

/// Deprecated since 1.1.7+.
///
/// Used internally.
@Deprecated('Used internally')
void Function()? get lockWarningCallback => impl.lockWarningCallback;

/// Deprecated since 1.1.7+.
@Deprecated('Used internally')
set lockWarningCallback(void Function()? callback) =>
    impl.lockWarningCallback = callback;

/// Deprecated since 1.1.7+.
@Deprecated('Used internally')
Duration? get lockWarningDuration => impl.lockWarningDuration;

/// Deprecated since 1.1.7+.
@Deprecated('Used internally')
set lockWarningDuration(Duration? duration) =>
    impl.lockWarningDuration = duration;

/// Change database lock behavior mechanism.
///
/// Default behavior is to print a message if a command hangs for more than
/// 10 seconds. Set en empty callback (not null) to prevent it from being
/// displayed.
void setLockWarningInfo({Duration? duration, void Function()? callback}) {
  impl.lockWarningDuration = duration ?? impl.lockWarningDuration;
  impl.lockWarningCallback = callback ?? impl.lockWarningCallback;
}

/// count column.
const sqlCountColumn = 'COUNT(*)';

/// Custom pragma prefix.
const sqflitePragmaPrefix = 'PRAGMA sqflite -- ';

/// See:
/// * https://github.com/tekartik/sqflite/pull/1058 (iOS implementation)
/// * https://github.com/tekartik/sqflite/issues/525 (FFI)

const sqflitePragmaDbDefensiveOff =
    '${sqflitePragmaPrefix}db_config_defensive_off';

/// Convert a DateTime to milliseconds since epoch for storage in SQLite.
///
/// DateTime values are stored as INTEGER (milliseconds since epoch) in SQLite.
/// Use this function when you need to explicitly convert a DateTime for storage.
///
/// Example:
/// ```dart
/// final timestamp = dateTimeToInt(DateTime.now());
/// await db.insert('events', {'timestamp': timestamp});
/// ```
int dateTimeToInt(DateTime dateTime) {
  return dateTime.millisecondsSinceEpoch;
}

/// Convert milliseconds since epoch to a DateTime object.
///
/// Use this function to convert INTEGER timestamp values read from SQLite
/// back to DateTime objects.
///
/// Example:
/// ```dart
/// final rows = await db.query('events');
/// final dateTime = intToDateTime(rows.first['timestamp'] as int);
/// ```
DateTime intToDateTime(int milliseconds) {
  return DateTime.fromMillisecondsSinceEpoch(milliseconds);
}

/// Convert a DateTime to ISO8601 string for storage in SQLite.
///
/// DateTime values can be stored as TEXT in ISO8601 format in SQLite.
/// Use this function when you prefer string representation over integer.
///
/// Example:
/// ```dart
/// final timestamp = dateTimeToString(DateTime.now());
/// await db.insert('events', {'timestamp': timestamp});
/// ```
String dateTimeToString(DateTime dateTime) {
  return dateTime.toIso8601String();
}

/// Convert an ISO8601 string to a DateTime object.
///
/// Use this function to convert TEXT timestamp values read from SQLite
/// back to DateTime objects.
///
/// Example:
/// ```dart
/// final rows = await db.query('events');
/// final dateTime = stringToDateTime(rows.first['timestamp'] as String);
/// ```
DateTime stringToDateTime(String iso8601String) {
  return DateTime.parse(iso8601String);
}
