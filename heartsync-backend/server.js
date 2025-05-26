require('dotenv').config();
const express = require('express');
const multer = require('multer');
const cors = require('cors');
const path = require('path');
const sqlite3 = require('sqlite3').verbose();
const fs = require('fs');
const nodemailer = require('nodemailer');
const jwt = require('jsonwebtoken');

const app = express();
const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || '8Jkl6j6c6sae';

// Configuração do banco de dados SQLite
const db = new sqlite3.Database('./heartsync.db', (err) => {
  if (err) {
    console.error('Erro ao conectar ao banco de dados:', err.message);
  } else {
    console.log('Conectado ao banco de dados SQLite');
    db.run('PRAGMA foreign_keys = ON;', (pragmaErr) => {
      if (pragmaErr) {
        console.error('Erro ao habilitar chaves estrangeiras:', pragmaErr.message);
      } else {
        console.log('Chaves estrangeiras habilitadas');
      }
      initializeDatabase();
    });
  }
});

// Função para criar/substituir o trigger de updatedAt para a tabela users
function createOrReplaceUsersUpdatedAtTrigger(database) {
  const triggerName = 'trigger_users_updatedAt';
  database.serialize(() => {
    database.run(`DROP TRIGGER IF EXISTS ${triggerName};`, (dropErr) => {
      if (dropErr) {
        console.warn(`Nota: Falha ao tentar remover trigger ${triggerName} (pode não existir):`, dropErr.message);
      }
      database.run(
        `CREATE TRIGGER ${triggerName}
         AFTER UPDATE ON users
         FOR EACH ROW
         BEGIN
           UPDATE users SET updatedAt = strftime('%Y-%m-%d %H:%M:%S', 'now') WHERE id = OLD.id;
         END;`,
        (createErr) => {
          if (createErr) {
            console.error(`Erro ao criar/substituir trigger ${triggerName}:`, createErr.message);
          } else {
            console.log(`Trigger ${triggerName} criado/substituído com sucesso.`);
          }
        }
      );
    });
  });
}

