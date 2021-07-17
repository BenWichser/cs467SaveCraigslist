const express = require("express"),
  db = require("../function"),
  aws = require("aws-sdk"),
  _ = require("lodash"),
  { v4: uuidv4 } = require("uuid"),
  bodyParser = require("body-parser");
const router = express.Router();

router.use(bodyParser.json());

router.post("/:sender_id/:receiver_id", async (req, res) => {
  let new_message = {
    sender_id: req.params.sender_id,
    receiver_id: req.params.receiver_id,
    content: req.body.content,
    date_sent: _.now(),
    id: req.params.sender_id + "_" + req.params.receiver_id + "_" + uuidv4(),
  };
  db.createItem("messages", aws.DynamoDB.Converter.marshall(new_message));
  res.status(201).json(new_message);
});

router.get("/:sender_id/:receiver_id", async (req, res) => {
  let messages = await db.queryMessages(
    req.params.sender_id,
    req.params.receiver_id
  );
  messages = _.flatMap(messages, (message) => {
    return aws.DynamoDB.Converter.unmarshall(message);
  });
  messages = _.sortBy(messages, (message) => {
    return parseInt(message.date_sent, 10);
  });
  res.status(200).json(messages);
});

module.exports = router;
