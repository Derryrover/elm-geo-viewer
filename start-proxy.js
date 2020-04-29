const Bundler = require('parcel-bundler');
const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');

// function relayRequestHeaders(proxyReq, req) {
//   Object.keys(req.headers).forEach(function (key) {
//       proxyReq.setHeader(key, req.headers[key]);
//   });
// };

// function relayResponseHeaders(proxyRes, req, res) {
//   Object.keys(proxyRes.headers).forEach(function (key) {
//       res.append(key, proxyRes.headers[key]);
//   });
// };

const options = {
  target: 'https://nxt3.staging.lizard.net/',
  changeOrigin: true,
  // not needed
  // pathRewrite: { '/api/v3': '/api/v3' },
  logLevel: 'debug',
  // not needed
  // onProxyReq: relayRequestHeaders,
  // onProxyRes: relayResponseHeaders,
  "headers": {
    "username": "",
    "password": ""
  }
}

const password = process.env.PROXY_PASSWORD;
const username = process.env.PROXY_USERNAME;

if (password && username) {
  options.headers.username = username;
  options.headers.password = password;
} else {
  console.log("Currently no username password used !");
}

const app = express();

app.use(createProxyMiddleware('/api/v3', options));

const bundler = new Bundler('src/index.html');
app.use(bundler.middleware());

app.listen(Number(process.env.PORT || 1234));