const express = require("express"),
  { body, validationResult } = require("express-validator"),
  customValidation = require("../middleware"),
  db = require("../function"),
  aws = require("aws-sdk"),
  { v4: uuidv4 } = require("uuid"),
  _ = require("lodash"),
  zip = require("zipcodes"),
  bodyParser = require("body-parser"),
  stopwords = require("stopword");


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
    db.itemPostTagEnhancer(req.body);
    let new_id = uuidv4();
    let new_item = _.extend(req.body, { id: new_id });
    db.createItem("items", aws.DynamoDB.Converter.marshall(new_item));
    res.status(201).json({ id: new_id });
  }
);

router.get("/", async (req, res) => {
  try {
    console.log(JSON.stringify(req.params));
    let listings = await db.getItemList(req.params);
    console.log("Got listings.  Now going to clean them up")
    res.status(201).json(db.makeListingsOutput(listings));
  } catch (err) {
    console.log(`ERROR getting item list: ${err}`);
  }
});

router.get("/users/:user_id", async (req, res)=> {
  let listings = await db.getAllUserItems(req.params.user_id, null);
  res.status(201).json(db.makeListingsOutput(listings.Items));
})

router.get("/:item_id", async (req, res) => {
  try{
    let item = await db.getItem("items", req.params.item_id);
    if (_.isUndefined(item.Item)) {
      return res.status(404).json({ Error: "No item with that item_id exists" });
    }
    item.Item['photo'] = await db.getUserPhoto(item.Item.seller_id.S)
    res.status(201).json(aws.DynamoDB.Converter.unmarshall(item.Item));
  } catch (err) {
    console.log(`Error getting /items/${item_id}`);
  }
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


// TEST FUNCTION
var testItemPostTagEnhancer = function () {
  const bodies = [ 
    { 
      'title': ''
    },
    { 
      'tags' : [],
      'title': 'Goonies never say die'
    },
    { 
      'tags' : 'the quick fox jumped over the lazy dog.'.split(' '),
      'title': 'dog bowl'
    },
    { 
      'tags' : 'The Quick Fox JUMPED OVER THE LAZY DOG'.split(' '),
      'title': 'DOG boWl'
    },
    { 
      'tags' : 'The Quick Fox JUMPED OVER THE LAZY DOG The Quick Fox JUMPED OVER THE LAZY DOG'.split(' '),
      'title': 'DOG boWl'
    },
    {
      'tags': 'She sells Sally\'s sea shells by the SEA-SHORE'.split(' '),
      'title': 'Sally: biography of an entrepreneur-mermaid'
    },
    {
      'tags': 'Waterfall -- Sally\'s favourite!'.split(' '),
      'title': 'Waterfall -- Sally\'s favourite!'
    }
   ];
  console.log("Testing itemPostTagEnhancer:");
  bodies.forEach( function(body)
  {
    var preTags = body.hasOwnProperty('tags') ? body['tags'] : 'NO TAGS FIELD ENTERED';
    console.log(`Title before improvement: \t ${body['title']}`);
    console.log(`Tags before improvement: \t ${preTags}`);
    itemPostTagEnhancer(body);
    console.log(`Enhanced tags: ${body['tags']} \n `);
  });
}

if (typeof require != 'undefined' && require.main === module)
{
  testItemPostTagEnhancer();
}

// EXPORTS
module.exports = router;
