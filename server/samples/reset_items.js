/* Removes all entries in `items` table and adds the sample items */ 

// Required items and functions
const {
    sampleItemA, 
    sampleItemB, 
    sampleItemC,
    sampleItemD
} = require("./sample_items.js");
const {
    insertSampleData,
    deleteAllTableEntries
} = require("./db_reset_functions.js");


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
