require('dotenv').config();
const express = require('express');
const multer = require('multer');
const cors = require('cors');
const path = require('path');
const sqlite3 = require('sqlite3').verbose();
const fs = require('fs');
const nodemailer = require('nodemailer');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt'); // Adicionado para hash de senhas
const validator = require('validator'); // Adicionado para validação de email

const app = express();
const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || '8Jkl6j6c6sae';
const SALT_ROUNDS = 10; // Para bcrypt

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
        createdAt TEXT DEFAULT (strftime('%Y-%m-%d %H:%M:%S', 'now')),
        streak INTEGER DEFAULT 0,
        lastStreakDate TEXT
      )`,
      (err) => {
        if (err) console.error('Erro ao criar tabela users:', err.message);
        else console.log('Tabela users criada ou já existe');
      }
    );

    db.run(
      `CREATE TABLE IF NOT EXISTS couples (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idUsuario1 INTEGER NOT NULL,
        idUsuario2 INTEGER NOT NULL,
        codigoConexao TEXT UNIQUE NOT NULL,
        createdAt TEXT DEFAULT (strftime('%Y-%m-%d %H:%M:%S', 'now')),
        FOREIGN KEY (idUsuario1) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (idUsuario2) REFERENCES users (id) ON DELETE CASCADE
      )`,
      (err) => {
        if (err) console.error('Erro ao criar tabela couples:', err.message);
        else console.log('Tabela couples criada ou já existe');
      }
    );

    db.run(
      `CREATE TABLE IF NOT EXISTS verification_codes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL,
        code TEXT NOT NULL,
        expiresAt TEXT NOT NULL
      )`,
      (err) => {
        if (err) console.error('Erro ao criar tabela verification_codes:', err.message);
        else console.log('Tabela verification_codes criada ou já existe');
      }
    );

    db.run(
      `CREATE TABLE IF NOT EXISTS roleta (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idUsuario INTEGER NOT NULL,
        dataRoleta TEXT NOT NULL,
        atividade TEXT NOT NULL,
        blockTime TEXT NOT NULL,
        proximaRoleta TEXT NOT NULL,
        FOREIGN KEY (idUsuario) REFERENCES users (id) ON DELETE CASCADE
      )`,
      (err) => {
        if (err) console.error('Erro ao criar tabela roleta:', err.message);
        else console.log('Tabela roleta criada ou já existe');
      }
    );

    // Migração para adicionar streak e lastStreakDate
    db.run(
      `ALTER TABLE users ADD COLUMN streak INTEGER DEFAULT 0`,
      (err) => {
        if (err && !err.message.includes('duplicate column')) {
          console.error('Erro ao adicionar coluna streak:', err.message);
        }
      }
    );
    db.run(
      `ALTER TABLE users ADD COLUMN lastStreakDate TEXT`,
      (err) => {
        if (err && !err.message.includes('duplicate column')) {
          console.error('Erro ao adicionar coluna lastStreakDate:', err.message);
        }
      }
    );
  });
}

// Configuração do transporte de e-mail
const transporter = nodemailer.createTransport({
  service: process.env.EMAIL_SERVICE || 'gmail',
  host: 'smtp.gmail.com',
  port: 587,
  secure: false,
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

// Configurações do Express
app.use(
  cors({
    origin: [
      'http://localhost',
      'http://localhost:8081',
      'http://10.0.2.2:3000',
      'http://192.168.0.29:3000', // Adicionado para suportar conexões do Flutter
    ],
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  })
);
app.use(express.json());

// Configuração do Multer para uploads
const uploadDir = 'upload';
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir);
}
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadDir),
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    const ext = path.extname(file.originalname);
    cb(null, `${file.fieldname}-${uniqueSuffix}${ext}`);
  },
});
const upload = multer({ storage });

// Middleware de autenticação JWT
const authenticateJWT = (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Token não fornecido ou inválido' });
  }
  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded;
    next();
  } catch (err) {
    console.error('Erro ao verificar JWT:', err.message, err.stack);
    return res.status(403).json({ error: 'Token inválido ou expirado' });
  }
};

// Rotas
app.post('/auth/register', async (req, res) => {
  const { nome, email, dataNascimento, senha } = req.body;
  if (!nome || !email || !dataNascimento || !senha) {
    return res.status(400).json({ error: 'Todos os campos são obrigatórios' });
  }
  if (!validator.isEmail(email)) {
    return res.status(400).json({ error: 'E-mail inválido' });
  }
  if (senha.length < 6) {
    return res.status(400).json({ error: 'A senha deve ter pelo menos 6 caracteres' });
  }

  try {
    const hashedPassword = await bcrypt.hash(senha, SALT_ROUNDS);
    const heartcode = generateHeartCode();
    const result = await new Promise((resolve, reject) => {
      db.run(
        `INSERT INTO users (nome, email, dataNascimento, senha, temFoto, profileImagePath, heartcode, streak, lastStreakDate)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [nome, email, dataNascimento, hashedPassword, false, null, heartcode, 0, null],
        function (err) {
          if (err) reject(err);
          else resolve(this.lastID);
        }
      );
    });

    const token = jwt.sign({ id: result, email }, JWT_SECRET, { expiresIn: '7d' });
    const response = {
      user: { _id: result, nome, email, heartcode, streak: 0 },
      token,
    };
    console.log('Usuário registrado:', response);
    res.status(201).json(response);
  } catch (err) {
    if (err.message.includes('UNIQUE constraint failed: users.email')) {
      return res.status(400).json({ error: 'Email já registrado' });
    }
    console.error('Erro ao registrar usuário:', err.message, err.stack);
    res.status(500).json({ error: 'Erro ao registrar usuário' });
  }
});

