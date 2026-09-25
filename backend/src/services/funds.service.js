const funds = require('../data/funds');

function getAllFunds() {
  return funds;
}

function getFundById(fundId) {
  return funds.find((fund) => fund.id === fundId);
}

module.exports = {
  getAllFunds,
  getFundById,
};