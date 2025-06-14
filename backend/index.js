const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const cors = require('cors');
const authController = require('./loginController');
const groupChatController = require('./groupChatController');
const app = express();
const port = 3000;

// Konfigurasi koneksi ke database MySQL
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '', // Ganti jika password MySQL Anda berbeda
  database: 'alumnet'
});

db.connect((err) => {
  if (err) {
    console.error('Koneksi ke database gagal:', err);
    return;
  }
  console.log('Terkoneksi ke database MySQL alumnet!');
});

// Set db ke app agar bisa diakses controller
app.set('db', db);

app.use(cors());
app.use(bodyParser.json());
app.use('/public', express.static('public'));

app.get('/', (req, res) => {
  res.send('Backend Node.js siap dan terkoneksi ke database MySQL alumnet!');
});

app.post('/login', authController.login);
app.post('/logout', authController.logout);

// Middleware auth JWT sederhana
const jwt = require('jsonwebtoken');
function authJWT(req, res, next) {
  const authHeader = req.headers['authorization'];
  if (!authHeader) return res.status(401).json({ success: false, message: 'Token tidak ditemukan' });
  const token = authHeader.split(' ')[1];
  jwt.verify(token, 'your_secret_key', (err, user) => {
    if (err) return res.status(403).json({ success: false, message: 'Token tidak valid' });
    req.user = user;
    next();
  });
}

// Group chat endpoints
app.get('/groupchat/messages', authJWT, groupChatController.fetchMessages);
app.post('/groupchat/messages', authJWT, groupChatController.storeMessage);
app.get('/groupchat/search-users', authJWT, groupChatController.searchUsers);

app.listen(port, '0.0.0.0', () => {
  console.log(`Server berjalan di http://0.0.0.0:${port}`);
});
