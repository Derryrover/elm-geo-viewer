npm install  
npm start  
  
requires npm to be installed  
requires elm 0.19.1 to be installed  
Probably requires parcel 1 to be installed (not sure if npm handles this) https://parceljs.org/  
  
"npm start" starts a proxy dev server with express and http-proxy-middleware  
Then the proxy is called with Parcel1 (our bundler).  

The project itself is written in Elm (elm-lang.org)  
It is an attempt to create a mapbackground viewer using a tiled approach ( like most mapviewers).  
Parcel handles the bundling of Elm and also the start of the elm state debugger without configuration (wow!).  
In Main.elm there is still some code from when I used webpack. But this can be gradually removed.  