function initializeDatabase() {
  db.serialize(() => {
    // Tabela USERS
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
        updatedAt TEXT
      )`,
      (err) => {
        if (err) {
          console.error('Erro ao criar tabela users:', err.message);
        } else {
          console.log('Tabela users criada ou já existe.');
          // Verificar se a coluna updatedAt existe
          db.all("PRAGMA table_info(users)", (pragmaErr, columns) => {
            if (pragmaErr) {
              console.error("Erro ao verificar schema da tabela users:", pragmaErr.message);
              return;
            }
            const updatedAtExists = columns.some(col => col.name === 'updatedAt');
            if (!updatedAtExists) {
              // Adicionar a coluna sem valor padrão dinâmico
              db.run("ALTER TABLE users ADD COLUMN updatedAt TEXT", (alterErr) => {
                if (alterErr) {
                  console.error("Erro ao adicionar coluna updatedAt à tabela users:", alterErr.message);
                  return;
                }
                console.log("Coluna updatedAt adicionada à tabela users.");
                // Preencher updatedAt para registros existentes
                db.run(
                  "UPDATE users SET updatedAt = strftime('%Y-%m-%d %H:%M:%S', 'now') WHERE updatedAt IS NULL",
                  (updateErr) => {
                    if (updateErr) {
                      console.error("Erro ao preencher valores de updatedAt:", updateErr.message);
                    } else {
                      console.log("Valores de updatedAt preenchidos para registros existentes.");
                      createOrReplaceUsersUpdatedAtTrigger(db);
                    }
                  }
                );
              });
            } else {
              createOrReplaceUsersUpdatedAtTrigger(db);
            }
          });
        }
      }
    );

    // Tabela COUPLES
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

    // Tabela VERIFICATION_CODES
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
  origin: ['http://localhost', 'http://10.0.2.2', 'http://localhost:8081', `http://${process.env.LOCAL_IP}`],
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
    db.run(
      `INSERT INTO users (nome, email, dataNascimento, senha, temFoto, profileImagePath, heartcode)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [nome, email, dataNascimento, senha, false, null, heartcode],
      function(err) {
        if (err) {
          if (err.message.includes('UNIQUE constraint failed: users.email')) {
            return res.status(400).json({ error: 'Email já registrado' });
          }
          console.error('Erro ao registrar usuário:', err);
          return res.status(500).json({ error: 'Erro ao registrar usuário' });
        }

        const userId = this.lastID;
        const token = jwt.sign({ id: userId, email }, JWT_SECRET, { expiresIn: '7d' });
        const response = {
          user: { _id: userId.toString(), nome, email, heartcode },
          token
        };
        console.log('Usuário registrado:', response);
        res.status(201).json(response);
      }
    );
  } catch (err) {
    console.error('Erro inesperado ao tentar registrar usuário:', err);
    res.status(500).json({ error: 'Erro inesperado ao registrar usuário' });
  }
});

app.post('/auth/login', (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'E-mail e senha são obrigatórios' });
  }

  db.get(
    `SELECT * FROM users WHERE email = ? AND senha = ?`,
    [email, password],
    (err, user) => {
      if (err) {
        console.error('Erro ao fazer login (db):', err);
        return res.status(500).json({ error: 'Erro ao fazer login' });
      }
      if (!user) {
        return res.status(401).json({ error: 'Credenciais inválidas' });
      }

      const token = jwt.sign({ id: user.id, email: user.email }, JWT_SECRET, { expiresIn: '7d' });
      res.status(200).json({
        user: { _id: user.id.toString(), nome: user.nome, email: user.email, heartcode: user.heartcode, profileImagePath: user.profileImagePath, temFoto: user.temFoto },
        token
      });
    }
  );
});

app.post('/send-verification-code', async (req, res) => {
  const { email } = req.body;
  if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    return res.status(400).json({ error: 'E-mail inválido' });
  }

  const verificationCode = Math.floor(100000 + Math.random() * 900000).toString().substring(0, 6);
  const expiresAt = new Date(Date.now() + 10 * 60 * 1000).toISOString();

  db.run(
    `INSERT INTO verification_codes (email, code, expiresAt) VALUES (?, ?, ?)`,
    [email, verificationCode, expiresAt],
    async (err) => {
      if (err) {
        console.error('Erro ao salvar código de verificação no DB:', err);
        return res.status(500).json({ error: 'Erro ao processar solicitação de código' });
      }
      try {
        const mailOptions = {
          from: process.env.EMAIL_USER,
          to: email,
          subject: 'Código de Verificação - HeartSync',
          text: `Seu código de verificação é: ${verificationCode}. Digite-o no aplicativo para continuar o registro. Validade: 10 minutos.`,
        };
        await transporter.sendMail(mailOptions);
        console.log(`Código ${verificationCode} enviado para ${email} às ${new Date().toLocaleString()}`);
        res.status(200).json({ message: 'Código de verificação enviado' });
      } catch (mailErr) {
        console.error('Erro ao enviar e-mail:', mailErr);
        res.status(500).json({ error: 'Erro ao enviar código de verificação' });
      }
    }
  );
});

app.post('/auth/verify-code', (req, res) => {
  const startTime = Date.now();
  console.log(`Verificação: Início da requisição às ${new Date().toLocaleString()}`);

  const { email, code } = req.body;
  if (!email || !code) {
    console.log(`Verificação: Falha - E-mail ou código ausente`);
    return res.status(400).json({ error: 'E-mail e código são obrigatórios' });
  }

  console.log(`Verificação: Recebida requisição para verificar código para e-mail: ${email}, código: ${code}`);

  db.get(
    `SELECT * FROM verification_codes WHERE email = ? AND code = ?`,
    [email, code],
    (err, result) => {
      if (err) {
        console.error('Erro ao verificar código (db):', err);
        return res.status(500).json({ error: 'Erro ao verificar código' });
      }

      if (!result) {
        console.log(`Verificação: Código inválido para e-mail: ${email}, código: ${code}`);
        return res.status(400).json({ error: 'Código inválido ou já utilizado' });
      }

      const expiresAt = new Date(result.expiresAt);
      if (expiresAt < new Date()) {
        console.log(`Verificação: Código expirado para e-mail: ${email}, código: ${code}, expiresAt: ${expiresAt}`);
        db.run(`DELETE FROM verification_codes WHERE email = ? AND code = ?`, [email, code], (delErr) => {
          if (delErr) console.error("Erro ao deletar código expirado:", delErr);
        });
        return res.status(400).json({ error: 'Código expirado' });
      }

      db.run(`DELETE FROM verification_codes WHERE email = ? AND code = ?`, [email, code], (deleteErr) => {
        if (deleteErr) {
          console.error('Erro ao deletar código após verificação bem-sucedida:', deleteErr);
        }
        console.log(`Verificação: Código verificado com sucesso para e-mail: ${email}, código: ${code}`);
        res.status(200).json({ message: 'Código verificado com sucesso' });
      });

      console.log(`Verificação: Fim da requisição. Tempo total: ${(Date.now() - startTime) / 1000} segundos`);
    }
  );
});

app.get('/users/me', authenticateJWT, (req, res) => {
  db.get(`SELECT id, nome, email, dataNascimento, temFoto, profileImagePath, heartcode, conectado, createdAt, updatedAt FROM users WHERE id = ?`, [req.user.id], (err, user) => {
    if (err) {
      console.error('Erro ao buscar perfil (db):', err);
      return res.status(500).json({ error: 'Erro ao buscar perfil' });
    }
    if (!user) {
      return res.status(404).json({ error: 'Usuário não encontrado' });
    }
    res.status(200).json({
      _id: user.id.toString(),
      nome: user.nome,
      email: user.email,
      dataNascimento: user.dataNascimento,
      temFoto: user.temFoto,
      profileImagePath: user.profileImagePath,
      heartcode: user.heartcode,
      conectado: user.conectado,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt
    });
  });
});

app.put('/users/:id', authenticateJWT, (req, res) => {
  const { id } = req.params;
  if (req.user.id !== parseInt(id, 10)) {
    return res.status(403).json({ error: 'Acesso não autorizado' });
  }
  const { nome, dataNascimento } = req.body;

  db.run(
    `UPDATE users SET nome = ?, dataNascimento = ? WHERE id = ?`,
    [nome, dataNascimento, id],
    function(err) {
      if (err) {
        console.error('Erro ao atualizar perfil (db):', err);
        return res.status(500).json({ error: 'Erro ao atualizar perfil' });
      }
      if (this.changes === 0) {
        return res.status(404).json({ error: 'Usuário não encontrado para atualização.' });
      }
      res.status(200).json({ message: 'Perfil atualizado com sucesso' });
    }
  );
});

app.post('/users/:id/avatar', authenticateJWT, upload.single('avatarFile'), (req, res) => {
  const startTime = Date.now();
  console.log(`Upload Foto: Início da requisição para user ${req.params.id} às ${new Date().toLocaleString()}`);

  const { id } = req.params;
  if (req.user.id !== parseInt(id, 10)) {
    console.log(`Upload Foto: Acesso não autorizado para user ${id}`);
    return res.status(403).json({ error: 'Acesso não autorizado' });
  }
  if (!req.file) {
    console.log(`Upload Foto: Nenhum arquivo enviado para user ${id}`);
    return res.status(400).json({ error: 'Nenhum arquivo enviado.' });
  }

  const serverBaseUrl = `${req.protocol}://${req.get('host')}`;
  const imageUrl = `${serverBaseUrl}/upload/${req.file.filename}`;

  db.run(
    `UPDATE users SET temFoto = ?, profileImagePath = ? WHERE id = ?`,
    [true, imageUrl, id],
    function(err) {
      if (err) {
        console.error(`Upload Foto: Erro ao atualizar foto de perfil (db):`, err);
        return res.status(500).json({ error: 'Erro ao atualizar foto de perfil' });
      }
      if (this.changes === 0) {
        console.log(`Upload Foto: Usuário ${id} não encontrado para atualizar foto`);
        return res.status(404).json({ error: 'Usuário não encontrado para atualizar foto.' });
      }
      console.log(`Upload Foto: Foto atualizada com sucesso para user ${id}`);
      res.status(200).json({ filePath: imageUrl });
      console.log(`Upload Foto: Fim da requisição. Tempo total: ${(Date.now() - startTime) / 1000} segundos`);
    }
  );
});

app.delete('/users/:id', authenticateJWT, (req, res) => {
  const { id } = req.params;
  if (req.user.id !== parseInt(id, 10)) {
    return res.status(403).json({ error: 'Acesso não autorizado' });
  }
  db.run(`DELETE FROM users WHERE id = ?`, [id], function(err) {
    if (err) {
      console.error('Erro ao deletar conta (db):', err);
      return res.status(500).json({ error: 'Erro ao deletar conta' });
    }
    if (this.changes === 0) {
      return res.status(404).json({ error: 'Usuário não encontrado para deletar.' });
    }
    res.status(200).json({ message: 'Conta deletada com sucesso' });
  });
});

app.post('/validate-heartcode', authenticateJWT, async (req, res) => {
  const { userHeartCode, partnerHeartCode } = req.body;

  if (!userHeartCode || !partnerHeartCode) {
    return res.status(400).json({ error: "Heartcodes do usuário e do parceiro são obrigatórios." });
  }
  if (userHeartCode === partnerHeartCode) {
    return res.status(400).json({ error: "Os heartcodes não podem ser iguais." });
  }

  try {
    const [user, partner] = await Promise.all([
      getUserByHeartCode(userHeartCode),
      getUserByHeartCode(partnerHeartCode)
    ]);

    if (!user) {
      return res.status(404).json({ error: `Usuário com heartcode ${userHeartCode} não encontrado.` });
    }
    if (!partner) {
      return res.status(404).json({ error: `Parceiro com heartcode ${partnerHeartCode} não encontrado.` });
    }

    if (user.id === partner.id) {
      return res.status(400).json({ error: "Não é possível conectar-se consigo mesmo." });
    }

    if (user.conectado) {
      return res.status(400).json({ error: `Usuário ${user.nome} já está conectado.` });
    }
    if (partner.conectado) {
      return res.status(400).json({ error: `Usuário ${partner.nome} já está conectado.` });
    }

    const codigoConexao = `CONN${Date.now().toString(36)}${Math.random().toString(36).substring(2, 7)}`.toUpperCase();

    db.serialize(() => {
      db.run('BEGIN TRANSACTION;');
      db.run(
        `INSERT INTO couples (idUsuario1, idUsuario2, codigoConexao) VALUES (?, ?, ?)`,
        [user.id, partner.id, codigoConexao],
        (err) => {
          if (err) {
            db.run('ROLLBACK;');
            console.error('Erro ao criar casal (db):', err);
            return res.status(500).json({ error: 'Erro ao criar conexão entre usuários.' });
          }

          const updateUser1Status = new Promise((resolve, reject) => {
            updateUserConnectionStatus(user.id, true).then(resolve).catch(reject);
          });
          const updateUser2Status = new Promise((resolve, reject) => {
            updateUserConnectionStatus(partner.id, true).then(resolve).catch(reject);
          });

          Promise.all([updateUser1Status, updateUser2Status])
            .then(() => {
              db.run('COMMIT;');
              res.status(200).json({
                message: `Conexão estabelecida entre ${user.nome} e ${partner.nome}!`,
                codigoConexao
              });
            })
            .catch(statusErr => {
              db.run('ROLLBACK;');
              console.error('Erro ao atualizar status de conexão dos usuários:', statusErr);
              return res.status(500).json({ error: 'Erro ao finalizar conexão.' });
            });
        }
      );
    });
  } catch (err) {
    console.error('Erro ao validar heartcode (geral):', err);
    res.status(500).json({ error: 'Erro ao validar heartcode' });
  }
});

app.post('/upload', authenticateJWT, upload.single('profile_image'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'Nenhum arquivo enviado.' });
  }
  const serverBaseUrl = `${req.protocol}://${req.get('host')}`;
  const imageUrl = `${serverBaseUrl}/upload/${req.file.filename}`;
  res.status(200).json({ imageUrl });
});

