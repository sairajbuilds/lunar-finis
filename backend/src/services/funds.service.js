const { db } = require('../config/firebase');

async function getAllFunds() {
  const snapshot = await db.collection('funds').get();

  return snapshot.docs.map((doc) => ({
    id: doc.id,
    ...doc.data(),
  }));
}

async function getFundById(fundId) {
  const doc = await db.collection('funds').doc(fundId).get();

  if (!doc.exists) {
    return null;
  }

  return {
    id: doc.id,
    ...doc.data(),
  };
}

module.exports = {
  getAllFunds,
  getFundById,
};