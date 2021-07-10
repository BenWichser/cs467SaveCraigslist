var {
  ListTablesCommand,
  GetItemCommand,
  PutItemCommand,
  DeleteItemCommand,
  BatchGetItemCommand,
  ScanCommand,
} = require("@aws-sdk/client-dynamodb");
// ddbClient construction -- created from AWS documentation but not provided in
//  AWS package
var { ddbClient } = require("./libs/ddbClient.js");

function createItem(datatype, data) {
  // createItem takes the table name and object to be posted and
  // sends a putItemCommand with that data
  // datatype: String (One of: "users", "messages", "items")
  // data: Object
  const params = {
    TableName: datatype,
    Item: data,
  };
  try {
    const action = ddbClient.send(new PutItemCommand(params));
  } catch (err) {
    console.log(err);
  }
}

async function getItem(datatype, id) {
  // getItem takes the table name and object ID and returns that item
  // datatype: String (One of: "users", "messages", "items")
  // id: String
  let params;

  if (datatype === "users") {
    params = {
      TableName: datatype,
      Key: {
        username: { S: id },
      },
    };
  } else {
    params = {
      TableName: datatype,
      Key: {
        id: { S: id },
      },
    };
  }

  try {
    const action = await ddbClient.send(new GetItemCommand(params));
    return action;
  } catch (err) {
    console.log(err);
  }
}

async function getAllItems(datatype, lastEval) {
  // getAllItems takes the table name and lastEvaluatedItem and sends a
  // ScanCommand to pull 10 entries from the table starting with that item
  // datatype: String (One of: "users", "messages", "items")
  // lastEval: Object (KEY, Returned from prior Scan, Can be Null)
  // NOTE: Scan is very inefficient and costly - we should work to minimize
  const params = {
    TableName: datatype,
    Limit: 10,
    ExclusiveStartKey: lastEval,
  };
  try {
    const action = await ddbClient.send(new ScanCommand(params));
    console.log(action);
    return action;
  } catch (err) {
    console.log(err);
  }
}

function deleteItem(datatype, id) {
  // deleteItem takes the table name and id of an element and sends a
  // DeleteItemCommand for this id
  // datatype: String (One of: "users", "messages", "items")
  // id: String
  let params;

  if (datatype === "user") {
    params = {
      TableName: datatype,
      Key: {
        username: { S: id },
      },
    };
  } else {
    params = {
      TableName: datatype,
      Key: {
        id: { S: id },
      },
    };
  }
  try {
    const action = ddbClient.send(new DeleteItemCommand(params));
  } catch (err) {
    console.log(err);
  }
}

module.exports = {
  createItem,
  getItem,
  deleteItem,
  getAllItems,
};
