import * as SQLite from 'expo-sqlite';

const db = SQLite.openDatabase('collecto.db');

// ...existing code...

// Create User table
db.transaction(tx => {
  tx.executeSql(
    `CREATE TABLE IF NOT EXISTS User (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT UNIQUE NOT NULL,
      password TEXT NOT NULL
    );`
  );
});

// ...existing code...
