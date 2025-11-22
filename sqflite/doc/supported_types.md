# Supported types

The API offers a way to save a record as map of type `Map<String, Object?>`. This map cannot be an
arbitrary map:
- Keys are column in a table (declared when creating the table)
- Values are field values in the record of type `num`, `String`, `Uint8List`, or `DateTime`

Nested content is not supported. For example, the following simple map is not supported:

```dart
{
  "title": "Table",
  "size": {"width": 80, "height": 80}
}
```

It should be flattened. One solution is to modify the map structure:

```sql
CREATE TABLE Product (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT,
  width INTEGER,
  height INTEGER)
```

```dart
{"title": "Table", "width": 80, "height": 80}
```

Another solution is to encode nested maps and lists as json (or other format), declaring the column
as a String.


```sql
CREATE TABLE Product (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT,
  size TEXT
)

```
```dart
{
  'title': 'Table',
  'size': '{"width":80,"height":80}'
};
```

## Supported SQLite types

No validity check is done on values yet so please avoid non supported types [https://www.sqlite.org/datatype3.html](https://www.sqlite.org/datatype3.html)

### DateTime Support

`DateTime` objects are now supported and automatically converted to `INTEGER` (milliseconds since epoch) when storing in SQLite.

```dart
// DateTime values are automatically converted
await db.insert('events', {
  'name': 'Meeting',
  'timestamp': DateTime.now(),  // Automatically converted to int
});

// When reading, convert back to DateTime
final rows = await db.query('events');
final timestamp = DateTime.fromMillisecondsSinceEpoch(rows.first['timestamp'] as int);
```

Utility functions are available for explicit conversion:
```dart
import 'package:sqflite_common/utils/utils.dart';

// Convert DateTime to int for storage
int timestampInt = dateTimeToInt(DateTime.now());

// Convert int back to DateTime
DateTime dateTime = intToDateTime(timestampInt);

// Convert DateTime to ISO8601 string (alternative storage format)
String timestampStr = dateTimeToString(DateTime.now());

// Convert ISO8601 string back to DateTime
DateTime dateTime2 = stringToDateTime(timestampStr);
```

For using SQLite's built-in `TIMESTAMP` type with date functions, see [date functions](https://www.sqlite.org/lang_datefunc.html). 
`TIMESTAMP` values are read as `String` that the application needs to parse.

`bool` is not a supported SQLite type. Use `INTEGER` and 0 and 1 values.

### INTEGER

* SQLite type: `INTEGER`
* Dart type: `int`
* Supported values: from -2^63 to 2^63 - 1

### REAL

* SQLite type: `REAL`
* Dart type: `num`

### TEXT

* SQLite type: `TEXT`
* Dart type: `String`

### BLOB

* SQLite typ: `BLOB`
* Dart type: `Uint8List`
