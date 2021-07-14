/* Removes all entries in `users` table and adds the new users */ 

// Required items and functions
const path = require("path");
const fs = require("fs");
const {
    sampleUserA, 
    sampleUserB, 
    sampleUserC
} = require("./sample_users.js");
const { ddbClient } = require("../libs/ddbClient.js");
const { s3Client } = require("../libs/sampleClient.js");
const {
    userTemplate, 
    itemTemplate, 
    messageTemplate
} = require("../dbStructure.js");
const {
    DeleteItemCommand,      // Remove DyanmoDB item
    PutItemCommand,         // Create DynamoDB item
    ScanCommand,            // Read DynamoDB table
} = require("@aws-sdk/client-dynamodb");

const {
    DeleteObjectCommand,      // Delete Object in s3 bucket
    GetObjectCommand,        // Download Object in s3 bucket
    ListObjectsCommand,      // List items in s3 bucket      
    PutObjectCommand,        // Place item in S3 bucket
} = require("@aws-sdk/client-s3");
db = require("../function"),


// Functions
async function listAllBucketObjects(bucketName){
    /* listAllBucketObjects
     * Lists all objects in a certain S3 bucket.
     * Accepts:
     *  bucketName (string): Name of S3 bucket
     * Returns:
     *  Array of all objects in the S3 bucket
     */
    const params = {Bucket: bucketName};
    try {
        const data = await s3Client.send(new ListObjectsCommand(params));
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
    try{
        var objectList = await listAllBucketObjects(bucketName);
    } catch(err) {
        console.log(`Error getting all items from ${bucketName}`);
    }
    // delete all bucket objects
    if (objectList && objectList.length != 0) 
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
    console.log("Done deleting all bucket objects.");
    return;
}

async function deleteThisTableEntry(tablename, user_id){
    /* deleteThisTableEntry
     * Async function to delete a single entry from a particular table
     * Accepts:
     *  tablename (string): table from which to delete entry
     *  user_id (string): id of entry to delete
     * Returns:
     *  Nothing.  Deletes entry from table.
     */
    var params = {
        TableName: tablename,
        Key: {
            id: {S: user_id},
            },
        };
    try
    {
        const data = await ddbClient.send(new DeleteItemCommand(params));
        console.log(`Success: entry ${user_id} deleted`);
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

async function deleteAllTableEntries(tablename) {
    /* deleteAllTableEntries
     * Deletes all entries in a given table
     * Accepts:
     *  tablename (string): name of table from which to get entries
     * Returns:
     *  Nothing. Empties given table of values.
     */
    var params = {
        TableName: tablename
    };
    // Iterate through table, getting a bunch of items until it's empty
    while (true) {
        try {
            // get some current table items
            const data = await ddbClient.send(new ScanCommand(params));
            // if table is empty, exit loop
            if (data.Items.length == 0)
                break;
            // create array of items to be deleted
            deleteThese = [];
            data.Items.forEach(element => deleteThese.push(
                element.id.S));
            // delete each item
            for (const entry of deleteThese)
                await deleteThisTableEntry(tablename, entry);
        } catch(err) {
            console.log(`Error scanning for entries in ${tablename}: `, err);
            break;
        }
    }
}

async function uploadUserPhoto(params){
    /* uploadUserPhoto
     * Uploads sample user photo into S3
     *  correct photo location.
     * Accepts:
     *  params (object): parameters we are creating for user upload
     * Returns:
     *  Nothing.  Modifies s3 bucket.
     */
    // create upload parameters
    const file = "./user_photos/" + params.Item.photo.S;
    const filestream = fs.createReadStream(file);
    const uploadParams = {
        Bucket: params.Item.bucket.S,
        Key: path.basename(file),
        Body: filestream,
        ContentType: "image/jpeg",
    };
    // Upload file to specified bucket.
    try {
        const data = await s3Client.send(new PutObjectCommand(uploadParams));
        console.log(`Success uploading image for ${params.Item.id.S}`);
        return data; // For unit tests.
    } catch (err) {
        console.log(`Error uploading image for ${params.Item.id.S}`, err);
    }
};

async function downloadUserPhoto(params){
    /* downloadUserPhoto
     * Downloads sample user photo from s3
     * Accepts:
     *  params (object): parameters for user upload
     * Returns:
     *  Nothing.  Modifies file system
     */
    const path = "./user_photos";
    // remove file if it exists
    const filename = path + '/' + "download_" + params.Item.photo.S;
    try{
        fs.unlinkSync(filename);
    } catch (err) {
        if (err && err.code == 'ENOENT')
            // file didn't exist
            console.log("File didn't exist, so removal was not necessary.");
        else
        console.log(`Error removing ${filename}: `, err);
    }
    // download the file
    try{
        //
        // Create a helper function to convert a ReadableStream to a string.
        const streamToString = (stream) =>
        new Promise((resolve, reject) => {
            const chunks = [];
            stream.on("data", (chunk) => chunks.push(chunk));
            stream.on("error", reject);
            stream.on("end", () => resolve(
                Buffer.concat(chunks).toString("utf8")));
        });
        // Get the object} from the Amazon S3 bucket. 
        // It is returned as a ReadableStream.
        const data = await s3Client.send(new GetObjectCommand({
            Bucket: params.Item.bucket.S,
            Key:params.Item.photo.S
        }));
        // return data; // For unit tests.
        // Convert the ReadableStream to a string.
        const bodyContents = await streamToString(data.Body);
        fs.writeFileSync(filename, bodyContents);
    } catch (err) {
        console.log(`Error downloading ${params.Item.photo.S}`, err);
    }
} 
    
async function insertSampleData(tablename, entries) {
    /* insertSampleData
     * Inserts a set of entries into a specified table
     * Accepts:
     *  tablename (string): table into which we want to insert data
     *  entries (array of objects): items to insert
     * Returns:
     *  Nothing.  Specified table has entries added to it
     */
    // empty user photo bucket
    const photoBucketName = 'savecraigslistsampleuserphotos';
    await deleteAllBucketObjects(photoBucketName);
    // go through the array of entries to be added, creating an insertion
    //  object for each one
    for(const entry of entries) {
        var params = {
            TableName: tablename,
            Item:
            {
                // all entries must have an id, and the samples share a bucket
                id: {S: entry.id},
                bucket: {S: photoBucketName}
            }
        }
        // add in any other keys that are present
        for(var field in entry)
            params.Item[ [field] ]   = { [userTemplate[field]]: entry[field]};
        // redo password as hashed/salted password
        if ('password' in entry)
            params.Item.password = {
                S: await db.hashPassword(entry.password)
            };  
        // upload user photo
        await uploadUserPhoto(params);
        // test download of user photo
        await downloadUserPhoto(params);
        // insert into table
        try {
            const data = await ddbClient.send(new PutItemCommand(params));
            console.log(`Added User ${params.Item.id.S}.`);
        }
        catch (err)
        {
            console.error(err);
        }
    }
};

async function reset_users() {
    /* reset_users
     * Deletes all entries in "users" and replaces with sample data
     * Accepts:
     *  Nothing
     * Returns:
     *  Nothing.  "users" table is altered
     */
    // delete all entries in "users"
    await deleteAllTableEntries("users");
    console.log("All users deleted from table.");
    // populate "users" with sample data
    const usersToInsert =  [sampleUserA, sampleUserB, sampleUserC];
    await insertSampleData("users", usersToInsert);
}


// SCRIPT
reset_users();
