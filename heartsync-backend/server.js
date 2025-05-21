const express = require('express');
const multer = require('multer');
const cors = require('cors');
const path = require('path');
const sqlite3 = require('sqlite3').verbose();
const fs = require('fs');

const app = express();
const PORT = 3000;

// Configuração do banco de dados SQLite
const db = new sqlite3.Database('./heartsync.db', (err) => {
  if (err) {
    console.error('Erro ao conectar ao banco de dados:', err.message);
  } else {
    console.log('Conectado ao banco de dados SQLite');
    initializeDatabase();
  }
});

function initializeDatabase() {
  db.serialize(() => {
    // Criar tabela de usuários
    db.run(`CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      email TEXT UNIQUE NOT NULL,
      dataNascimento TEXT NOT NULL,
      senha TEXT NOT NULL,
      temFoto BOOLEAN DEFAULT FALSE,
      profileImagePath TEXT,
      heartcode TEXT UNIQUE NOT NULL,
      conectado BOOLEAN DEFAULT FALSE,
      createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )`);

    // Criar tabela de casais
    db.run(`CREATE TABLE IF NOT EXISTS couples (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      idUsuario1 INTEGER NOT NULL,
      idUsuario2 INTEGER NOT NULL,
      codigoConexao TEXT UNIQUE NOT NULL,
      FOREIGN KEY (idUsuario1) REFERENCES users (id),
      FOREIGN KEY (idUsuario2) REFERENCES users (id),
      createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )`);
  });
}

// Configurações do Express
app.use(cors({
  origin: ['http://localhost', 'http://10.0.2.2'], // Permitir Flutter e localhost
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use(express.json());

// Configuração do Multer para uploads
const uploadDir = 'upload';
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir);
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadDir),
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname);
    cb(null, `${file.fieldname}-${uniqueSuffix}${ext}`);
  }
});

const upload = multer({ storage });

// Rotas
app.post('/upload', upload.single('profile_image'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'Nenhum arquivo enviado.' });
  }
  const imageUrl = `http://10.0.2.2:${PORT}/upload/${req.file.filename}`;
  res.status(200).json({ imageUrl });
});

app.post('/users', async (req, res) => {
  const { nome, email, dataNascimento, senha, temFoto, profileImagePath } = req.body;

  // Gerar heartcode único
  const heartcode = generateHeartCode();

  try {
    const result = await new Promise((resolve, reject) => {
      db.run(
        `INSERT INTO users (nome, email, dataNascimento, senha, temFoto, profileImagePath, heartcode)
         VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [nome, email, dataNascimento, senha, temFoto, profileImagePath, heartcode],
        function(err) {
          if (err) reject(err);
          else resolve(this.lastID);
        }
      );
    });

    res.status(201).json({
      id: result,
      nome,
      email,
      heartcode,
      profileImagePath
    });
  } catch (err) {
    if (err.message.includes('UNIQUE constraint failed: users.email')) {
      return res.status(400).json({ error: 'Email já registrado' });
    }
    console.error('Erro ao criar usuário:', err);
    res.status(500).json({ error: 'Erro ao criar usuário' });
  }
});

app.post('/validate-heartcode', async (req, res) => {
  const { userHeartCode, partnerHeartCode } = req.body;

  try {
    // Verificar se os heartcodes existem
    const [user, partner] = await Promise.all([
      getUserByHeartCode(userHeartCode),
      getUserByHeartCode(partnerHeartCode)
    ]);

    if (!user || !partner) {
      return res.status(404).json({ error: 'Usuário ou parceiro não encontrado' });
    }

    if (user.conectado || partner.conectado) {
      return res.status(400).json({ error: 'Um dos usuários já está conectado' });
    }

    // Gerar código de conexão
    const codigoConexao = `CONN${Math.random().toString(36).substring(2, 10).toUpperCase()}`;

    // Criar conexão
    await new Promise((resolve, reject) => {
      db.run(
        `INSERT INTO couples (idUsuario1, idUsuario2, codigoConexao) VALUES (?, ?, ?)`,
        [user.id, partner.id, codigoConexao],
        (err) => err ? reject(err) : resolve()
      );
    });

    // Atualizar status de conexão
    await Promise.all([
      updateUserConnectionStatus(user.id, true),
      updateUserConnectionStatus(partner.id, true)
    ]);

    res.status(200).json({ codigoConexao });
  } catch (err) {
    console.error('Erro ao validar heartcode:', err);
    res.status(500).json({ error: 'Erro ao validar heartcode' });
  }
});

// Funções auxiliares
function generateHeartCode() {
  const numbers = Math.floor(1000000 + Math.random() * 9000000).toString().substring(0, 7);
  const letters = String.fromCharCode(
    65 + Math.floor(Math.random() * 26),
    65 + Math.floor(Math.random() * 26)
  );
  return numbers + letters;
}

function getUserByHeartCode(heartcode) {
  return new Promise((resolve, reject) => {
    db.get(
      `SELECT * FROM users WHERE heartcode = ?`,
      [heartcode],
      (err, row) => err ? reject(err) : resolve(row)
    );
  });
}

function updateUserConnectionStatus(userId, status) {
  return new Promise((resolve, reject) => {
    db.run(
      `UPDATE users SET conectado = ? WHERE id = ?`,
      [status, userId],
      (err) => err ? reject(err) : resolve()
    );
  });
}

// Servir arquivos estáticos
app.use('/upload', express.static(path.join(__dirname, uploadDir)));

// Middleware de erro
app.use((err, req, res, next) => {
  console.error('Erro no servidor:', err);
  res.status(500).json({
    error: 'Falha no servidor. Tente novamente mais tarde.',
    details: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

// Iniciar servidor
app.listen(PORT, () => {
  console.log(`Servidor rodando em http://localhost:${PORT}`);
});