var {
  ListTablesCommand,
  GetItemCommand,
  PutItemCommand,
  DeleteItemCommand,
  BatchGetItemCommand,
  ScanCommand,
  QueryCommand,
} = require("@aws-sdk/client-dynamodb");
// ddbClient construction -- created from AWS documentation but not provided in
//  AWS package
var { ddbClient } = require("./libs/ddbClient.js");
const crypt = require("bcrypt");
const _ = require("lodash");
var zipcodes = require("zipcodes");
var stopwords = require("stopword");

async function hashPassword(password) {
  const salt = await crypt.genSalt(10);
  const hash = await crypt.hash(password, salt);
  return hash;
}

async function createItem(datatype, data) {
  // createItem takes the table name and object to be posted and
  // sends a putItemCommand with that data
  // datatype: String (One of: "users", "messages", "items")
  // data: Object
  const params = {
    TableName: datatype,
    Item: data,
    ConditionExpression: "attribute_not_exists(id)",
  };
  try {
    const action = await ddbClient.send(new PutItemCommand(params));
    return action;
  } catch (err) {
    console.log(err);
  }
}

async function updateItem(datatype, data) {
  // createItem takes the table name and object to be posted and
  // sends a putItemCommand with that data
  // datatype: String (One of: "users", "messages", "items")
  // data: Object
  const params = {
    TableName: datatype,
    Item: data,
  };
  try {
    const action = await ddbClient.send(new PutItemCommand(params));
    return action;
  } catch (err) {
    console.log(err);
  }
}

async function getItem(datatype, id) {
  // getItem takes the table name and object ID and returns that item
  // datatype: String (One of: "users", "messages", "items")
  // id: String
  const params = {
    TableName: datatype,
    Key: {
      id: { S: id },
    },
  };

  try {
    const action = await ddbClient.send(new GetItemCommand(params));
    return action;
  } catch (err) {
    console.log(err);
  }
}

async function getNumItems(num, lastEval, forSale = true) {
  // getNumItems take the number of items desired and lastEvaluatedItem and sends a
  // ScanCommand to pull `num` entries from the table starting with that item
  // num: Int (number of items to be asked for)
  // lastEval: Object (KEY, Returned from prior Scan, Can be Null)
  // forSale: bool - Must items be for sale
  // NOTE: Scan is very inefficient and costly - we should work to minimize
    const params = {
        TableName: 'items',
        IndexName: 'status-location-index',
        Limit: num,
        ExclusiveStartKey: lastEval,
          };
    if (forSale) 
    {
            params["KeyConditionExpression"] = "#s = :s";
            params["ExpressionAttributeNames"] = {"#s": "status"};
            params["ExpressionAttributeValues"] = {
                ":s": {S: "For Sale"}
            };
    }
      try {
            const action = await ddbClient.send(new QueryCommand(params));
            return action;
      } catch (err) {
        console.log(err);
      }
}

function addDistanceToUser(location, data) {
  /* addDistanceToUser
   * Takes a list of JSON objects, from DynamoDB, and adds a key:value pair, representing
   *  distance to the user.
   * Accepts:
   *  locaiton (string): Current location
   *  data (list of JSON): data representing an entry in "items" table
   * Returns:
   *  None. Alters `data` to include `distance`: key value in each member
   */
  data['Items'].forEach( function(item) {
    item['distance'] = {'N': zipcodes.distance(location, item['location']['S'])};
  });
  return data;
}

async function getOpeningItemList(location, num) {
  /* openingItemList 
   * Uses getNumItems to get the opening screen list of items, including distance to user
   * Currently:
   *  10 ITEMS WITH NO TAG RELEVANCE SEARCH
   * Accepts:
   *  locaiton (String): Location for distance comparison
   *  num (int): Maximum number of items to return
   * Returns:
   *  JSON of DynamoDB items for user by default when they open the app.
   */
  try {
    const returnItems = await getNumItems(num, null, true);
    await addDistanceToUser(location, returnItems);
    return returnItems;
  } catch (err) {
    console.log(`Error getting opening item list: ${err}`);
  }
}


async function getAllUserItems(userId, lastEval) {
  const params = {
    TableName: "items",
    FilterExpression: "seller_id = :s",
    ExpressionAttributeValues: {
      ":s": { S: userId },
    },
    Limit: 10,
    ExclusiveStartKey: lastEval,
  };
  try {
    const action = await ddbClient.send(new ScanCommand(params));
    return action;
  } catch (err) {
    console.log(err);
  }
}

async function queryMessages(sender, receiver) {
  const params = {
    TableName: "messages",
    FilterExpression: "(receiver_id = :r AND sender_id = :s)",
    ExpressionAttributeValues: {
      ":r": { S: receiver },
      ":s": { S: sender },
    },
  };
  const params2 = {
    TableName: "messages",
    FilterExpression: "(receiver_id = :s AND sender_id = :r)",
    ExpressionAttributeValues: {
      ":r": { S: receiver },
      ":s": { S: sender },
    },
  };
  try {
    const action = await ddbClient.send(new ScanCommand(params));
    const action2 = await ddbClient.send(new ScanCommand(params2));
    let messages = _.concat(action.Items, action2.Items);
    return messages;
  } catch (err) {
    console.log(err);
  }
}

function deleteItem(datatype, id) {
  // deleteItem takes the table name and id of an element and sends a
  // DeleteItemCommand for this id
  // datatype: String (One of: "users", "messages", "items")
  // id: String
  const params = {
    TableName: datatype,
    Key: {
      id: { S: id },
    },
  };
  try {
    const action = ddbClient.send(new DeleteItemCommand(params));
  } catch (err) {
    console.log(err);
  }
}

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

module.exports = {
  createItem,
  getItem,
  deleteItem,
  getNumItems,
  getOpeningItemList,
  hashPassword,
  updateItem,
  queryMessages,
  getAllUserItems,
  itemPostTagEnhancer
};
