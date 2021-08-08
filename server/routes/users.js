const express = require("express"),
  bodyParser = require("body-parser"),
  { body, validationResult } = require("express-validator"),
  db = require("../function"),
  _ = require("lodash"),
  aws = require("aws-sdk"),
  customValidation = require("../middleware");
const router = express.Router();

router.use(bodyParser.json());

router.post(
  "/",
  [
    body("email").exists().isEmail(),
    body("username").exists(),
    body("password").exists(),
    body("zip").exists(),
  ],
  customValidation.validate,
  async (req, res) => {
    let password = await db.hashPassword(req.body.password);
    let exists = await db.getItem("users", req.body.username);

    if (!_.isUndefined(exists.Item)) {
      return res.status(403).json({ error: "A user with this username already exists" });
    }
    
    let newUserParams = {
        email: { S: req.body.email },
        id: { S: req.body.username },
        password: { S: password },
        zip: { S: req.body.zip },
        recents: { L: [] }
    };
    if ('photo' in req.body)
    {
      newUserParams.photo = { S: req.body.photo};
    }
    await db.createItem("users", newUserParams);
    res.status(201).send();
  }
);

router.get("/:user_id", async (req, res) => {
  let user = await db.getItem("users", req.params.user_id);
  if (_.isUndefined(user.Item)) {
    return res.status(404).json({ error: "This user doesn't exist" });
  } else {
    user = _.omit(aws.DynamoDB.Converter.unmarshall(user.Item), "password");
    console.log(`Logged in user ${req.params.user_id}`);
    return res.status(200).json(user);
  }
});

router.patch("/:user_id", async (req, res) => {
  console.log(`Patching info for user ${req.params.user_id}`);
  try {
    let current = await db.getItem("users", req.params.user_id);
    current = aws.DynamoDB.Converter.unmarshall(current.Item);
    if (_.isUndefined(current)) {
      return res.status(404).json({ error: "No user with this user_id" });
    }
    current.email = _.isUndefined(req.body.email)
      ? current.email
      : req.body.email;
    const oldZip = current.zip;
    current.zip = _.isUndefined(req.body.zip) ? current.zip : req.body.zip;
    if ('photo' in req.body)
    {
      current.photo = req.body.photo;
    }
    await db.updateItem("users", current);
    // if we changed the location, then the user's items should have their location also changed
    if (oldZip != current.zip)
    {
      await db.changeUserItemLocations(current);
    }
    // only send back necessary information
    current = {
      photo: current.photo,
      zip: current.zip,
      email: current.email,
      id: current.id
    }
    res.status(200).json(current);
  } catch (err) {
    console.log(`ERROR patch /:user_id for ${req.params.user_id} -- error getting current user info: ${err}`);
    return res.status(500);
  }
});


router.delete("/:user_id", customValidation.isLoggedIn, (req, res) => {
  db.deleteItem("users", req.params.user_id);
  res.status(204).send();
});

module.exports = router;