app.post('/auth/login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'E-mail e senha são obrigatórios' });
  }
  if (!validator.isEmail(email)) {
    return res.status(400).json({ error: 'E-mail inválido' });
  }

  try {
    const user = await new Promise((resolve, reject) => {
      db.get(`SELECT * FROM users WHERE email = ?`, [email], (err, row) =>
        err ? reject(err) : resolve(row)
      );
    });

    if (!user) {
      return res.status(401).json({ error: 'Credenciais inválidas' });
    }

    const isPasswordValid = await bcrypt.compare(password, user.senha);
    if (!isPasswordValid) {
      return res.status(401).json({ error: 'Credenciais inválidas' });
    }

    const token = jwt.sign({ id: user.id, email: user.email }, JWT_SECRET, { expiresIn: '7d' });
    res.status(200).json({
      user: {
        _id: user.id,
        nome: user.nome,
        email: user.email,
        heartcode: user.heartcode,
        streak: user.streak || 0,
        lastStreakDate: user.lastStreakDate,
      },
      token,
    });
  } catch (err) {
    console.error('Erro ao fazer login:', err.message, err.stack);
    res.status(500).json({ error: 'Erro ao fazer login' });
  }
});

app.post('/send-verification-code', async (req, res) => {
  const { email } = req.body;
  if (!email || !validator.isEmail(email)) {
    return res.status(400).json({ error: 'E-mail inválido' });
  }

  const verificationCode = Math.floor(100000 + Math.random() * 900000)
    .toString()
    .padStart(6, '0');
  const expiresAt = new Date(Date.now() + 10 * 60 * 1000).toISOString();

  try {
    await new Promise((resolve, reject) => {
      db.run(
        `INSERT INTO verification_codes (email, code, expiresAt) VALUES (?, ?, ?)`,
        [email, verificationCode, expiresAt],
        (err) => (err ? reject(err) : resolve())
      );
    });

    const mailOptions = {
      from: process.env.EMAIL_USER,
      to: email,
      subject: 'Código de Verificação - HeartSync',
      text: `Seu código de verificação é: ${verificationCode}. Digite-o no aplicativo para continuar o registro.`,
    };

    await transporter.sendMail(mailOptions);
    console.log(`Código ${verificationCode} enviado para ${email}`);
    res.status(200).json({ message: 'Success' });
  } catch (err) {
    console.error('Erro ao enviar código:', err.message, err.stack);
    res.status(500).json({ error: 'Failed to send verification code' });
  }
});

app.post('/auth/verify-code', async (req, res) => {
  const { email, code } = req.body;
  if (!email || !code || !validator.isEmail(email)) {
    return res.status(400).json({ error: 'E-mail e código são obrigatórios e devem ser válidos' });
  }

  try {
    const result = await new Promise((resolve, reject) => {
      db.get(
        `SELECT * FROM verification_codes WHERE email = ? AND code = ?`,
        [email, code],
        (err, row) => (err ? reject(err) : resolve(row))
      );
    });

    if (!result) {
      return res.status(400).json({ error: 'Código inválido' });
    }

    const expiresAt = new Date(result.expiresAt);
    if (expiresAt < new Date()) {
      return res.status(400).json({ error: 'Código expirado' });
    }

    await new Promise((resolve, reject) => {
      db.run(
        `DELETE FROM verification_codes WHERE email = ? AND code = ?`,
        [email, code],
        (err) => (err ? reject(err) : resolve())
      );
    });

    res.status(200).json({ message: 'Código verificado com sucesso' });
  } catch (err) {
    console.error('Erro ao verificar código:', err.message, err.stack);
    res.status(500).json({ error: 'Erro ao verificar código' });
  }
});

