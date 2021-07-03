const express = require("express"),
  users = require("./routes/users.js"),
  items = require("./routes/items.js"),
  messages = require("./routes/messages.js"),
  bodyParser = require("body-parser");

const hostname = "127.0.0.1";
const port = process.env.port || 8080;
const app = express();

app.use(bodyParser.urlencoded({ extended: false }));
app.use("/users", users);
app.use("/items", items);
app.use("/messages", messages);

app.listen(port, () => {
  console.log(`App listening at http://${hostname}:${port}`);
});
