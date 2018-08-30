const express = require('express');
const cors = require('cors');
const axios = require('axios');
const Cache = require('caching-map');
require('dotenv').config();

const app = express();

const ynabBaseUrl = 'https://api.youneedabudget.com/v1';

const cache = new Cache(Infinity);
const ttl = 60 * 60 * 1000; // one hour

app.use(cors());

app.get('/token', (req, res) => {
  res.json({
    token: process.env.YNAB_TOKEN,
  });
});

app.get('/ynab/*', (req, res) => {
  const path = req.path.slice(5);
  if (cache.has(path)) {
    const data = cache.get(path);
    console.log(`--- (cached) ${path}`);
    console.log(`             ╰─𝆓  ${JSON.stringify(data).length} bytes`);
    res.json(data);
  } else {
    console.log(`--- (miss)   ${path}`);
    console.log(`             │ Fetching from YNAB api...`);
    axios
      .get(ynabBaseUrl + path, {
        headers: {Authorization: req.header('Authorization')},
      })
      .then(response => {
        console.log(
          `             ╰─𝆓  ${JSON.stringify(response.data).length} bytes`,
        );
        cache.set(path, response.data, {ttl});
        res.json(response.data);
      })
      .catch(err => {
        console.error(err);
        res.json({message: 'unsuccessful request'});
      });
  }
});
app.listen(4000);
