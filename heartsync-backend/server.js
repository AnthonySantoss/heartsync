require('dotenv').config();
const express = require('express');
const multer = require('multer');
const cors = require('cors');
const path = require('path');
const sqlite3 = require('sqlite3').verbose();
const fs = require('fs');
const nodemailer = require('nodemailer');
const jwt = require('jsonwebtoken'); // Adicionado

const app = express();
const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || '8Jkl6j6c6sae';

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
        createdAt TEXT DEFAULT (strftime('%Y-%m-%d %H:%M:%S', 'now'))
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
  });
}

// Configuração do transporte de e-mail
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
    console.error('Erro ao verificar JWT:', err.message);
    return res.status(403).json({ error: 'Token inválido ou expirado' });
  }
};

// Rotas
app.post('/auth/register', async (req, res) => {
  const { nome, email, dataNascimento, senha } = req.body;
  if (!nome || !email || !dataNascimento || !senha) {
    return res.status(400).json({ error: 'Todos os campos são obrigatórios' });
  }
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    return res.status(400).json({ error: 'E-mail inválido' });
  }
  if (senha.length < 6) {
    return res.status(400).json({ error: 'A senha deve ter pelo menos 6 caracteres' });
  }

  const heartcode = generateHeartCode();
  try {
    const result = await new Promise((resolve, reject) => {
      db.run(
        `INSERT INTO users (nome, email, dataNascimento, senha, temFoto, profileImagePath, heartcode)
         VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [nome, email, dataNascimento, senha, false, null, heartcode],
        function(err) {
          if (err) reject(err);
          else resolve(this.lastID);
        }
      );
    });

    const token = jwt.sign({ id: result, email }, JWT_SECRET, { expiresIn: '7d' });
    const response = {
      user: { _id: result, nome, email, heartcode },
      token
    };
    console.log('Usuário registrado:', response);
    res.status(201).json(response);
  } catch (err) {
    if (err.message.includes('UNIQUE constraint failed: users.email')) {
      return res.status(400).json({ error: 'Email já registrado' });
    }
    console.error('Erro ao registrar usuário:', err);
    res.status(500).json({ error: 'Erro ao registrar usuário' });
  }
});

// Novo endpoint para salvar atividade da roleta
app.post('/roulette/save', async (req, res) => {
  const { userId, dataRoleta, atividade, blockTime, proximaRoleta } = req.body;
  if (!userId || !dataRoleta || !atividade || !blockTime || !proximaRoleta) {
    return res.status(400).json({ error: 'Todos os campos são obrigatórios' });
  }

  try {
    const result = await new Promise((resolve, reject) => {
      db.run(
        `INSERT INTO roleta (idUsuario, dataRoleta, atividade, blockTime, proximaRoleta)
         VALUES (?, ?, ?, ?, ?)`,
        [userId, dataRoleta, atividade, blockTime, proximaRoleta],
        function(err) {
          if (err) reject(err);
          else resolve(this.lastID);
        }
      );
    });
    res.status(201).json({ id: result, message: 'Atividade da roleta salva com sucesso' });
  } catch (err) {
    console.error('Erro ao salvar atividade da roleta:', err);
    res.status(500).json({ error: 'Erro ao salvar atividade da roleta' });
  }
});

// Novo endpoint para atualizar a sequência (streak)
app.post('/roulette/update-streak', async (req, res) => {
  const { userId, streak } = req.body;
  if (!userId || streak == null) {
    return res.status(400).json({ error: 'userId e streak são obrigatórios' });
  }

  try {
    await new Promise((resolve, reject) => {
      db.run(
        `UPDATE users SET streak = ? WHERE id = ?`,
        [streak, userId],
        function(err) {
          if (err) reject(err);
          else resolve();
        }
      );
    });
    res.status(200).json({ message: 'Sequência atualizada com sucesso' });
  } catch (err) {
    console.error('Erro ao atualizar sequência:', err);
    res.status(500).json({ error: 'Erro ao atualizar sequência' });
  }
});

// Novo endpoint para recuperar a sequência atual
app.get('/roulette/streak/:userId', async (req, res) => {
  const { userId } = req.params;
  try {
    const result = await new Promise((resolve, reject) => {
      db.get(
        `SELECT streak FROM users WHERE id = ?`,
        [userId],
        (err, row) => {
          if (err) reject(err);
          else resolve(row);
        }
      );
    });
    if (!result) {
      return res.status(404).json({ error: 'Usuário não encontrado' });
    }
    res.status(200).json({ streak: result.streak || 0 });
  } catch (err) {
    console.error('Erro ao recuperar sequência:', err);
    res.status(500).json({ error: 'Erro ao recuperar sequência' });
  }
});

app.post('/auth/login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'E-mail e senha são obrigatórios' });
  }

  try {
    const user = await new Promise((resolve, reject) => {
      db.get(
        `SELECT * FROM users WHERE email = ? AND senha = ?`,
        [email, password],
        (err, row) => err ? reject(err) : resolve(row)
      );
    });

    if (!user) {
      return res.status(401).json({ error: 'Credenciais inválidas' });
    }

    const token = jwt.sign({ id: user.id, email: user.email }, JWT_SECRET, { expiresIn: '7d' });
    res.status(200).json({
      user: { _id: user.id, nome: user.nome, email: user.email, heartcode: user.heartcode },
      token
    });
  } catch (err) {
    console.error('Erro ao fazer login:', err);
    res.status(500).json({ error: 'Erro ao fazer login' });
  }
});

app.post('/send-verification-code', async (req, res) => {
  const { email } = req.body;
  if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    return res.status(400).json({ error: 'E-mail inválido' });
  }

  const verificationCode = Math.floor(100000 + Math.random() * 900000).toString().substring(0, 6);
  const expiresAt = new Date(Date.now() + 10 * 60 * 1000).toISOString(); // Expira em 10 minutos

  try {
    await new Promise((resolve, reject) => {
      db.run(
        `INSERT INTO verification_codes (email, code, expiresAt) VALUES (?, ?, ?)`,
        [email, verificationCode, expiresAt],
        (err) => err ? reject(err) : resolve()
      );
    });

    const mailOptions = {
      from: process.env.EMAIL_USER,
      to: email,
      subject: 'Código de Verificação - HeartSync',
      text: `Seu código de verificação é: ${verificationCode}. Digite-o no aplicativo para continuar o registro. Validade: 10 minutos.`,
    };

    await transporter.sendMail(mailOptions);
    console.log(`Código ${verificationCode} enviado para ${email} às ${new Date().toLocaleString()}`);
    res.status(200).json({ message: 'Código de verificação enviado' });
  } catch (err) {
    console.error('Erro ao enviar e-mail:', err);
    res.status(500).json({ error: 'Erro ao enviar código de verificação' });
  }
});

app.post('/auth/verify-code', async (req, res) => {
  const { email, code } = req.body;
  if (!email || !code) {
    return res.status(400).json({ error: 'E-mail e código são obrigatórios' });
  }

  console.log(`Verificação: Recebida requisição para verificar código para e-mail: ${email}, código: ${code}`);

  try {
    // Log para verificar o conteúdo da tabela
    const allCodes = await new Promise((resolve, reject) => {
      db.all(`SELECT * FROM verification_codes WHERE email = ?`, [email], (err, rows) => {
        err ? reject(err) : resolve(rows);
      });
    });
    console.log(`Verificação: Códigos armazenados para ${email}:`, allCodes);

    const result = await new Promise((resolve, reject) => {
      db.get(
        `SELECT * FROM verification_codes WHERE email = ? AND code = ?`,
        [email, code],
        (err, row) => err ? reject(err) : resolve(row)
      );
    });

    if (!result) {
      console.log(`Verificação: Código inválido para e-mail: ${email}, código: ${code}`);
      return res.status(400).json({ error: 'Código inválido' });
    }

    const expiresAt = new Date(result.expiresAt);
    if (expiresAt < new Date()) {
      console.log(`Verificação: Código expirado para e-mail: ${email}, código: ${code}, expiresAt: ${expiresAt}`);
      return res.status(400).json({ error: 'Código expirado' });
    }

    // Remover o código após a validação
    await new Promise((resolve, reject) => {
      db.run(`DELETE FROM verification_codes WHERE email = ? AND code = ?`, [email, code], (err) => err ? reject(err) : resolve());
    });

    console.log(`Verificação: Código verificado com sucesso para e-mail: ${email}, código: ${code}`);
    res.status(200).json({ message: 'Código verificado com sucesso' });
  } catch (err) {
    console.error('Erro ao verificar código:', err);
    res.status(500).json({ error: 'Erro ao verificar código' });
  }
});

app.get('/users/me', authenticateJWT, async (req, res) => {
  try {
    const user = await new Promise((resolve, reject) => {
      db.get(`SELECT * FROM users WHERE id = ?`, [req.user.id], (err, row) => err ? reject(err) : resolve(row));
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
      conectado: user.conectado
    });
  } catch (err) {
    console.error('Erro ao buscar perfil:', err);
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
        (err) => err ? reject(err) : resolve()
      );
    });
    res.status(200).json({ message: 'Perfil atualizado com sucesso' });
  } catch (err) {
    console.error('Erro ao atualizar perfil:', err);
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
  const imageUrl = `http://10.0.2.2:${PORT}/upload/${req.file.filename}`;
  try {
    await new Promise((resolve, reject) => {
      db.run(
        `UPDATE users SET temFoto = ?, profileImagePath = ? WHERE id = ?`,
        [true, imageUrl, id],
        (err) => err ? reject(err) : resolve()
      );
    });
    res.status(200).json({ filePath: imageUrl });
  } catch (err) {
    console.error('Erro ao atualizar foto de perfil:', err);
    res.status(500).json({ error: 'Erro ao atualizar foto de perfil' });
  }
});

app.delete('/users/:id', authenticateJWT, async (req, res) => {
  const { id } = req.params;
  if (req.user.id != id) {
    return res.status(403).json({ error: 'Acesso não autorizado' });
  }
  try {
    await new Promise((resolve, reject) => {
      db.run(`DELETE FROM users WHERE id = ?`, [id], (err) => err ? reject(err) : resolve());
    });
    res.status(200).json({ message: 'Conta deletada com sucesso' });
  } catch (err) {
    console.error('Erro ao deletar conta:', err);
    res.status(500).json({ error: 'Erro ao deletar conta' });
  }
});

app.post('/validate-heartcode', authenticateJWT, async (req, res) => {
  const { userHeartCode, partnerHeartCode } = req.body;
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

app.post('/upload', upload.single('profile_image'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'Nenhum arquivo enviado.' });
  }
  const imageUrl = `http://10.0.2.2:${PORT}/upload/${req.file.filename}`;
  res.status(200).json({ imageUrl });
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