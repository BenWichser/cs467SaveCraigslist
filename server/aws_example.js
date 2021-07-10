// IMPORTS
// AWS-specific commands
var {
    ListTablesCommand, 
    GetItemCommand, 
    PutItemCommand,
    DeleteItemCommand
} = require("@aws-sdk/client-dynamodb");
// ddbClient construction -- created from AWS documentation but not provided in
//  AWS package
var { ddbClient } = require("./libs/ddbClient.js");


// FUNCTIONS THAT DO WORK
let listTables = async function () {
    /* listTables
     * Function to get the tables currently available
     * Accepts:
     *  Nothing
     * Returns:
     *  JSON of table names
     */
    try 
    {
        const data = await ddbClient.send(new ListTablesCommand({}));
        console.log(data.TableNames.join("\n"));
        return data;
    } 
    catch (err) 
    {
        console.error(err);
    }
    };

let fetchOneByKey = async function (tablename, username = "") {
    /* fetchOneByKey
     * Async function to get item from a table
     * Accepts:
     *  username (string): Username
     * Returns:
     *  JSON of item
     */
    var params = {
        TableName: tablename,
        Key: {
            "username": { S: username },
        },
        ProjectionExpression: "email",
    };
    try
    {
        const data = await ddbClient.send( new GetItemCommand(params));
        console.log("Success", data.Item);
        return data;
    }
    catch (err)
    {
        consolde.error(err);
    }
};

let addUser = async function (userObject) {
    /* addUser
     * Async function to add a user (row to User table)
     * Accepts:
     *  Object with user information
     * Returns:
     *  JSON of success
     */
    console.log(userObject.zip);
    const params = {
        TableName: "users",
        Item:
        {
            zip: {S: userObject.zip},
            username: {S: userObject.username},
        },
    };
    try 
    {
        const data = await ddbClient.send(new PutItemCommand(params));
        console.log("Added User");
        console.log(data);
        return data;
    }
    catch (err)
    {
        console.error(err);
    }
};

let deleteUser = async function (username) {
    /* deleteUser
     * Async function to delete a user
     * Accepts:
     *  username (string): username to be deleted
     * Returns:
     *  JSON of success
     */
    var params = {
        TableName: "users",
        Key: {
            username: {S: username},
            },
        };
    try
    {
        const data = await ddbClient.send(new DeleteItemCommand(params));
        console.log(`Success: user ${username} deleted`);
        console.log(data);
        return data;
    }
    catch (err)
    {
        if (err && err.code === "ResourceNotFoundException")
            console.log("Error: Table not found");
        else if (err && err.code === "ResourceInUseException")
        {
            console.log("Error: Table in use");
        }
    }
};




// Script to go through functions
console.log("Listing tables:");
listTables();
console.log("Fetching an example from User table");
fetchOneByKey("users", "joebiden46");
console.log("Adding a user:");
addUser({zip: "80301", username: "mckenzry"});
console.log("Deleting the user we just added:");
deleteUser("mckenzry");
