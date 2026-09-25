const fundsService = require('../services/funds.service');

async function getFunds(req, res) {
  try {
    const funds = await fundsService.getAllFunds();

    return res.status(200).json({
      funds,
    });
  } catch (error) {
    console.error(error);

    return res.status(500).json({
      message: 'Failed to load funds',
    });
  }
}

module.exports = {
  getFunds,
};