// 'use strict';

// require("./styles.scss");

// const {Elm} = require('./Main');
// var app = Elm.Main.init({flags: 6});


// // Use ES2015 syntax and let Babel compile it for you
// var testFn = (inp) => {
//     let a = inp + 1;
//     return a;
// }
// above requires webpack

import { Elm } from './Main.elm'

const app = Elm.Main.init({
  node: document.querySelector('main'),
  // flags: 6
})

// app.ports.toJs.subscribe(data => {
//     console.log(data);
// })

// app.ports.localDateTimePosix.subscribe(data => {
//     console.log(data);
//     const dateTimeObj = new Date(data);
//     console.log(dateTimeObj);
//     const posix = dateTimeObj.getTime();
//     console.log(posix);
//     app.ports.receivePosixFromDate.send(posix);
// })