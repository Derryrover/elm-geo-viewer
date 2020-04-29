const Bundler = require('parcel-bundler');
const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');

function relayRequestHeaders(proxyReq, req) {
  Object.keys(req.headers).forEach(function (key) {
      proxyReq.setHeader(key, req.headers[key]);
  });
};

function relayResponseHeaders(proxyRes, req, res) {
  Object.keys(proxyRes.headers).forEach(function (key) {
      res.append(key, proxyRes.headers[key]);
  });
};

const options = {
  target: 'https://nxt3.staging.lizard.net/',
  changeOrigin: true,
  // pathRewrite: { '/api/v3': '/api/v3' },
  logLevel: 'debug',
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
  console.log("Please set PROXY_PASSWORD and PROXY_USERNAME variables!");
  process.exit(1);
}

const app = express();

app.use(createProxyMiddleware('/api/v3', options));
// probably not a good idea since the login will be over http
// app.use(createProxyMiddleware('/api-auth/login', options))

const bundler = new Bundler('src/index.html');
app.use(bundler.middleware());

app.listen(Number(process.env.PORT || 1234));
// const Bundler = require('parcel-bundler');
// const express = require('express');
// const { createProxyMiddleware } = require('http-proxy-middleware');


// const app = express();

// app.use(createProxyMiddleware('/api', {
//   target: 'https://nxt3.staging.lizard.net/'
// }));

// const bundler = new Bundler('src/index.html');
// app.use(bundler.middleware());

// app.listen(Number(process.env.PORT || 1234));

// const proxy = require('http-proxy-middleware');
// const Bundler = require('parcel-bundler');
// const express = require('express');

// const bundler = new Bundler('src/index.html', {
//   // Don't cache anything in development 
//   cache: false,
// });

// const app = express();
// const PORT = process.env.PORT || 3000;

// // This route structure is specifc to Netlify functions, so 
// // if you're setting this up for a non-Netlify project, just use
// // whatever values make sense to you.  Probably something like /api/**

// app.use(
//   '/api',
//   proxy({
//     // Your local server
//     target: 'https://nxt3.staging.lizard.net/',
//     // Your production routes
//     // pathRewrite: {
//     //   '/.netlify/functions/': '',
//     // },
//   })
// );

// // Pass the Parcel bundler into Express as middleware
// app.use(bundler.middleware());

// // Run your Express server
// app.listen(PORT);