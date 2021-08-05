const express = require("express"),
//{ body, validationResult } = require("express-validator"),
//customValidation = require("../middleware"),
//db = require("../function"),
//aws = require("aws-sdk"),
{ v4: uuidv4 } = require("uuid"),
//_ = require("lodash"),
bodyParser = require("body-parser");
const router = express.Router();
const {PutObjectCommand} = require("@aws-sdk/client-s3");
const {getSignedUrl} = require("@aws-sdk/s3-request-presigner");
const {s3Client} = require("../libs/sampleClient.js");

router.use(bodyParser.json());

// Route for getting URL for photo upload from 
// https://github.com/GursheeshSingh/flutter-aws-s3-upload/blob/master/server.js
router.post(
  "/", async (req, res) =>  {
    // Check for correct file type
    const fileType = req.body.fileType.slice(1);
    if (fileType != 'jpg' && fileType != 'png' && fileType != 'jpeg')
    {
      return res.status(400).json({error: "Incorrect file type"});
    }
    const fileName = uuidv4();
    const bucketName = 'savecraigslist' + req.body.table;     //TODO: expand to be items or usersrs
    const params = {
        Bucket: bucketName,
        Key: fileName + "." + fileType,
        ACL: "public-read",
    };
    // Make URL with Bezos's Blessing
    //  https://aws.amazon.com/blogs/developer/generate-presigned-url-modular-aws-sdk-javascript/
    try {
        var command = new PutObjectCommand(params);
        var url = await getSignedUrl(
        s3Client, // credentials client
        command,    // create a "put" URL
        {expiresIn: 3600}               // valid for one hour
    );
    } catch (err) {
        console.log(`Error creating s3 URL for image ${params.Key} -- `, err);
        return res.end();
    }
    const returnData = {
        success: true,
        message: "URL generated",
        uploadUrl: url,
        fileName: fileName + "." + fileType,
        downloadUrl:
            `https://${bucketName}.s3.us-east-2.amazonaws.com/${fileName}.${fileType}`
    };
    res.status(201).json(returnData);
    }
   );


   module.exports = router