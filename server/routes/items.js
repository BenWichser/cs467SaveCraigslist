const express = require("express"),
  { body, validationResult } = require("express-validator"),
  customValidation = require("../middleware"),
  db = require("../function"),
  aws = require("aws-sdk"),
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
  ],
  customValidation.isLoggedIn,
  customValidation.validate,
  (req, res) => {
    db.createItem("items", {
      title: { S: req.body.title },
      seller_id: { S: req.body.seller_id },
      price: { N: req.body.price },
      location: { S: req.body.location },
      status: { S: req.body.status },
    });
    res.status(201).send();
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

router.get("/:item_id", (req, res) => {
  res.status(201).json();
});

router.put(
  "/:item_id",
  [
    body("title").exists().isString(),
    body("seller_id").exists().isString(),
    body("price").exists().isFloat(),
    body("location").exists().isString(),
    body("status").exists().isString(),
  ],
  customValidation.isLoggedIn,
  customValidation.validate,
  (req, res) => {
    res.status(200).send();
  }
);

router.delete(
  "/:item_id",
  customValidation.isLoggedIn,
  customValidation.validate,
  (req, res) => {
    db.deleteItem("items", req.params.item_id);
    res.status(204).send();
  }
);

module.exports = router;
