const { Pool, types } = require('pg');

// Kolom DATE dikembalikan sebagai teks 'YYYY-MM-DD', bukan Date JS yang tergeser zona waktu
types.setTypeParser(1082, (value) => value);

// Pool membaca PGHOST, PGPORT, PGUSER, PGPASSWORD, PGDATABASE dari .env
module.exports = new Pool();
