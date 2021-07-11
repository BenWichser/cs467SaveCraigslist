const { validationResult } = require("express-validator"),
  _ = require("lodash");

function validate(req, res, next) {
  if (!validationResult(req).isEmpty()) {
    console.log(validationResult(req));
    return res
      .status(400)
      .json({ error: "Your request has missing or invalid attributes" });
  } else {
    next();
  }
}

function isLoggedIn(req, res, next) {
  if (_.isUndefined(req.session.user)) {
    return res.status(400).json({ error: "You're not logged in!" });
  } else {
    next();
  }
}

module.exports = {
  validate,
  isLoggedIn,
};
