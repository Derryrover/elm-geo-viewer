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
target: 'https://nxt3.staging.lizard.net/api/v3/',
changeOrigin: true,
pathRewrite: { '/api/v3': '' },
logLevel: 'debug',
// onProxyReq: relayRequestHeaders,
// onProxyRes: relayResponseHeaders,
}

const app = express();

app.use(createProxyMiddleware('/api/v3', options));

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