// Import required AWS SDK clients and commands for Node.js.
// Set the parameters
// IMPORTS
// AWS-specific commands
var {
    ListTablesCommand, 
    GetItemCommand, 
    PutItemCommand,
    DeleteItemCommand
} = require("@aws-sdk/client-dynamodb");
var { 
    PutObjectCommand,                   // Puts a single object in S3 bucket 
    CreateBucketCommand,                // Creates a S3 bucket
    ListObjectsCommand,                 // Lists all objects in an S3 bucket
    DeleteObjectCommand,                // Deletes a single object in an S3 bucket
    DeleteBucketCommand                 // Delets an empty S3 bucket
} = require("@aws-sdk/client-s3");

// ddbClient and s3Client construction -- created from AWS documentation 
// but not provided in AWS package

var { s3Client } = require("./libs/sampleClient.js");
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
            "id": { S: username },
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
            id: {S: userObject.username},
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
            id: {S: username},
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


let createBucket = async function(bucketName){
    /* createBucket
     * Creates a new AWS bucket with specified name.
     * Accepts
     *  bucketName (string): name of AWS bucket to be created
     * Returns:
     *  JSON response from AWS server
     */
    try {
        const data = await s3Client.send(
             new CreateBucketCommand({ Bucket: bucketName})
         );
        console.log(data);
        console.log("Successfully created a bucket called ", data.Location);
        // uploadFile(bucketName, "TextTest.txt", "Text Test");
        return data;
    } catch (err) {
        console.log("Error creating bucket:", err);
    }
};

let uploadFile = async function(bucketName, fileName, fileContents){
    /* uploadFile
     * Uploads a specified file into a specified bucket.
     * Accepts:
     *  bucketName (string): Name of bucket into which file is uploaded
     *  fileName (string): Name of file to be created
     *  fileContents (string): Text of file to be created
     */
    const params = {
        Bucket: bucketName,
        Key: fileName,
        Body: fileContents,
    };
    try {
        const results = await s3Client.send(new PutObjectCommand(params));
        console.log("Successfully created " + params.Key + 
            " and uploaded it to " + params.Bucket + "/" + params.Key);
        return results;
    } catch (err) {
        console.log(`Error uploading $params.Key`, err);
    }
};

async function listAllBucketObjects(bucketName){
    /* listAllBucketObjects
     * Lists all objects in a certain S3 bucket.
     * Accepts:
     *  bucketName (string): Name of S3 bucket
     * Returns:
     *  array of all objects in the S3 bucket
     */
    const params = {Bucket: bucketName};
    try {
        const data = await s3Client.send(new ListObjectsCommand(params));
        console.log(data.Contents);
        return data.Contents;
    } catch(err) {
        console.log(`Error getting items from ${bucketName}`, err);
    }
}

async function deleteAllBucketObjects(bucketName){
    /* deleteAllBucketObjects
     * Deletes all objects in S3 bucket
     * Accepts:
     *  bucketName (string): Name of S3 bucket
     * Returns:
     *  Nothing
     */
    // get list of bucket objects
    const objectList = await listAllBucketObjects(bucketName);
    console.log("This is what we have to delete:" + 
        `${JSON.stringify(objectList)})`);
    if (objectList.length != 0) 
    {
        for(let i = 0; i < objectList.length; i++)
        {
            try {
                const data = await s3Client.send(new DeleteObjectCommand( {
                    Key: objectList[i].Key, Bucket: bucketName }));
                console.log(`Deleted ${objectList[i].Key} from ${bucketName}.`);
            } catch (err) {
                console.log(`Error deleting ${objectList.Key} from ${bucketName}` +
                    err);
            }
        }
    }
    return;
}

async function deleteBucket(bucketName){
    /* deleteBucket
     * Deletes an S3 bucket with the given name.  Note: the bucket must be
     *  already empty for AWS to delete.
     * Accepts:
     *  bucketName (string): Name of bucket to be deleted
     * Returns:
     *  Nothing
     */
    try {
        const data = await s3Client.send( 
            new DeleteBucketCommand({Bucket: bucketName}));
        console.log(`Successfully deleted bucket ${bucketName}.`);
        console.log(data);
    } catch(err) {
        console.log(`Error deleting bucket ${bucketName}:` + err);
    }
}

async function dynamoDBTest(){
    /* dynamoDBTest
     * Goes through basic DynamoDB features.  All wrapped in this function to
     * (needlessly, aside from feedback) enforce syncronicity among calls.
     * Accepts:
     *  Nothing
     * Returns:
     *  Nothing
     */
    console.log("Listing tables:");
    await listTables();
    console.log("Fetching an example from User table");
    await fetchOneByKey("users", "joebiden46");
    console.log("Adding a user:");
    await addUser({zip: "80301", username: "mckenzry"});
    console.log("Deleting the user we just added:");
    await deleteUser("mckenzry");
}

async function s3Test() {
    /* s3Test
     * Goes through s3 bucket and file access process.  All wrapped in this
     *  function to enforce syncronicity among files.
     * Accepts:
     *  Nothing
     * Returns:
     *  Nothing
     */
    console.log("Creating a bucket named TextTest");
    await createBucket("wichserbentexttest");
    console.log("Uploading text to TextTest bucket");
    await uploadFile("wichserbentexttest", "HelloWorld.txt", "Hello world");    
    console.log("Printing things in wichserbentexttest bucket");
    const bucketContents = await listAllBucketObjects("wichserbentexttest");
    console.log("Deleting each item in the bucket");
    await deleteAllBucketObjects("wichserbentexttest");
    console.log("Finally, we clean up by deleting the now-empty bucket");
    await deleteBucket("wichserbentexttest");
}


// SCRIPT TO GO THROUGH TESTS
dynamoDBTest();
s3Test();

