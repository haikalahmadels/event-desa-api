-- Sistem Informasi Event Desa
-- Relasi:
--   one-to-one   : warga <-> profil_warga
--   one-to-many  : rt -> warga, kategori_kegiatan -> kegiatan
--   many-to-many : warga <-> kegiatan (lewat pendaftaran_kegiatan dan panitia_kegiatan)

DROP TABLE IF EXISTS panitia_kegiatan, pendaftaran_kegiatan, kegiatan, kategori_kegiatan, profil_warga, warga, rt;

CREATE TABLE rt (
  id SERIAL PRIMARY KEY,
  nomor VARCHAR(5) NOT NULL UNIQUE,
  nama_ketua VARCHAR(100) NOT NULL
);

CREATE TABLE warga (
  id SERIAL PRIMARY KEY,
  rt_id INT NOT NULL REFERENCES rt(id) ON DELETE RESTRICT,
  nik CHAR(16) NOT NULL UNIQUE,
  nama VARCHAR(100) NOT NULL,
  no_hp VARCHAR(20)
);

CREATE TABLE profil_warga (
  id SERIAL PRIMARY KEY,
  warga_id INT NOT NULL UNIQUE REFERENCES warga(id) ON DELETE CASCADE,
  alamat TEXT NOT NULL,
  tanggal_lahir DATE,
  jenis_kelamin CHAR(1) CHECK (jenis_kelamin IN ('L', 'P')),
  pekerjaan VARCHAR(100)
);

CREATE TABLE kategori_kegiatan (
  id SERIAL PRIMARY KEY,
  nama VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE kegiatan (
  id SERIAL PRIMARY KEY,
  kategori_id INT NOT NULL REFERENCES kategori_kegiatan(id) ON DELETE RESTRICT,
  judul VARCHAR(150) NOT NULL,
  deskripsi TEXT,
  lokasi VARCHAR(150),
  tanggal DATE NOT NULL,
  kuota INT CHECK (kuota > 0),
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE pendaftaran_kegiatan (
  warga_id INT NOT NULL REFERENCES warga(id) ON DELETE CASCADE,
  kegiatan_id INT NOT NULL REFERENCES kegiatan(id) ON DELETE CASCADE,
  tanggal_daftar TIMESTAMP NOT NULL DEFAULT NOW(),
  status VARCHAR(10) NOT NULL DEFAULT 'terdaftar' CHECK (status IN ('terdaftar', 'hadir', 'batal')),
  PRIMARY KEY (warga_id, kegiatan_id)
);

CREATE TABLE panitia_kegiatan (
  warga_id INT NOT NULL REFERENCES warga(id) ON DELETE CASCADE,
  kegiatan_id INT NOT NULL REFERENCES kegiatan(id) ON DELETE CASCADE,
  peran VARCHAR(50) NOT NULL,
  PRIMARY KEY (warga_id, kegiatan_id)
);

-- Data contoh
INSERT INTO rt (nomor, nama_ketua) VALUES ('01', 'Budi Santoso'), ('02', 'Siti Aminah');

INSERT INTO warga (rt_id, nik, nama, no_hp) VALUES
  (1, '3201010101900001', 'Andi Pratama', '081234567801'),
  (1, '3201010101920002', 'Rina Wulandari', '081234567802'),
  (2, '3201010101950003', 'Joko Susilo', '081234567803');

INSERT INTO profil_warga (warga_id, alamat, tanggal_lahir, jenis_kelamin, pekerjaan) VALUES
  (1, 'Jl. Melati No. 1', '1990-01-01', 'L', 'Petani'),
  (2, 'Jl. Melati No. 5', '1992-03-12', 'P', 'Guru'),
  (3, 'Jl. Mawar No. 2', '1995-07-20', 'L', 'Pedagang');

INSERT INTO kategori_kegiatan (nama) VALUES ('Gotong Royong'), ('Olahraga'), ('Keagamaan');

INSERT INTO kegiatan (kategori_id, judul, deskripsi, lokasi, tanggal, kuota) VALUES
  (1, 'Kerja Bakti Bersih Selokan', 'Membersihkan selokan sebelum musim hujan', 'Sepanjang Jl. Melati', '2026-11-15', 30),
  (2, 'Turnamen Voli Antar RT', 'Lomba voli memperingati HUT desa', 'Lapangan Desa', '2026-11-22', 60);

INSERT INTO pendaftaran_kegiatan (warga_id, kegiatan_id) VALUES (1, 1), (2, 1), (3, 2);
INSERT INTO panitia_kegiatan (warga_id, kegiatan_id, peran) VALUES (2, 1, 'Koordinator'), (1, 2, 'Wasit');
