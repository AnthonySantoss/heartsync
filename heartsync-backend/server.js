require('dotenv').config();
const express = require('express');
const multer = require('multer');
const cors = require('cors');
const path = require('path');
const sqlite3 = require('sqlite3').verbose();
const fs = require('fs');
const nodemailer = require('nodemailer');

const app = express();
const PORT = process.env.PORT || 3000;

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
    db.run(
      `CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        dataNascimento TEXT NOT NULL,
        senha TEXT NOT NULL,
        temFoto BOOLEAN DEFAULT FALSE,
        profileImagePath TEXT,
        createdAt TEXT DEFAULT (strftime('%Y-%m-%d %H:%M:%S', 'now'))
      )`,
      (err) => {
        if (err) console.error('Erro ao criar tabela users:', err.message);
        else console.log('Tabela users criada ou já existe');
      }
    );
  });
}

// Configuração do transporte de e-mail (usando variáveis de ambiente)
const transporter = nodemailer.createTransport({
  service: process.env.EMAIL_SERVICE || 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

// Configurações do Express
app.use(cors({
  origin: ['http://localhost', 'http://10.0.2.2', 'http://localhost:8081'],
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

  console.log('Recebendo dados para criar usuário:', req.body);

  try {
    const result = await new Promise((resolve, reject) => {
      db.run(
        `INSERT INTO users (nome, email, dataNascimento, senha, temFoto, profileImagePath)
         VALUES (?, ?, ?, ?, ?, ?)`,
        [nome, email, dataNascimento, senha, temFoto, profileImagePath],
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

app.post('/send-verification-code', async (req, res) => {
  const { email } = req.body;

  if (!email) {
    return res.status(400).json({ error: 'Email é obrigatório' });
  }

  // Gerar código de verificação de 6 dígitos
  const verificationCode = Math.floor(100000 + Math.random() * 900000).toString().substring(0, 6);

  // Configurar e enviar e-mail
  const mailOptions = {
    from: process.env.EMAIL_USER,
    to: email,
    subject: 'Código de Verificação - HeartSync',
    text: `Seu código de verificação é: ${verificationCode}. Digite-o no aplicativo para continuar o registro. Validade: 10 minutos.`,
  };

  try {
    await transporter.sendMail(mailOptions);
    console.log(`Código ${verificationCode} enviado para ${email} às ${new Date().toLocaleString()}`);
    res.status(200).json({ verificationCode });
  } catch (err) {
    console.error('Erro ao enviar e-mail:', err);
    res.status(500).json({ error: 'Erro ao enviar código de verificação' });
  }
});

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