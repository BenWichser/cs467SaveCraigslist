var {
  ListTablesCommand,
  GetItemCommand,
  PutItemCommand,
  DeleteItemCommand,
  BatchGetItemCommand,
  ScanCommand,
  QueryCommand,
} = require("@aws-sdk/client-dynamodb");
var aws = require('aws-sdk');
// ddbClient construction -- created from AWS documentation but not provided in
//  AWS package
var { ddbClient } = require("./libs/ddbClient.js");
const crypt = require("bcrypt");
const _ = require("lodash");
var zipcodes = require("zipcodes");
var stopwords = require("stopword");
const { filter } = require("lodash");

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

function makeListingsOutput(arr) {
  /* makeListingsOutput
   * Takes an array of items from DynamoDB and creates an appropriate array
   *  suitable for sharing with front end.
   * Accepts:
   *  arr (array): array from DyanamoDB return Object.Items
   * Returns:
   *  List of items converted via marshall
   */
  let output = [];
  arr.forEach( function (item) {
    output.push(aws.DynamoDB.Converter.unmarshall(item)
  )});
  return output;
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

function itemSearchAddLocation(params, body, zipController) {
  /* itemSearchAddLocation
   * Adds location specification to item search parameters.
   * Accepts:
   *  params (object): Object created for Dynamo query command
   *  body (object): Body of search request
   *  zipController (object): information on starting search index and whether or not
   *    search should continue
   * Returns:
   *  Boolean on if more zip codes must be considered.  Also slters `params`
   */ 
  // set default location to home of PBS's "Zoom" if there is none already given
  var zip = 'location' in body ? String(body.location) : '70116';
  // set default distance to 5 miles
  var radius = 'radius' in body ? Number(body.radius) : 1100;
  const goodZips = zipcodes.radius(zip, radius);
  // if, for some crazy reason, we have no zip codes...bail
  if (goodZips.length == 0)
  {
    return;
  }
  console.log(`Good Zips: ${goodZips}$`);
  // until we are out of zip codes to look through, or we use 100 zips.
  var listZips = 0;
  zipNum = zipController.next_start;
  while (zipNum < goodZips.length && listZips < 100)
  {
    if (zipNum % 100 == 0) {
      params.ExpressionAttributeNames['#l'] = 'location';
      params.FilterExpression += " AND #l in ("
    } else
    {
      params.FilterExpression += ", "
    }
    params.FilterExpression += `:zip${zipNum}`;
    params.ExpressionAttributeValues[`:zip${zipNum}`] = {'S': goodZips[zipNum]};
    zipNum += 1;
    listZips +=1;
  }
  params.FilterExpression += ")";
  return {'next_start': zipNum, 'search_zips_again': !(zipNum == goodZips.length)};
}

function itemSearchAddPrice(params, body) {
  /* itemSearchAddPrice
   * Adds price requirements to item search parameters.
   * Accepts:
   *  params (object): Object created for Dynamo query command
   *  body (object): Body of search request
   * Returns:
   *  Nothing.  Alters `params`
   */ 
  if ('minPrice' in body && 'maxPrice' in body) {
    params.FilterExpression += "price between :minPrice and :maxPrice"; 
    params.ExpressionAttributeValues[':minPrice'] = {'N': Number(body.minPrice)};
    params.ExpressionAttributeValues[':maxPrice'] = {'N': Number(body.maxPrice)};
  } else if ('minPrice' in body)
  {
    params.FilterExpression += "price >= :minPrice";
    params.ExpressionAttributeValues[':minPrice'] = {'N': Number(body.minPrice)};
  } else if ('maxPrice' in body)
  {
    params.FilterExpression += "price <= :maxPrice";
    params.ExpressionAttributeValues[':maxPrice'] = {'N': Number(body.maxPrice)};
  }
 }

function itemSearchAddTags(params, body){
  /* itemSearchAddTags
   * Adds price requirements to item search parameters.
   * Accepts:
   *  params (object): Object created for Dynamo query command
   *  body (object): Body of search request
   * Returns:
   *  Nothing.  Alters `params`
   */ 
  // set default tags ot an empty string
  var tags = 'search' in body ? String(body.search) : '';
  if ('tags' in body)
  {
    // turn 'tags' from server into a list in format as stored on database
    var fakePost = {'title': body['tags']};
    itemPostTagEnhancer(fakePost);
    const tags = fakePost['tags'];
    console.log(tags);
    // make sure cleaning didnt remove all tags
    if (tags.length == 0)
      return;
    params.FilterExpression['#t'] =  'tags';
    const tagNum = 0;
    while (tags.length > 0)
    {
      //introduce tag logic clause in filter expression, or the logic connector "or"
      if (tagNum == 0)
      {
        params.FilterExpression += "AND (";
      } else
      {
        params.FilterExpression += " OR "
      }
      // add tag information to filter expression and the object of variables
      tagNum += 1;
      params.FilterExpression += `contains(#t, :tag${numTags}`;
      params.ExpressionAttributeValues[`:tag${numTags}`] = {'S': tags.pop()};
    }
    params.FilterExpression += ")";
  }
}

function addRelevanceToSearch(body, returnItems) {
  /* Adds the number of tag hits
   * Accepts:
      body (object): search request parameters
      returnItems: list of items to return
   * Returns:
      Nothing.  Modifies newItems
   */
  var fakeTitle = "tags" in body? body.tags : '';
  var fakePost = {'title':  fakeTitle};
  itemPostTagEnhancer(fakePost);
  const tags = fakePost['tags']
  var itemTagCount;
  console.log(returnItems);
  for (item of returnItems) {
    itemTagCount = 0;
    for (tag of item['tags']['L'])
    {
      if (tag in tags)
      {
        itemTagCount += 1;
      }
    }
    item['num_matching_tags'] = itemTagCount;
  }
}

async function getItemList(body) {
  /* getItemList
   * Returns a list of items according to the specified criteria.
   * Accepts:
   *  body (Object): Requests from app
   * Returns:
   *  List of DynamoDB return objects
   */
  console.log(JSON.stringify(body));
  // set default current user to jbutt
  var currentUser = 'user_id' in body ? String(body.user_id) : 'jbutt';
  var returnItems = [];
  // create loop for multiple zip code lists
  var zipController = {
    'next_start': 0,
    'search_zips_again': true
  };
  while (zipController.search_zips_again)
  {
    // set up parameters including need for active "For Sale" listing from another seller
    var params = {
      TableName: "items",
      IndexName: "status-index",
      KeyConditionExpression: '#s = :s',
      FilterExpression: "seller_id <> :sid",
      ExpressionAttributeNames: {
        '#s': 'status'
      },
      ExpressionAttributeValues: {
        ':s': {'S': 'For Sale'},
        ':sid': {'S': currentUser} 
      }
    }
    // Add location requirements, and get feedback on if we must check more zips
    zipController = itemSearchAddLocation(params, body, zipController);
    // Add price requirements
    itemSearchAddPrice(params, body);
    // Add tag requirements
    itemSearchAddTags(params, body);
    console.log(JSON.stringify(params)); 
    try {
      var newItems = await ddbClient.send(new QueryCommand(params));
    } catch (err) {
      console.log(`ERROR getItemList with parameters ${JSON.stringify(params)} -- ${err}`);
    }
  returnItems = returnItems.concat(newItems['Items']);
  }
  const currentZip = 'location' in body ? body.location : '70116';
  addDistanceToUser(currentZip, {"Items": returnItems} );
  addRelevanceToSearch(body, returnItems);
 console.log(`Search results: ${JSON.stringify(returnItems)}`);
return returnItems;
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
  itemPostTagEnhancer,
  makeListingsOutput,
  getItemList
};
