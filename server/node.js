const express = require("express"),
  { body, validationResult } = require("express-validator"),
  { v4: uuidv4 } = require("uuid"),
  users = require("./routes/users.js"),
  items = require("./routes/items.js"),
  messages = require("./routes/messages.js"),
  db = require("./function"),
  crypt = require("bcrypt"),
  _ = require("lodash"),
  aws = require("aws-sdk"),
  customValidation = require("./middleware"),
  bodyParser = require("body-parser");

let session = require("express-session");
const hostname = "127.0.0.1";
const port = process.env.port || 8080;
const app = express();
const {PutObjectCommand} = require("@aws-sdk/client-s3");
const {getSignedUrl} = require("@aws-sdk/s3-request-presigner");
const {s3Client} = require("./libs/sampleClient.js");

app.set("trust proxy", 1);

app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());
app.use("/users", users);
app.use("/items", items);
app.use("/messages", messages);

app.use(
  session({
    genid: uuidv4,
    secret: "What is the airspeed velocity of a laden swallow?",
    resave: false,
    saveUninitialized: true,
    cookie: {},
  })
);

app.post(
  "/login",
  [body("username").exists(), body("password").exists()],
  customValidation.validate,
  async (req, res) => {
    let user = await db.getItem("users", req.body.username);
    if (_.isUndefined(user.Item)) {
      return res
        .status(400)
        .json({ error: "There is no such user in our system" });
    }
    const match = await crypt.compare(req.body.password, user.Item.password.S);

    if (match) {
      req.session.user = {
        username: user.Item.id.S,
        email: user.Item.email.S,
      };
    } else {
      return res.status(400).json({ error: "Incorrect password" });
    }
    user = aws.DynamoDB.Converter.unmarshall(_.omit(user.Item, "password"));
    console.log(`Logged in user ${req.body.username}`);
    return res.status(200).json(user);
  }
);

app.post("/logout", customValidation.isLoggedIn, (req, res) => {
  req.session.destroy();
  return res.status(200).send("Logged Out");
});

app.listen(port, () => {
  console.log(`App listening at http://${hostname}:${port}`);
});

// Route for getting URL for photo upload from 
// https://github.com/GursheeshSingh/flutter-aws-s3-upload/blob/master/server.js
app.post("/generatePresignedUrl", async (req, res) =>  {
  console.log('Entered generatePresignedUrl');
  // Check for correct file type
  const fileType = req.body.fileType.slice(1);
  if (fileType != 'jpg' && fileType != 'png' && fileType != 'jpeg')
  {
    return res.status(400).json({error: "Incorrect file type"});
  }
  const fileName = uuidv4();
  console.log(`This will be our filename ${fileName}`);
  const bucketName = 'savecraigslistitems';     //TODO: expand to be items or usersrs
  const params = {
      Bucket: bucketName,
      Key: fileName + "." + fileType,
      ACL: "public-read",
  };
  // Make URL with Bezos's Blessing
  //  https://aws.amazon.com/blogs/developer/generate-presigned-url-modular-aws-sdk-javascript/
  try {
      console.log("Going to try to make a PutObjectCommand");
      console.log(PutObjectCommand);
      var command = new PutObjectCommand(params);
      console.log("Made Put Object Command");
      var url = await getSignedUrl(
      s3Client, // credentials client
      command,    // create a "put" URL
      {expiresIn: 3600}               // valid for one hour
  );
  console.log(url);
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