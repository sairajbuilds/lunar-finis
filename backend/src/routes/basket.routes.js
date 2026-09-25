const express = require('express');

const authenticate = require('../middleware/auth');

const {
  getBasket,
  addFund,
  removeFund,
} = require('../controllers/basket.controller');

const router = express.Router();

router.get('/', authenticate, getBasket);
router.post('/', authenticate, addFund);
router.delete('/:fundId', authenticate, removeFund);

module.exports = router;