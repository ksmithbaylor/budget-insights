const express = require("express");
const cors = require("cors");
require("dotenv").config();

const app = express();

app.use(cors());

app.get("/token", (req, res) => {
  res.json({
    token: process.env.YNAB_TOKEN
  });
});

app.listen(4000);
