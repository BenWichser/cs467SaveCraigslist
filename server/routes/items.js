const express = require("express"),
  bodyParser = require("body-parser");
const router = express.Router();

router.use(bodyParser.json());

router.post('/', (req, res) => {
    res.status(201).send();
});

router.get('/', (req, res) => {
    res.status(201).json();
});

router.get('/:item_id', (req, res) => {
    res.status(201).json();
});

router.put('/:item_id', (req, res) => {
    res.status(200).send();
});

router.delete('/:item_id', (req, res) =>{
    res.status(204).send();
});

module.exports = router;
