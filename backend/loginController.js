const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

// Controller untuk login
exports.login = (req, res) => {
  const db = req.app.get('db');
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ success: false, message: 'Email dan password wajib diisi.' });
  }
  db.query('SELECT * FROM users WHERE email = ?', [email], (err, results) => {
    if (err) {
      return res.status(500).json({ success: false, message: 'Kesalahan server.', error: err });
    }
    if (results.length === 0) {
      return res.status(401).json({ success: false, message: 'Email tidak ditemukan.' });
    }
    const user = results[0];
    // Penyesuaian prefix hash jika dari Laravel
    let hash = user.password;
    if (hash.startsWith('$2y$')) {
      hash = '$2b$' + hash.slice(4);
    }
    bcrypt.compare(password, hash, (err, isMatch) => {
      if (err) {
        return res.status(500).json({ success: false, message: 'Kesalahan server.', error: err });
      }
      if (!isMatch) {
        return res.status(401).json({ success: false, message: 'Password salah.' });
      }
      // Jika login berhasil, buat token JWT (opsional)
      const token = jwt.sign({ id: user.id, email: user.email }, 'your_secret_key', { expiresIn: '1h' });
      return res.json({ success: true, message: 'Login berhasil', token, user_id: user.id });
    });
  });
};

// Endpoint logout (opsional, untuk frontend yang pakai token)
exports.logout = (req, res) => {
  // Jika pakai token JWT, logout cukup di sisi frontend (hapus token di storage)
  // Jika ingin blacklist token, bisa simpan token ke database blacklist (tidak wajib)
  return res.json({ success: true, message: 'Logout berhasil' });
};