// Funções auxiliares
function generateHeartCode() {
  const numbers = Math.floor(100000 + Math.random() * 899999).toString();
  const letters = String.fromCharCode(65 + Math.floor(Math.random() * 26)) +
                  String.fromCharCode(65 + Math.floor(Math.random() * 26));
  const arr = (numbers + letters).split('');
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr.join('').substring(0, 8);
}

function getUserByHeartCode(heartcode) {
  return new Promise((resolve, reject) => {
    db.get(
      `SELECT * FROM users WHERE heartcode = ?`,
      [heartcode],
      (err, row) => {
        if (err) return reject(err);
        resolve(row);
      }
    );
  });
}

function updateUserConnectionStatus(userId, status) {
  return new Promise((resolve, reject) => {
    db.run(
      `UPDATE users SET conectado = ? WHERE id = ?`,
      [status ? 1 : 0, userId],
      function(err) {
        if (err) return reject(err);
        if (this.changes === 0) return reject(new Error(`Usuário com ID ${userId} não encontrado para atualizar status.`));
        resolve(this.changes);
      }
    );
  });
}

// Servir arquivos estáticos da pasta 'upload'
app.use('/upload', express.static(path.join(__dirname, uploadDir)));

// Middleware de erro global
app.use((err, req, res, next) => {
  console.error('Erro não tratado no servidor:', err.stack || err);
  res.status(err.status || 500).json({
    error: 'Falha inesperada no servidor. Tente novamente mais tarde.',
    details: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

// Iniciar servidor
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Servidor rodando em http://0.0.0.0:${PORT}`);
  if (process.env.LOCAL_IP) {
    console.log(`Também acessível em http://${process.env.LOCAL_IP}:${PORT}`);
  }
});