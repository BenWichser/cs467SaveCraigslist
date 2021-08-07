const express = require("express"),
  db = require("../function"),
  aws = require("aws-sdk"),
  _ = require("lodash"),
  { v4: uuidv4 } = require("uuid"),
  route_utils = require("../route_utils"),
  bodyParser = require("body-parser");
const router = express.Router();

router.use(bodyParser.json());

router.post("/:sender_id/:receiver_id", async (req, res) => {

  let new_message = {
    sender_id: req.params.sender_id,
    receiver_id: req.params.receiver_id,
    content: req.body.content,
    date_sent: _.now().toString(),
    id: req.params.sender_id + "_" + req.params.receiver_id + "_" + uuidv4(),
  };
  db.createItem("messages", aws.DynamoDB.Converter.marshall(new_message));

  let sender = await db.getItem("users", new_message.sender_id);
  let receiver = await db.getItem("users", new_message.receiver_id);

  sender = aws.DynamoDB.Converter.unmarshall(sender.Item);
  receiver = aws.DynamoDB.Converter.unmarshall(receiver.Item);

  let sender_mapped = {recent_id: sender.id, message_id: new_message.id};
  let receiver_mapped = {recent_id: receiver.id, message_id: new_message.id};

  sender.recents = route_utils.recent_uniques(sender.recents, receiver_mapped);
  receiver.recents = route_utils.recent_uniques(receiver.recents, sender_mapped);

  db.updateItem("users", aws.DynamoDB.Converter.marshall(sender));
  db.updateItem("users", aws.DynamoDB.Converter.marshall(receiver));

  res.status(201).json(new_message);
});

router.get("/:user_id/recents", async (req, res) => {
  let user = await db.getItem("users", req.params.user_id);
  user = aws.DynamoDB.Converter.unmarshall(user.Item);
  let recents = user.recents;

  if (_.isUndefined(recents)) {
    return res.status(200).send([]);
  }
  let recents_details = [];
  let recent;
  let content;

  for (let i = 0; i < recents.length; i++) {
    recent = await db.getItem("users", recents[i].recent_id);
    recent = aws.DynamoDB.Converter.unmarshall(recent.Item);
    content = await db.getItem("messages", recents[i].message_id);
    content = aws.DynamoDB.Converter.unmarshall(content.Item);
    recent.content = content;
    recents_details.push(_.omit(recent, ["password", "recents"]));
  }

  res.status(200).json(recents_details);
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
