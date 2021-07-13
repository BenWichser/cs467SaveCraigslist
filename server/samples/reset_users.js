/* Removes all entries in `users` table and adds the new users */ 

// Required items and functions
const {
    sampleUserA, 
    sampleUserB, 
    sampleUserC
} = require("./sample_users.js");
const { ddbClient } = require("../libs/ddbClient.js");
const {
    userTemplate, 
    itemTemplate, 
    messageTemplate
} = require("../dbStructure.js");
const {
    DeleteItemCommand,
    PutItemCommand,
    ScanCommand,
} = require("@aws-sdk/client-dynamodb");


// Functions
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
        console.log(data);
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
            console.log(`Successfully scanned ${tablename}:`);
            data.Items.forEach(element => 
                console.log(JSON.stringify(element)));
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
            break;
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
    // go through the array of entries to be added, creating an insertion
    //  object for each one
    for(const entry of entries) {
        var params = {
            TableName: tablename,
            Item:
            {
                // all entries must have an id
                id: {S: entry.id}
            }
        }
        // add in any other keys that are present
        console.log(entry);
        for(var field in entry) {
            const newKey = userTemplate[field];
            const newValue = entry[field];
            params.Item[ [field] ]   = { [newKey]: newValue};
        }
        // insert into table
        try {
            console.log(params);
            const data = await ddbClient.send(new PutItemCommand(params));
            console.log("Added User");
            console.log(data);
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
    // populate "users" with sample data
    const usersToInsert =  [sampleUserA, sampleUserB, sampleUserC];
    await insertSampleData("users", usersToInsert);
}


// SCRIPT
reset_users();
