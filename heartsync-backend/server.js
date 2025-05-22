require('dotenv').config();
const express = require('express');
const multer = require('multer');
const cors = require('cors');
const path = require('path');
const sqlite3 = require('sqlite3').verbose();
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 3000;

// Configuração do banco de dados SQLite
const db = new sqlite3.Database('./heartsync.db', (err) => {
  if (err) {
    console.error('Erro ao conectar ao banco de dados:', err.message);
  } else {
    console.log('Conectado ao banco de dados SQLite');
    db.run('PRAGMA foreign_keys = ON;', (err) => {
      if (err) {
        console.error('Erro ao habilitar chaves estrangeiras:', err.message);
      } else {
        console.log('Chaves estrangeiras habilitadas');
      }
      initializeDatabase();
    });
  }
});

function initializeDatabase() {
  db.serialize(() => {
    // Tabela de usuários corrigida
    db.run(
      `CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        dataNascimento TEXT NOT NULL,
        senha TEXT NOT NULL,
        temFoto BOOLEAN DEFAULT FALSE,
        profileImagePath TEXT,
        heartcode TEXT UNIQUE NOT NULL,
        conectado BOOLEAN DEFAULT FALSE,
        createdAt TEXT DEFAULT (strftime('%Y-%m-%d %H:%M:%S', 'now'))
      )`, // Fechando o parêntese que estava faltando
      (err) => {
        if (err) console.error('Erro ao criar tabela users:', err.message);
        else console.log('Tabela users criada ou já existe');
      }
    );

    // Tabela de casais corrigida
    db.run(
      `CREATE TABLE IF NOT EXISTS couples (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idUsuario1 INTEGER NOT NULL,
        idUsuario2 INTEGER NOT NULL,
        codigoConexao TEXT UNIQUE NOT NULL,
        createdAt TEXT DEFAULT (strftime('%Y-%m-%d %H:%M:%S', 'now')),
        FOREIGN KEY (idUsuario1) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (idUsuario2) REFERENCES users (id) ON DELETE CASCADE
      )`, // Fechando o parêntese que estava faltando
      (err) => {
        if (err) console.error('Erro ao criar tabela couples:', err.message);
        else console.log('Tabela couples criada ou já existe');
      }
    );
  });
}

// Configurações do Express
app.use(cors({
  origin: ['http://localhost', 'http://10.0.2.2', 'http://localhost:8081'], // Adicionado localhost:8081 para Flutter
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

// Upload de imagem de perfil
app.post('/upload', upload.single('profile_image'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'Nenhum arquivo enviado.' });
  }
  const imageUrl = `http://10.0.2.2:${PORT}/upload/${req.file.filename}`;
  res.status(200).json({ imageUrl });
});

// Criação de usuário
app.post('/users', async (req, res) => {
  const { nome, email, dataNascimento, senha, temFoto, profileImagePath } = req.body;

  console.log('Recebendo dados para criar usuário:', req.body);

  const heartcode = generateHeartCode();
  console.log('Heartcode gerado:', heartcode);

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

    const response = {
      id: result,
      nome,
      email,
      heartcode,
      profileImagePath
    };
    console.log('Resposta enviada:', response);
    res.status(201).json(response);
  } catch (err) {
    if (err.message.includes('UNIQUE constraint failed: users.email')) {
      return res.status(400).json({ error: 'Email já registrado' });
    }
    console.error('Erro ao criar usuário:', err);
    res.status(500).json({ error: 'Erro ao criar usuário' });
  }
});

// Validação de heartcode e criação de conexão
app.post('/validate-heartcode', async (req, res) => {
  const { userHeartCode, partnerHeartCode } = req.body;

  console.log('Recebendo dados para validar heartcode:', req.body);

  try {
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

    const codigoConexao = `CONN${Math.random().toString(36).substring(2, 10).toUpperCase()}`;
    console.log('Código de conexão gerado:', codigoConexao);

    await new Promise((resolve, reject) => {
      db.run(
        `INSERT INTO couples (idUsuario1, idUsuario2, codigoConexao) VALUES (?, ?, ?)`,
        [user.id, partner.id, codigoConexao],
        (err) => err ? reject(err) : resolve()
      );
    });

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
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Servidor rodando em http://0.0.0.0:${PORT}`);
});