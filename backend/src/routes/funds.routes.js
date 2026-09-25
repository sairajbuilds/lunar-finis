const express = require('express');
const { getFunds } = require('../controllers/funds.controller');

const router = express.Router();

router.get('/', getFunds);

module.exports = router;