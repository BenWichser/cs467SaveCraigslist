/* Removes all entries in `users` table and adds the sample users */ 

// Required items and functions
const path = require("path");
const fs = require("fs");
const {
    sampleUserA, 
    sampleUserB, 
    sampleUserC
} = require("./sample_users.js");
const {
    insertSampleData,
    deleteAllTableEntries
} = require("./db_reset_functions.js");


// FUNCTION
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


// EXPORTS
module.exports = {reset_users};
