import 'package:sqflite_common/src/sql_builder.dart';
import 'package:sqflite_common/src/value_utils.dart';
import 'package:sqflite_common/utils/utils.dart';
import 'package:test/test.dart';

void main() {
  group('datetime', () {
    test('convertToSupportedValue converts DateTime to int', () {
      final dateTime = DateTime(2024, 11, 22, 10, 30, 45);
      final converted = convertToSupportedValue(dateTime);
      
      expect(converted, isA<int>());
      expect(converted, dateTime.millisecondsSinceEpoch);
    });

    test('convertToSupportedValue returns non-DateTime values unchanged', () {
      expect(convertToSupportedValue('test'), 'test');
      expect(convertToSupportedValue(123), 123);
      expect(convertToSupportedValue(45.67), 45.67);
      expect(convertToSupportedValue(null), null);
    });

    test('insert with DateTime value', () {
      final dateTime = DateTime(2024, 11, 22, 10, 30, 45);
      final builder = SqlBuilder.insert('test', <String, Object?>{
        'name': 'Event',
        'timestamp': dateTime,
      });

      expect(builder.sql, 'INSERT INTO test (name, timestamp) VALUES (?, ?)');
      expect(builder.arguments, hasLength(2));
      expect(builder.arguments![0], 'Event');
      expect(builder.arguments![1], dateTime.millisecondsSinceEpoch);
    });

    test('insert with multiple DateTime values', () {
      final createdAt = DateTime(2024, 11, 22, 10, 30, 45);
      final updatedAt = DateTime(2024, 11, 22, 11, 45, 30);
      
      final builder = SqlBuilder.insert('events', <String, Object?>{
        'name': 'Meeting',
        'created_at': createdAt,
        'updated_at': updatedAt,
      });

      expect(builder.sql, 'INSERT INTO events (name, created_at, updated_at) VALUES (?, ?, ?)');
      expect(builder.arguments, hasLength(3));
      expect(builder.arguments![0], 'Meeting');
      expect(builder.arguments![1], createdAt.millisecondsSinceEpoch);
      expect(builder.arguments![2], updatedAt.millisecondsSinceEpoch);
    });

    test('update with DateTime value', () {
      final dateTime = DateTime(2024, 11, 22, 10, 30, 45);
      final builder = SqlBuilder.update(
        'test',
        <String, Object?>{'timestamp': dateTime},
        where: 'id = ?',
        whereArgs: <Object>[1],
      );

      expect(builder.sql, 'UPDATE test SET timestamp = ? WHERE id = ?');
      expect(builder.arguments, hasLength(2));
      expect(builder.arguments![0], dateTime.millisecondsSinceEpoch);
      expect(builder.arguments![1], 1);
    });

    test('update with DateTime in whereArgs', () {
      final dateTime = DateTime(2024, 11, 22, 10, 30, 45);
      final builder = SqlBuilder.update(
        'test',
        <String, Object?>{'status': 'completed'},
        where: 'timestamp > ?',
        whereArgs: <Object>[dateTime],
      );

      expect(builder.sql, 'UPDATE test SET status = ? WHERE timestamp > ?');
      expect(builder.arguments, hasLength(2));
      expect(builder.arguments![0], 'completed');
      expect(builder.arguments![1], dateTime.millisecondsSinceEpoch);
    });

    test('query with DateTime in whereArgs', () {
      final dateTime = DateTime(2024, 11, 22, 10, 30, 45);
      final builder = SqlBuilder.query(
        'test',
        where: 'timestamp > ?',
        whereArgs: <Object>[dateTime],
      );

      expect(builder.sql, 'SELECT * FROM test WHERE timestamp > ?');
      expect(builder.arguments, hasLength(1));
      expect(builder.arguments![0], dateTime.millisecondsSinceEpoch);
    });

    test('delete with DateTime in whereArgs', () {
      final dateTime = DateTime(2024, 11, 22, 10, 30, 45);
      final builder = SqlBuilder.delete(
        'test',
        where: 'timestamp < ?',
        whereArgs: <Object>[dateTime],
      );

      expect(builder.sql, 'DELETE FROM test WHERE timestamp < ?');
      expect(builder.arguments, hasLength(1));
      expect(builder.arguments![0], dateTime.millisecondsSinceEpoch);
    });

    test('utility function dateTimeToInt', () {
      final dateTime = DateTime(2024, 11, 22, 10, 30, 45);
      final result = dateTimeToInt(dateTime);
      
      expect(result, isA<int>());
      expect(result, dateTime.millisecondsSinceEpoch);
    });

    test('utility function intToDateTime', () {
      final milliseconds = 1732270245000;
      final result = intToDateTime(milliseconds);
      
      expect(result, isA<DateTime>());
      expect(result.millisecondsSinceEpoch, milliseconds);
    });

    test('utility function dateTimeToString', () {
      final dateTime = DateTime.utc(2024, 11, 22, 10, 30, 45);
      final result = dateTimeToString(dateTime);
      
      expect(result, isA<String>());
      expect(result, '2024-11-22T10:30:45.000Z');
    });

    test('utility function stringToDateTime', () {
      const isoString = '2024-11-22T10:30:45.000Z';
      final result = stringToDateTime(isoString);
      
      expect(result, isA<DateTime>());
      expect(result.toIso8601String(), isoString);
    });

    test('roundtrip conversion int', () {
      final original = DateTime(2024, 11, 22, 10, 30, 45, 123);
      final asInt = dateTimeToInt(original);
      final restored = intToDateTime(asInt);
      
      expect(restored.millisecondsSinceEpoch, original.millisecondsSinceEpoch);
    });

    test('roundtrip conversion string', () {
      final original = DateTime.utc(2024, 11, 22, 10, 30, 45, 123);
      final asString = dateTimeToString(original);
      final restored = stringToDateTime(asString);
      
      expect(restored.toIso8601String(), original.toIso8601String());
    });

    test('DateTime.now() conversion', () {
      final now = DateTime.now();
      final converted = convertToSupportedValue(now);
      
      expect(converted, isA<int>());
      expect(converted, now.millisecondsSinceEpoch);
      
      final restored = intToDateTime(converted as int);
      expect(restored.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
    });

    test('insert with null and DateTime values', () {
      final dateTime = DateTime(2024, 11, 22);
      final builder = SqlBuilder.insert('test', <String, Object?>{
        'name': 'Event',
        'timestamp': dateTime,
        'deleted_at': null,
      });

      expect(
        builder.sql,
        'INSERT INTO test (name, timestamp, deleted_at) VALUES (?, ?, NULL)',
      );
      expect(builder.arguments, hasLength(2));
      expect(builder.arguments![0], 'Event');
      expect(builder.arguments![1], dateTime.millisecondsSinceEpoch);
    });

    test('mixed types with DateTime', () {
      final dateTime = DateTime(2024, 11, 22, 10, 30);
      final builder = SqlBuilder.insert('events', <String, Object?>{
        'id': 1,
        'name': 'Conference',
        'duration': 3.5,
        'start_time': dateTime,
        'active': null,
      });

      expect(builder.arguments, hasLength(4));
      expect(builder.arguments![0], 1);
      expect(builder.arguments![1], 'Conference');
      expect(builder.arguments![2], 3.5);
      expect(builder.arguments![3], dateTime.millisecondsSinceEpoch);
    });
  });
}
