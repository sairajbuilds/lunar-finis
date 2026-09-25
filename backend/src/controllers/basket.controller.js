const basketService = require('../services/basket.service');

async function getBasket(req, res) {
  try {
    const funds = await basketService.getBasket(req.user.uid);

    return res.status(200).json({
      funds,
    });
  } catch (error) {
    console.error(error);

    return res.status(500).json({
      message: 'Failed to load basket',
    });
  }
}

async function addFund(req, res) {
  try {
    const { fundId } = req.body;

    if (!fundId) {
      return res.status(400).json({
        message: 'fundId is required',
      });
    }

    await basketService.addFund(req.user.uid, fundId);

    return res.status(201).json({
      message: 'Fund added to basket',
      fundId,
    });
  } catch (error) {
    console.error(error);

    return res.status(error.statusCode || 500).json({
      message: error.message || 'Failed to add fund to basket',
    });
  }
}

async function removeFund(req, res) {
  try {
    const { fundId } = req.params;

    await basketService.removeFund(req.user.uid, fundId);

    return res.status(204).send();
  } catch (error) {
    console.error(error);

    return res.status(error.statusCode || 500).json({
      message: error.message || 'Failed to remove fund from basket',
    });
  }
}

module.exports = {
  getBasket,
  addFund,
  removeFund,
};