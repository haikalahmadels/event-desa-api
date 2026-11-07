const express = require('express');
const db = require('../db');

const router = express.Router();
const FIELDS = ['kategori_id', 'judul', 'deskripsi', 'lokasi', 'tanggal', 'kuota'];

function validasi(body) {
  if (!body || !body.kategori_id || !body.judul || !body.tanggal) {
    return 'kategori_id, judul, dan tanggal wajib diisi';
  }
  return null;
}

function handleDbError(err, res, next) {
  if (err.code === '23503') return res.status(400).json({ message: 'kategori_id tidak ditemukan' });
  if (['22P02', '22007', '22008', '23514'].includes(err.code)) {
    return res.status(400).json({ message: 'Format data tidak valid', detail: err.message });
  }
  next(err);
}

// GET semua kegiatan
router.get('/', async (req, res, next) => {
  try {
    const { rows } = await db.query(
      `SELECT k.*, kk.nama AS kategori
       FROM kegiatan k JOIN kategori_kegiatan kk ON kk.id = k.kategori_id
       ORDER BY k.id`
    );
    res.json({ message: 'Berhasil mengambil semua kegiatan', data: rows });
  } catch (err) {
    next(err);
  }
});

// GET kegiatan berdasarkan id
router.get('/:id', async (req, res, next) => {
  try {
    const { rows } = await db.query(
      `SELECT k.*, kk.nama AS kategori
       FROM kegiatan k JOIN kategori_kegiatan kk ON kk.id = k.kategori_id
       WHERE k.id = $1`,
      [req.params.id]
    );
    if (!rows.length) return res.status(404).json({ message: 'Kegiatan tidak ditemukan' });
    res.json({ message: 'Berhasil mengambil kegiatan', data: rows[0] });
  } catch (err) {
    handleDbError(err, res, next);
  }
});

// POST kegiatan baru
router.post('/', async (req, res, next) => {
  const error = validasi(req.body);
  if (error) return res.status(400).json({ message: error });
  try {
    const { rows } = await db.query(
      `INSERT INTO kegiatan (${FIELDS.join(', ')}) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
      FIELDS.map((f) => req.body[f] ?? null)
    );
    res.status(201).json({ message: 'Kegiatan berhasil dibuat', data: rows[0] });
  } catch (err) {
    handleDbError(err, res, next);
  }
});

// PUT update kegiatan berdasarkan id
router.put('/:id', async (req, res, next) => {
  const error = validasi(req.body);
  if (error) return res.status(400).json({ message: error });
  try {
    const { rows } = await db.query(
      `UPDATE kegiatan SET ${FIELDS.map((f, i) => `${f} = $${i + 1}`).join(', ')}
       WHERE id = $7 RETURNING *`,
      [...FIELDS.map((f) => req.body[f] ?? null), req.params.id]
    );
    if (!rows.length) return res.status(404).json({ message: 'Kegiatan tidak ditemukan' });
    res.json({ message: 'Kegiatan berhasil diperbarui', data: rows[0] });
  } catch (err) {
    handleDbError(err, res, next);
  }
});

// DELETE kegiatan berdasarkan id
router.delete('/:id', async (req, res, next) => {
  try {
    const { rows } = await db.query('DELETE FROM kegiatan WHERE id = $1 RETURNING *', [req.params.id]);
    if (!rows.length) return res.status(404).json({ message: 'Kegiatan tidak ditemukan' });
    res.json({ message: 'Kegiatan berhasil dihapus', data: rows[0] });
  } catch (err) {
    handleDbError(err, res, next);
  }
});

module.exports = router;
