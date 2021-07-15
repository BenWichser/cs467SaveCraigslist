/* s3_reset_functions
 * Functions for resetting s3 bucket for sample data needs
 */

// INCLUDES
const path = require("path");
const fs = require("fs");
const { s3Client } = require("../libs/sampleClient.js");
const db = require("../function");
const {
    DeleteObjectCommand,      // Delete Object in s3 bucket
    GetObjectCommand,        // Download Object in s3 bucket
    ListObjectsCommand,      // List items in s3 bucket      
    PutObjectCommand,        // Place item in S3 bucket
} = require("@aws-sdk/client-s3");

// FUNCTIONS
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

async function uploadPhoto(params){
    /* uploadPhoto
     * Uploads sample photo into S3
     *  correct photo location.
     * Accepts:
     *  params (object): parameters we created for upload
     * Returns:
     *  Nothing.  Modifies s3 bucket.
     */
    // create upload parameters
    const file = "./photos/" +  params.Key;
    const filestream = fs.createReadStream(file);
    params.Body = filestream;
    // Upload file to specified bucket.
    try {
        const data = await s3Client.send(new PutObjectCommand(params));
        console.log(`Success uploading image for ${params.Key}`);
        return data; // For unit tests.
    } catch (err) {
        console.log(`Error uploading image for ${params.Key}`, err);
    }
};

// EXPORTS
module.exports = {
    listAllBucketObjects, 
    deleteAllBucketObjects, 
    uploadPhoto
}

