const { auth } = require('../config/firebase');

async function authenticate(req, res, next) {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        message: 'Authentication required',
      });
    }

    const idToken = authHeader.split('Bearer ')[1];

    const decodedToken = await auth.verifyIdToken(idToken);

    req.user = {
      uid: decodedToken.uid,
    };

    next();
  } catch (error) {
    return res.status(401).json({
      message: 'Invalid or expired authentication token',
    });
  }
}

module.exports = authenticate;