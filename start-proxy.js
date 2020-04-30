

const proxyUrlTarget = 'https://nxt3.staging.lizard.net/';
const portNumber = Number(process.env.PORT || 1234);
const bundlerStartingPoint = 'src/index.html';
const theseUrlPostFixesAreProxied = ['/api/v3'];

const options = {
  target: proxyUrlTarget,
  changeOrigin: proxyUrlTarget.indexOf('localhost') < 0, 
  logLevel: 'debug',
  "headers": {
    // if username password left '' will continue without credentials !
    "username": '', 
    "password": '',
  }
}

const Bundler = require('parcel-bundler');
const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const Prompt = require('prompt-password');

const usernamePrompt = new Prompt({
  type: 'username',
  message: 'Enter your username',
  name: 'username',
  mask: function(input) {
    return input;
  }
});
const passwordPrompt = new Prompt({
  type: 'password',
  message: 'Enter your password please (will be displayed as ***)',
  name: 'password',
});

console.log('Please enter credentials for ' + proxyUrlTarget + ' \n Leaving username or password empty will continue without credentials. ');
usernamePrompt.run()
.then (function(username){
  console.log('Use username: ' + username);
  passwordPrompt.run()
  .then(function(password) {
    // appearently they become undefined when using empty string
    if (username != undefined && password != undefined) {
      options.headers.username = username;
      options.headers.password = password;
    } else {
      console.log("Currently no username password used, because one of them was empty string ! \n Continue without credentials");
    }
    
    const app = express();
    theseUrlPostFixesAreProxied.forEach(function(urlPostfix){
      app.use(createProxyMiddleware(urlPostfix, options));
    })
    const bundler = new Bundler(bundlerStartingPoint);
    app.use(bundler.middleware());
    console.log('starting dev server at: http://localhost:' + portNumber )
    app.listen(portNumber);
  });
})


