const mysql = require('mysql2');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Storage untuk file media
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const dir = path.join(__dirname, '../public/images/Grupchat');
    fs.mkdirSync(dir, { recursive: true });
    cb(null, dir);
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + '_' + file.originalname);
  }
});
const upload = multer({ storage: storage, limits: { fileSize: 10 * 1024 * 1024 } });

// Ambil koneksi db dari app
function getDb(req) {
  return req.app.get('db');
}

exports.fetchMessages = (req, res) => {
  const db = getDb(req);
  db.query('SELECT m.*, u.nama as user_name FROM messages m JOIN users u ON m.user_id = u.id ORDER BY m.created_at ASC', (err, results) => {
    if (err) return res.status(500).json({ success: false, message: 'DB error', error: err });
    res.json(results);
  });
};

exports.storeMessage = [
  upload.single('media'),
  (req, res) => {
    const db = getDb(req);
    const userId = req.user.id; // req.user diisi dari middleware auth JWT
    let { message } = req.body;
    let mediaPath = null;
    let mediaType = null;

    if (!message && !req.file) {
      return res.status(400).json({ success: false, message: 'Pesan atau media harus diisi.' });
    }

    // Mention: ubah @nama jadi <span class="mention">@nama</span>
    if (message) {
      message = message.replace(/@([\w.\s]+)/g, '<span class="mention">@$1</span>');
    }

    if (req.file) {
      mediaPath = 'images/Grupchat/' + req.file.filename;
      mediaType = req.file.mimetype.split('/')[0];
    }

    db.query('INSERT INTO messages (user_id, message, media_path, media_type) VALUES (?, ?, ?, ?)',
      [userId, message, mediaPath, mediaType],
      (err, result) => {
        if (err) return res.status(500).json({ success: false, message: 'DB error', error: err });
        res.json({ success: true, message: 'Pesan berhasil dikirim!' });
      }
    );
  }
];

exports.searchUsers = (req, res) => {
  const db = getDb(req);
  const query = req.query.query;
  db.query('SELECT id, nama FROM users WHERE nama LIKE ? LIMIT 5', [`%${query}%`], (err, results) => {
    if (err) return res.status(500).json({ success: false, message: 'DB error', error: err });
    res.json(results);
  });
};
