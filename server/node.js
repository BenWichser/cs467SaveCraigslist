const express = require("express"),
  { body, validationResult } = require("express-validator"),
  { v4: uuidv4 } = require("uuid"),
  users = require("./routes/users.js"),
  items = require("./routes/items.js"),
  messages = require("./routes/messages.js"),
  generatePresignedURL = require("./routes/generatePresignedURL.js"),
  db = require("./function"),
  crypt = require("bcrypt"),
  _ = require("lodash"),
  aws = require("aws-sdk"),
  customValidation = require("./middleware"),
  bodyParser = require("body-parser");

let session = require("express-session");
const hostname = "127.0.0.1";
const port = process.env.port || 8080;
const app = express();


app.set("trust proxy", 1);

app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());
app.use("/users", users);
app.use("/items", items);
app.use("/messages", messages);
app.use("/generatePresignedUrl", generatePresignedURL);

app.use(
  session({
    genid: uuidv4,
    secret: "What is the airspeed velocity of a laden swallow?",
    resave: false,
    saveUninitialized: true,
    cookie: {},
  })
);

app.post(
  "/login",
  [body("username").exists(), body("password").exists()],
  customValidation.validate,
  async (req, res) => {
    let user = await db.getItem("users", req.body.username);
    if (_.isUndefined(user.Item)) {
      return res
        .status(400)
        .json({ error: "There is no such user in our system" });
    }
    const match = await crypt.compare(req.body.password, user.Item.password.S);

    if (match) {
      req.session.user = {
        username: user.Item.id.S,
        email: user.Item.email.S,
      };
    } else {
      return res.status(400).json({ error: "Incorrect password" });
    }
    user = aws.DynamoDB.Converter.unmarshall(_.omit(user.Item, "password"));
    console.log(`Logged in user ${req.body.username}`);
    return res.status(200).json(user);
  }
);

app.post("/logout", customValidation.isLoggedIn, (req, res) => {
  req.session.destroy();
  return res.status(200).send("Logged Out");
});

app.listen(port, () => {
  console.log(`App listening at http://${hostname}:${port}`);
});

