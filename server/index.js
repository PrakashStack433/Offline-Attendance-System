const express = require('express');
const cors = require('cors');
const { pool, initDB } = require('./db');
const { v4: uuidv4 } = require('uuid');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 8080;

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Create class (teacher)
app.post('/api/class', async (req, res) => {
  try {
    const { name } = req.body;
    if (!name) return res.status(400).json({ error: 'Class name required' });

    const id = uuidv4();
    await pool.query('INSERT INTO classes (id, name) VALUES ($1, $2)', [id, name]);
    res.json({ id, name });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get class info
app.get('/api/class/:classId', async (req, res) => {
  try {
    const { classId } = req.params;
    const result = await pool.query('SELECT * FROM classes WHERE id = $1', [classId]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Class not found' });

    const studentCount = await pool.query(
      'SELECT COUNT(*) FROM students WHERE class_id = $1',
      [classId]
    );

    res.json({
      ...result.rows[0],
      studentCount: parseInt(studentCount.rows[0].count),
    });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

// List students in class
app.get('/api/class/:classId/students', async (req, res) => {
  try {
    const { classId } = req.params;
    const result = await pool.query(
      'SELECT * FROM students WHERE class_id = $1 ORDER BY enrollment_no',
      [classId]
    );
    res.json({ students: result.rows });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

// Add student to class
app.post('/api/class/:classId/student', async (req, res) => {
  try {
    const { classId } = req.params;
    const { id, name, enrollmentNo } = req.body;

    if (!id || !name || !enrollmentNo) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    await pool.query(
      'INSERT INTO students (id, class_id, name, enrollment_no) VALUES ($1, $2, $3, $4)',
      [id, classId, name, enrollmentNo]
    );
    res.json({ id, name, enrollmentNo });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

// Mark attendance (student calls this)
app.post('/api/class/:classId/attendance', async (req, res) => {
  try {
    const { classId } = req.params;
    const { studentId, name, enrollmentNo } = req.body;

    if (!studentId || !name || !enrollmentNo) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    // Check if already marked today
    const today = new Date().toISOString().split('T')[0];
    const existing = await pool.query(
      'SELECT id FROM attendance WHERE class_id = $1 AND student_id = $2 AND date = $3',
      [classId, studentId, today]
    );

    if (existing.rows.length > 0) {
      return res.json({ message: 'Already marked', status: 'duplicate' });
    }

    const id = uuidv4();
    const now = new Date();
    const date = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`;
    const time = `${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}:${String(now.getSeconds()).padStart(2, '0')}`;

    await pool.query(
      `INSERT INTO attendance (id, class_id, student_id, name, enrollment_no, date, time, present, source)
       VALUES ($1, $2, $3, $4, $5, $6, $7, true, 'online')`,
      [id, classId, studentId, name, enrollmentNo, date, time]
    );

    res.json({ message: 'Attendance marked', status: 'present' });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get attendance for a class (teacher)
app.get('/api/class/:classId/attendance', async (req, res) => {
  try {
    const { classId } = req.params;
    const { date } = req.query;

    let query = 'SELECT * FROM attendance WHERE class_id = $1';
    const params = [classId];

    if (date) {
      query += ' AND date = $2';
      params.push(date);
    }

    query += ' ORDER BY timestamp DESC';
    const result = await pool.query(query, params);
    res.json({ records: result.rows });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get student attendance history
app.get('/api/student/:studentId/history', async (req, res) => {
  try {
    const { studentId } = req.params;
    const result = await pool.query(
      `SELECT a.*, c.name as class_name
       FROM attendance a
       JOIN classes c ON a.class_id = c.id
       WHERE a.student_id = $1
       ORDER BY a.timestamp DESC`,
      [studentId]
    );
    res.json({ records: result.rows });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

// Start server
async function start() {
  await initDB();
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}

start();
