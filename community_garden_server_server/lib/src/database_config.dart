import 'package:mysql1/mysql1.dart';

class DatabaseConfig {
  static const String host = '74.50.79.163';
  static const int port = 3306;
  static const String database = 'hhkone_startnest';
  static const String username = 'hhkone_startnest';
  static const String password = 'startnest56119';
  static const bool useSSL = false;

  static Future<MySqlConnection> getConnection() async {
    final settings = ConnectionSettings(
      host: host,
      port: port,
      user: username,
      password: password,
      db: database,
      useSSL: useSSL,
    );

    try {
      final connection = await MySqlConnection.connect(settings);
      print('Database connected successfully');
      return connection;
    } catch (e) {
      print('Database connection failed: $e');
      rethrow;
    }
  }

  static Future<void> closeConnection(MySqlConnection connection) async {
    try {
      await connection.close();
      print('Database connection closed');
    } catch (e) {
      print('Error closing database connection: $e');
    }
  }
} 