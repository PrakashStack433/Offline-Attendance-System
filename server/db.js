const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false },
});

async function initDB() {
  const client = await pool.connect();
  try {
    await client.query(`
      CREATE TABLE IF NOT EXISTS classes (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT NOW()
      );
    `);

    await client.query(`
      CREATE TABLE IF NOT EXISTS students (
        id TEXT PRIMARY KEY,
        class_id TEXT NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
        name TEXT NOT NULL,
        enrollment_no TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT NOW()
      );
    `);

    await client.query(`
      CREATE TABLE IF NOT EXISTS attendance (
        id TEXT PRIMARY KEY,
        class_id TEXT NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
        student_id TEXT NOT NULL,
        name TEXT NOT NULL,
        enrollment_no TEXT NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        timestamp TIMESTAMP DEFAULT NOW(),
        present BOOLEAN DEFAULT true,
        source TEXT DEFAULT 'online'
      );
    `);

    await client.query(`
      CREATE TABLE IF NOT EXISTS server_config (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      );
    `);

    console.log('Database initialized');
  } finally {
    client.release();
  }
}

module.exports = { pool, initDB };
