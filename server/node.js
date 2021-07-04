const express = require("express"),
  { body, validationResult } = require("express-validator"),
  { v4: uuidv4 } = require('uuid'),
  users = require("./routes/users.js"),
  items = require("./routes/items.js"),
  messages = require("./routes/messages.js"),
  bodyParser = require("body-parser");

let session = require("express-session");
const hostname = "127.0.0.1";
const port = process.env.port || 8080;
const app = express();

app.set("trust proxy", 1);

app.use(bodyParser.urlencoded({ extended: false }));
app.use("/users", users);
app.use("/items", items);
app.use("/messages", messages);

app.use(session({
  genid: uuidv4,
  secret: "What is the airspeed velocity of a laden swallow?",
  resave: false,
  saveUninitialized: true,
  cookie: {}
}));

app.post(
  "/login",
  [body("username").exists(), body("password").exists()],
  (req, res) => {
    req.session.username = req.body.username;
  }
);

app.post('/logout', (req, res) => {
  req.session.destroy();
});

app.listen(port, () => {
  console.log(`App listening at http://${hostname}:${port}`);
});
