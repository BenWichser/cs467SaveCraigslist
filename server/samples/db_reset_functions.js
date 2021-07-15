/* db_reset_functions provides functions for reset functionality */
// REQUIREMENTS
const { ddbClient } = require("../libs/ddbClient.js");
const {
    deleteAllBucketObjects,
    uploadPhoto
} = require("./s3_reset_functions.js");
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

// FUNCTIONS
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


async function insertSampleData(tablename, entries) {
    /* insertSampleData
     * Inserts a set of entries into a specified table
     * Accepts:
     *  tablename (string): table into which we want to insert data
     *  entries (array of objects): items to insert
     * Returns:
     *  Nothing.  Specified table has entries added to it
     */
    const bucketSelector = {
        users: "savecraigslistusers",
        items: "savecraigslistitems",
        messages: "savecraigslistmessages"
    };
    const thisBucket = bucketSelector[[tablename]];
    await deleteAllBucketObjects(thisBucket);
    // go through the array of entries to be added, creating an insertion
    //  object for each one
    for(const entry of entries) {
        // empty appropriate photos
        var params = {
            TableName: tablename,
            Item:
            {
                // all entries must have an id
                id: {S: entry.id},
            }
        }
        // add in any other keys that are present
        const templateSelector = {
            "users": userTemplate, 
            "items": itemTemplate,
            "messages": messageTemplate
        };
        for(var field in entry)
            params.Item[ [field] ]   = { 
                [templateSelector[[tablename]][field]]: entry[field]};
        // redo password as hashed/salted password
        if ('password' in entry)
            params.Item.password = {
                S: await db.hashPassword(entry.password)
            };  
        
        // upload photo(s)
        if (tablename == 'users')
            // users version
        {
            const uploadParams = {
                Bucket: "savecraigslistusers",
                Key: entry.photo
            };
            // upload user photo
            await uploadPhoto(uploadParams);
        }
        else if (tablename == 'items')
        {
            // items version
            for (var photo of entry.photos)
            {
                const uploadParams = {
                    Bucket: "savecraigslistitems",
                    Key: photo.M.URL.S
                };
                // upload photo
                await uploadPhoto(uploadParams);
            }
        }
        // insert into table
        try {
            const data = await ddbClient.send(new PutItemCommand(params));
            console.log(`Added ${params.Item.id.S}.`);
        }
        catch (err)
        {
            console.log(`Error entering ${params.Item.id.S} -- `, err);
        }
    }
}


// EXPORTS
module.exports = {insertSampleData, deleteAllTableEntries};
