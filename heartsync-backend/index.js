const express = require('express');
const multer = require('multer');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = 3000;

// Habilitar CORS para permitir chamadas do Flutter
app.use(cors());

// Configurar o Multer
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'upload'); // pasta já existente
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname);
    cb(null, `${file.fieldname}-${uniqueSuffix}${ext}`);
  }
});

const upload = multer({ storage });

// Rota para upload
app.post('/upload', upload.single('profile_image'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'Nenhum arquivo enviado.' });
  }

  const imageUrl = `http://localhost:${PORT}/upload/${req.file.filename}`;
  console.log('Imagem recebida:', imageUrl);

  res.status(200).json({ imageUrl });
});

// Servir a pasta de uploads estaticamente
app.use('/upload', express.static(path.join(__dirname, 'upload')));

// Iniciar o servidor
app.listen(PORT, () => {
  console.log(`Servidor rodando em http://localhost:${PORT}`);
});