app.post('/roulette/save', authenticateJWT, async (req, res) => {
  const { userId, dataRoleta, atividade, blockTime, proximaRoleta } = req.body;
  if (!userId || !dataRoleta || !atividade || !blockTime || !proximaRoleta) {
    return res.status(400).json({ error: 'Todos os campos são obrigatórios' });
  }
  if (req.user.id != userId) {
    return res.status(403).json({ error: 'Acesso não autorizado' });
  }

  try {
    const result = await new Promise((resolve, reject) => {
      db.run(
        `INSERT INTO roleta (idUsuario, dataRoleta, atividade, blockTime, proximaRoleta)
         VALUES (?, ?, ?, ?, ?)`,
        [userId, dataRoleta, atividade, blockTime, proximaRoleta],
        function (err) {
          if (err) reject(err);
          else resolve(this.lastID);
        }
      );
    });
    res.status(201).json({ id: result, message: 'Atividade da roleta salva com sucesso' });
  } catch (err) {
    console.error('Erro ao salvar atividade da roleta:', err.message, err.stack);
    res.status(500).json({ error: 'Erro ao salvar atividade da roleta' });
  }
});

app.post('/roulette/update-streak', authenticateJWT, async (req, res) => {
  const { userId, streak, lastStreakDate } = req.body;
  if (!userId || streak == null) {
    return res.status(400).json({ error: 'userId e streak são obrigatórios' });
  }
  if (req.user.id != userId) {
    return res.status(403).json({ error: 'Acesso não autorizado' });
  }

  try {
    await new Promise((resolve, reject) => {
      db.run(
        `UPDATE users SET streak = ?, lastStreakDate = ? WHERE id = ?`,
        [streak, lastStreakDate, userId],
        function (err) {
          if (err) reject(err);
          else resolve();
        }
      );
    });
    res.status(200).json({ message: 'Sequência atualizada com sucesso', streak, lastStreakDate });
  } catch (err) {
    console.error('Erro ao atualizar sequência:', err.message, err.stack);
    res.status(500).json({ error: 'Erro ao atualizar sequência' });
  }
});

app.get('/roulette/streak/:userId', authenticateJWT, async (req, res) => {
  const { userId } = req.params;
  if (req.user.id != userId) {
    return res.status(403).json({ error: 'Acesso não autorizado' });
  }
  try {
    const result = await new Promise((resolve, reject) => {
      db.get(
        `SELECT streak, lastStreakDate FROM users WHERE id = ?`,
        [userId],
        (err, row) => (err ? reject(err) : resolve(row))
      );
    });
    if (!result) {
      return res.status(404).json({ error: 'Usuário não encontrado' });
    }
    res.status(200).json({ streak: result.streak || 0, lastStreakDate: result.lastStreakDate });
  } catch (err) {
    console.error('Erro ao recuperar sequência:', err.message, err.stack);
    res.status(500).json({ error: 'Erro ao recuperar sequência' });
  }
});

app.post('/roulette/reset-streak', authenticateJWT, async (req, res) => {
  const { userId } = req.body;
  if (!userId) {
    return res.status(400).json({ error: 'userId é obrigatório' });
  }
  if (req.user.id != userId) {
    return res.status(403).json({ error: 'Acesso não autorizado' });
  }

  try {
    await new Promise((resolve, reject) => {
      db.run(
        `UPDATE users SET streak = 0, lastStreakDate = NULL WHERE id = ?`,
        [userId],
        function (err) {
          if (err) reject(err);
          else resolve();
        }
      );
    });
    res.status(200).json({ message: 'Sequência resetada com sucesso' });
  } catch (err) {
    console.error('Erro ao resetar sequência:', err.message, err.stack);
    res.status(500).json({ error: 'Erro ao resetar sequência' });
  }
});

app.get('/users/me', authenticateJWT, async (req, res) => {
  try {
    const user = await new Promise((resolve, reject) => {
      db.get(`SELECT * FROM users WHERE id = ?`, [req.user.id], (err, row) =>
        err ? reject(err) : resolve(row)
      );
    });
    if (!user) {
      return res.status(404).json({ error: 'Usuário não encontrado' });
    }
    res.status(200).json({
      _id: user.id,
      nome: user.nome,
      email: user.email,
      dataNascimento: user.dataNascimento,
      temFoto: user.temFoto,
      profileImagePath: user.profileImagePath,
      heartcode: user.heartcode,
      conectado: user.conectado,
      streak: user.streak || 0,
      lastStreakDate: user.lastStreakDate,
    });
  } catch (err) {
    console.error('Erro ao buscar perfil:', err.message, err.stack);
    res.status(500).json({ error: 'Erro ao buscar perfil' });
  }
});

