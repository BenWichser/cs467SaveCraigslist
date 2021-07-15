/* Removes all entries in all tables and repopulates them with sample data */

// Required items and functions
const {reset_items} = require("./reset_items.js");
const {reset_users} = require("./reset_users.js");
const {reset_messages} = require("./reset_messages.js");

// FUNCTION
async function reset_all() {
    /* reset_all
     * Deletes all entries in all tables and replaces with sample data
     * Accepts:
     *  Nothing
     * Returns:
     *  Nothing.  all tables are altered
     */
    await reset_items();
    console.log("DONE RESETTING ITEMS!!!");
    await reset_users();
    console.log("DONE RESETTING USERS!!!");
    await reset_messages();
    console.log("DONE RESETTING MESSAGES!!!");
}


// SCRIPT
reset_all();

