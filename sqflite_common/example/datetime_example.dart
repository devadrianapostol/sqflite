// Example demonstrating DateTime support in sqflite
// This is a documentation example only (sqflite_common requires a DatabaseFactory implementation)

import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common/utils/utils.dart';

/// Example showing how to use DateTime with sqflite
/// 
/// Note: This is a conceptual example. To run this code, you need to use
/// a concrete implementation like sqflite or sqflite_common_ffi.
Future<void> datetimeExample(DatabaseFactory factory) async {
  // Open or create a database
  final db = await factory.openDatabase(
    'events.db',
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (Database db, int version) async {
        // Create a table with an INTEGER column for storing DateTime
        await db.execute('''
          CREATE TABLE events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            updated_at INTEGER
          )
        ''');
      },
    ),
  );

  // Example 1: Insert with DateTime (automatically converted to int)
  print('Example 1: Insert with DateTime');
  final now = DateTime.now();
  final eventId = await db.insert('events', {
    'name': 'Meeting with team',
    'created_at': now, // DateTime automatically converted to millisecondsSinceEpoch
    'updated_at': now,
  });
  print('Inserted event with ID: $eventId');

  // Example 2: Query and convert back to DateTime
  print('\nExample 2: Query and convert back to DateTime');
  final events = await db.query('events', where: 'id = ?', whereArgs: [eventId]);
  if (events.isNotEmpty) {
    final event = events.first;
    final createdAt =
        DateTime.fromMillisecondsSinceEpoch(event['created_at'] as int);
    print('Event: ${event['name']}');
    print('Created at: $createdAt');
  }

  // Example 3: Update with DateTime
  print('\nExample 3: Update with DateTime');
  final updateTime = DateTime.now();
  await db.update(
    'events',
    {'updated_at': updateTime},
    where: 'id = ?',
    whereArgs: [eventId],
  );
  print('Updated event with new timestamp');

  // Example 4: Query with DateTime in whereArgs
  print('\nExample 4: Query with DateTime in whereArgs');
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  final recentEvents = await db.query(
    'events',
    where: 'created_at > ?',
    whereArgs: [yesterday], // DateTime in whereArgs automatically converted
  );
  print('Found ${recentEvents.length} events created in the last 24 hours');

  // Example 5: Using utility functions explicitly
  print('\nExample 5: Using utility functions');
  final specificDate = DateTime(2024, 11, 22, 10, 30);

  // Convert to int for storage
  final timestampInt = dateTimeToInt(specificDate);
  await db.insert('events', {
    'name': 'Scheduled event',
    'created_at': timestampInt,
  });

  // Convert to ISO8601 string (alternative storage format)
  final timestampStr = dateTimeToString(specificDate);
  print('ISO8601 format: $timestampStr');

  // Convert back from string
  final parsedDate = stringToDateTime(timestampStr);
  print('Parsed date: $parsedDate');

  // Example 6: Delete with DateTime in whereArgs
  print('\nExample 6: Delete old events');
  final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
  final deletedCount = await db.delete(
    'events',
    where: 'created_at < ?',
    whereArgs: [oneWeekAgo],
  );
  print('Deleted $deletedCount old events');

  // Example 7: Batch operations with DateTime
  print('\nExample 7: Batch operations with DateTime');
  final batch = db.batch();
  final batchTime = DateTime.now();
  
  batch.insert('events', {
    'name': 'Event 1',
    'created_at': batchTime,
  });
  
  batch.insert('events', {
    'name': 'Event 2',
    'created_at': batchTime.add(const Duration(hours: 1)),
  });
  
  batch.insert('events', {
    'name': 'Event 3',
    'created_at': batchTime.add(const Duration(hours: 2)),
  });
  
  await batch.commit();
  print('Batch insert completed with DateTime values');

  // Close the database
  await db.close();
  print('\nDatabase closed');
}

void main() {
  print('''
DateTime Support in sqflite
===========================

DateTime objects are now natively supported in sqflite and are automatically
converted to INTEGER (milliseconds since epoch) when storing in SQLite.

This example demonstrates various ways to use DateTime with sqflite:
1. Direct insert/update with DateTime objects
2. DateTime in query whereArgs
3. Converting retrieved values back to DateTime
4. Using utility functions for explicit conversion
5. Batch operations with DateTime

To run this example, use it with a DatabaseFactory implementation such as:
- sqflite (for Flutter mobile/desktop)
- sqflite_common_ffi (for unit tests and CLI apps)

For more information, see:
- sqflite/doc/supported_types.md
- sqflite_common/lib/utils/utils.dart (for utility functions)
''');
}
