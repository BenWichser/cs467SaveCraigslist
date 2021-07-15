/* Removes all entries in `messages` table and adds the sample messages */ 

// Required items and functions
const {sampleMessages} = require("./sample_messages.js");
const {
    insertSampleData,
    deleteAllTableEntries
} = require("./db_reset_functions.js");


// FUNCTION
async function reset_messages() {
    /* reset_messages
     * Deletes all entries in "messages" and replaces with sample data
     * Accepts:
     *  Nothing
     * Returns:
     *  Nothing.  "messages" table is altered
     */
    // delete all entries in "messages"
    await deleteAllTableEntries("messages");
    console.log("All messages deleted from table.");
    // populate "messages" with sample data
    await insertSampleData("messages", sampleMessages);
}


// SCRIPT
reset_messages();

// EXPORTS
module.exports = {reset_messages}
