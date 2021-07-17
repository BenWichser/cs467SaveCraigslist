const express = require("express"),
  { body, validationResult } = require("express-validator"),
  customValidation = require("../middleware"),
  db = require("../function"),
  aws = require("aws-sdk"),
  { v4: uuidv4 } = require("uuid"),
  _ = require("lodash"),
  bodyParser = require("body-parser");
const router = express.Router();

router.use(bodyParser.json());

router.post(
  "/",
  [
    body("title").exists().isString(),
    body("seller_id").exists().isString(),
    body("price").exists().isFloat(),
    body("location").exists().isString(),
    body("status").exists().isString(),
    body("description").exists().isString(),
  ],
  //customValidation.isLoggedIn,
  customValidation.validate,
  (req, res) => {
    let new_id = uuidv4();
    let new_item = _.extend(req.body, { id: new_id });
    db.createItem("items", aws.DynamoDB.Converter.marshall(new_item));
    res.status(201).json({ id: new_id });
  }
);

router.get("/", async (req, res) => {
  let listings = await db.getAllItems("items", null);
  let output = [];

  listings.Items.forEach((item) => {
    output.push(aws.DynamoDB.Converter.unmarshall(item));
  });
  res.status(201).json(output);
});

router.get("/:item_id", async (req, res) => {
  let item = await db.getItem("items", req.params.item_id);
  if (_.isUndefined(item.Item)) {
    return res.status(404).json({ Error: "No item with that item_id exists" });
  }
  res.status(201).json(aws.DynamoDB.Converter.unmarshall(item.Item));
});

router.put(
  "/:item_id",
  [
    body("title").exists().isString(),
    body("seller_id").exists().isString(),
    body("price").exists().isFloat(),
    body("location").exists().isString(),
    body("status").exists().isString(),
    body("description").exists().isString(),
  ],
  //customValidation.isLoggedIn,
  customValidation.validate,
  async (req, res) => {
    let item = await db.getItem("items", req.params.item_id);
    if (_.isUndefined(item.Item)) {
      return res
        .status(404)
        .json({ Error: "No item with that item_id exists" });
    }
    let update = _.extend(req.body, { id: req.params.item_id });
    item = await db.updateItem(
      "items",
      aws.DynamoDB.Converter.marshall(_.extend(req.body, update))
    );
    res.status(200).json(update);
  }
);

router.delete(
  "/:item_id",
  //customValidation.isLoggedIn,
  async (req, res) => {
    let item = await db.getItem("items", req.params.item_id);
    if (_.isUndefined(item.Item)) {
      return res
        .status(404)
        .json({ Error: "No item with this item_id exists" });
    }
    db.deleteItem("items", req.params.item_id);
    res.status(204).send();
  }
);

module.exports = router;
