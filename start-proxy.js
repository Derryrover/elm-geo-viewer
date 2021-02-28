const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const { personal_api_key }  = require('./personal_api_key');

 
const app = express();

app.use(express.static('dist'))
app.use('/api', createProxyMiddleware({ 
  target: 'https://nxt3.staging.lizard.net', 
  changeOrigin: true,
  auth: "__key__:"+personal_api_key
}));
app.listen(4000);