app.put('/users/:id', authenticateJWT, async (req, res) => {
  const { id } = req.params;
  if (req.user.id != id) {
    return res.status(403).json({ error: 'Acesso não autorizado' });
  }
  const { nome, dataNascimento } = req.body;
  try {
    await new Promise((resolve, reject) => {
      db.run(
        `UPDATE users SET nome = ?, dataNascimento = ? WHERE id = ?`,
        [nome, dataNascimento, id],
        (err) => (err ? reject(err) : resolve())
      );
    });
    res.status(200).json({ message: 'Perfil atualizado com sucesso' });
  } catch (err) {
    console.error('Erro ao atualizar perfil:', err.message, err.stack);
    res.status(500).json({ error: 'Erro ao atualizar perfil' });
  }
});

app.post('/users/:id/avatar', authenticateJWT, upload.single('avatarFile'), async (req, res) => {
  const { id } = req.params;
  if (req.user.id != id) {
    return res.status(403).json({ error: 'Acesso não autorizado' });
  }
  if (!req.file) {
    return res.status(400).json({ error: 'Nenhum arquivo enviado.' });
  }
  const imageUrl = `http://192.168.0.29:${PORT}/upload/${req.file.filename}`;
  try {
    await new Promise((resolve, reject) => {
      db.run(
        `UPDATE users SET temFoto = ?, profileImagePath = ? WHERE id = ?`,
        [true, imageUrl, id],
        (err) => (err ? reject(err) : resolve())
      );
    });
    res.status(200).json({ filePath: imageUrl });
  } catch (err) {
    console.error('Erro ao atualizar foto:', err.message, err.stack);
    res.status(500).json({ error: 'Erro ao atualizar foto' });
  }
});

app.delete('/users/:id', authenticateJWT, async (req, res) => {
  const { id } = req.params;
  if (req.user.id != id) {
    return res.status(403).json({ error: 'Acesso não autorizado' });
  }
  try {
    await new Promise((resolve, reject) => {
      db.run(`DELETE FROM users WHERE id = ?`, [id], (err) => (err ? reject(err) : resolve()));
    });
    res.status(200).json({ message: 'Conta deletada com sucesso' });
  } catch (err) {
    console.error('Erro ao deletar conta:', err.message, err.stack);
    res.status(500).json({ error: 'Erro ao deletar conta' });
  }
});

app.post('/validate-heartcode', authenticateJWT, async (req, res) => {
  const { userHeartCode, partnerHeartCode } = req.body;
  try {
    const [user, partner] = await Promise.all([
      getUserByHeartCode(userHeartCode),
      getUserByHeartCode(partnerHeartCode),
    ]);
    if (!user || !partner) {
      return res.status(404).json({ error: 'Usuário ou parceiro não encontrado' });
    }
    if (user.conectado || partner.conectado) {
      return res.status(400).json({ error: 'Um dos usuários já está conectado' });
    }
    const code = `CONN${Math.random().toString(36).substring(2, 10).toUpperCase()}`;
    await new Promise((resolve, reject) => {
      db.run(
        `INSERT INTO couples (idUsuario1, idUsuario2, codigoConexao) VALUES (?, ?, ?)`,
        [user.id, partner.id, code],
        (err) => (err ? reject(err) : resolve())
      );
    });
    await Promise.all([
      updateUserConnectionStatus(user.id, true),
      updateUserConnectionStatus(partner.id, true),
    ]);
    res.status(200).json({ code });
  } catch (err) {
    console.error('Erro ao validar heartcode:', err.message, err.stack);
    res.status(500).json({ error: 'Erro ao validar heartcode' });
  }
});

app.post('/upload', upload.single('profile_image'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'Nenhum arquivo enviado.' });
  }
  const imageUrl = `http://192.168.0.29:${PORT}/upload/${req.file.filename}`;
  res.status(200).json({ imageUrl });
});

// Funções auxiliares
function generateHeartCode() {
  const numbers = Math.floor(1000000 + Math.random() * 9000000)
    .toString()
    .padStart(7, '0');
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
      (err, row) => (err ? reject(err) : resolve(row))
    );
  });
}

function updateUserConnectionStatus(userId, status) {
  return new Promise((resolve, reject) => {
    db.run(
      `UPDATE users SET conectado = ? WHERE id = ?`,
      [status, userId],
      (err) => (err ? reject(err) : resolve())
    );
  });
}

// Servir arquivos estáticos
app.use('/upload', express.static(path.join(__dirname, uploadDir)));

// Middleware de erro
app.use((err, req, res, next) => {
  console.error('Erro no servidor:', err.message, err.stack);
  res.status(500).json({
    error: 'Falha no servidor. Tente novamente mais tarde.',
    details: process.env.NODE_ENV === 'development' ? err.message : undefined,
  });
});

// Iniciar servidor
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Servidor rodando em http://0.0.0.0:${PORT}`);
});