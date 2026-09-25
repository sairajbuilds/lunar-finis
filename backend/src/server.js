require('dotenv').config();

const express = require('express');
const cors = require('cors');

const fundsRoutes = require('./routes/funds.routes');
const basketRoutes = require('./routes/basket.routes');

const app = express();

app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'ok',
  });
});

app.use('/funds', fundsRoutes);
app.use('/basket', basketRoutes);

const PORT = process.env.PORT || 3000;

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});