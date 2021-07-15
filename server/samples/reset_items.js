/* Removes all entries in `users` table and adds the new users */ 

// Required items and functions
const path = require("path");
const fs = require("fs");
const {
    sampleItemA, 
    sampleItemB, 
    sampleItemC,
    sampleItemD
} = require("./sample_items.js");
const { ddbClient } = require("../libs/ddbClient.js");
const { s3Client } = require("../libs/sampleClient.js");
const {
    userTemplate, 
    itemTemplate, 
    messageTemplate
} = require("../dbStructure.js");
const db = require("../function.js");
const {
    insertSampleData,
    deleteAllTableEntries
} = require("./db_reset_functions.js");
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



// FUNCTION
async function reset_items() {
    /* reset_items
     * Deletes all entries in "items" and replaces with sample data
     * Accepts:
     *  Nothing
     * Returns:
     *  Nothing.  "items" table is altered
     */
    // delete all entries in "items"
    await deleteAllTableEntries("items");
    console.log("All items deleted from table.");
    // populate "items" with sample data
    const itemsToInsert =  [sampleItemA, sampleItemB, sampleItemC, sampleItemD];
    await insertSampleData("items", itemsToInsert);
}


// SCRIPT
reset_items();

// EXPORTS
module.exports = {reset_items}
