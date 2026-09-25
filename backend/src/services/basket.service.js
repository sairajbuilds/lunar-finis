const { db } = require('../config/firebase');
const fundsService = require('./funds.service');

const basketsCollection = db.collection('baskets');

async function addFund(userId, fundId) {
  const fund = await fundsService.getFundById(fundId);

  if (!fund) {
    const error = new Error('Fund not found');
    error.statusCode = 404;
    throw error;
  }

  const itemRef = basketsCollection
    .doc(userId)
    .collection('items')
    .doc(fundId);

  const existingItem = await itemRef.get();

  if (existingItem.exists) {
    const error = new Error('Fund is already in your basket');
    error.statusCode = 409;
    throw error;
  }

  await itemRef.set({
    fundId,
    addedAt: new Date().toISOString(),
  });
}

async function getBasket(userId) {
  const snapshot = await basketsCollection
    .doc(userId)
    .collection('items')
    .get();

  const items = snapshot.docs.map((doc) => doc.data());

  const funds = await Promise.all(
    items.map((item) => fundsService.getFundById(item.fundId)),
  );

  return funds.filter(Boolean);
}

async function removeFund(userId, fundId) {
  const itemRef = basketsCollection
    .doc(userId)
    .collection('items')
    .doc(fundId);

  const existingItem = await itemRef.get();

  if (!existingItem.exists) {
    const error = new Error('Fund is not in your basket');
    error.statusCode = 404;
    throw error;
  }

  await itemRef.delete();
}

module.exports = {
  addFund,
  getBasket,
  removeFund,
};