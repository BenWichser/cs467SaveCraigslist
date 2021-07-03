const express = require("express"),
  bodyParser = require("body-parser");
const router = express.Router();

router.use(bodyParser.json());

router.post('/', (req, res) => {
    res.status(201).send();
});

router.get('/', (req, res) => {
    res.status(200).json();
});

module.exports = router;
