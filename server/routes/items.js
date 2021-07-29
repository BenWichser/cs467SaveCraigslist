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

// Function
function makeListingsOutput(obj) {
  /* makeListingsOutput
   * Takes an array of items from DynamoDB and creates an appropriate array
   *  suitable for sharing with front end.
   * Accepts:
   *  obj (Object): DynamodDB return object with items array in it.
   * Returns:
   *  List of items converted via marshall
   */
  let output = [];
  obj['Items'].forEach( function (item) {
    output.push(aws.DynamoDB.Converter.unmarshall(item)
  )});
  return output;
}


// Functions
function itemPostTagEnhancer(body) {
  /* itemPostTagEnhancer
  * Scans title for useable tags, and adds them to body's tag array
  * Accepts:
  *   body (Object):  Object from item post
  * Returns:
  *   Null.  Alters `body['tags']`.
  */
 // make new array based on any tags already there
  let improvedTags = body.hasOwnProperty('tags') ? body['tags'] : [];
  // remove punctuation from both title and tags, in that order -- 
  // Not entirely sure ALL punctuation removal is best
  // var punctuation = '!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~';
  var regex = new RegExp(/[\u2000-\u206F\u2E00-\u2E7F\\'!"#$%&()*+,\-.\/:;<=>?@\[\]^_`{|}~]/, 'g');
  const noPunctuationTitle = body['title'].replace(regex, ' ');
  // any entered tags are made to be a string and then reformed into list
  //  after punctuation is removed.  This is to make sure the list is only
  //  of single words
  improvedTags = improvedTags.join(' ').replace(regex, ' ').split(' ');
  // change all current tag words to lower case
  if (improvedTags.length > 0)
    improvedTags.forEach( (name, index) => improvedTags[index] = name.toLowerCase());
  // add every title word that isn't alreadya tag into tag array
  const titleArray = noPunctuationTitle.split(' ');
  for (let word of titleArray)
  {
    if (!improvedTags.includes(word.toLowerCase()))
    {
      improvedTags.push(word.toLowerCase());
    }
  }
  // remove common words, as well as trailing 's' and 't' from contractions/possessive
  improvedTags = stopwords.removeStopwords(improvedTags, [...stopwords.en, ...['s', 't']]);
  // quick convert to set and back to remove duplicates
  improvedTags = [ ...new Set(improvedTags)];
  // remove empty strings
  improvedTags = improvedTags.filter( function(ele) {
    return  ele != '';
  }
  );
  // fix the body (ody ody ody) 'tags' value
  body['tags'] = improvedTags;
}

// Router routes
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
    itemPostTagEnhancer(req.body);
    let new_id = uuidv4();
    let new_item = _.extend(req.body, { id: new_id });
    db.createItem("items", aws.DynamoDB.Converter.marshall(new_item));
    res.status(201).json({ id: new_id });
  }
);

router.get("/", async (req, res) => {
  var zip = 'location' in req.body ? String(req.body.location) : '02134';
  try {
    let listings = await db.getOpeningItemList(zip, 10);
    res.status(201).json(makeListingsOutput(listings));
  } catch (err) {
    console.log(`Error getting opening item list: ${err}`);
  }
});

router.get("/search", async(req, res) => {
  // Route for search from user
  try {
    let listings = await db.getSearchItems(req.body);
    res.status(201).json(makeListingsOutput(listings));
  } catch (err) {
    console.log(`Error getting search item list: ${err}`);
  }
});

router.get("/users/:user_id", async (req, res)=> {
  let listings = await db.getAllUserItems(req.params.user_id, null);
  res.status(201).json(makeListingsOutput(listings));
})

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
