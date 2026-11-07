const express = require('express');
const kegiatanRoutes = require('./routes/kegiatan');

const app = express();
app.use(express.json());

app.get('/', (req, res) => res.json({ message: 'API Sistem Informasi Event Desa' }));
app.use('/api/kegiatan', kegiatanRoutes);

app.use((req, res) => res.status(404).json({ message: 'Route tidak ditemukan' }));
app.use((err, req, res, next) => {
  if (err.type === 'entity.parse.failed') return res.status(400).json({ message: 'Body JSON tidak valid' });
  console.error(err);
  res.status(500).json({ message: 'Terjadi kesalahan pada server' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server berjalan di http://localhost:${PORT}`));
