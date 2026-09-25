const fundsService = require('../services/funds.service');

function getFunds(req, res) {
  const funds = fundsService.getAllFunds();

  return res.status(200).json({
    funds,
  });
}

module.exports = {
  getFunds,
};