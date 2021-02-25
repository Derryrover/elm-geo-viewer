import { nanoid } from '../web_modules/nanoid.js';

// function eventFire(el, etype){
//   if (el.fireEvent) {
//     el.fireEvent('on' + etype);
//   } else {
//     var evObj = document.createEvent('Events');
//     evObj.initEvent(etype, true, false);
//     el.dispatchEvent(evObj);
//   }
// }

class UuidGenerator extends HTMLElement {

  static get observedAttributes() { 
    return [
    "requeststate"
    ]; 
  }
  attributeChangedCallback(name, oldValue, newValue) {
    console.log(`1 Value changed from ${oldValue} to ${newValue}`);

    switch (name) {
      case  "requeststate":
        
        if (newValue === "requested") {
          console.log(`123 Value changed from ${oldValue} to ${newValue}`, this);
          const newUuid = nanoid();
          const customEvent = new CustomEvent('created', {detail: newUuid});//{ target: { value: newUuid }});
          this.setAttribute('requestState', "created");
          this.setAttribute('uuid', newUuid);
          this.dispatchEvent(customEvent);

          // const button = this.shadow.getElementById("button_choose_folder");
          // console.log("uuid button", button)
          // // eventFire(button, "click");
          // button.click();

          // const loadEvent = new Event("load"); 
          // this.dispatchEvent(loadEvent);
          // console.log("preevent");
          // const event2 = new MouseEvent('click', {
          //   view: window,
          //   bubbles: true,
          //   cancelable: true
          // });
          // console.log("preevent 2");
          
          // this.dispatchEvent(event2);
          // console.log("preevent 3");

        } else if (newValue === "reset") {
          this.setAttribute('requestState', "idle");
          this.setAttribute('uuid', "");
          // this.dispatchEvent(customEvent);
        }
    }

  }

  
  
  constructor() {
    // Always call super first in constructor
    super();
    // console.log('constructor uuid generator');
    // const shadow = this.attachShadow({mode: 'open'});
    // this.shadow = shadow;
    // const button = document.createElement('button');
    // shadow.appendChild(button);
    // button.setAttribute('id','button_choose_folder');
    // button.innerHTML = "uuid";

    // const customEvent = new CustomEvent('uuidcreated', { target: { value: "1233" }});
    // this.dispatchEvent(customEvent);
    
    // var wrapper = document.createElement('button');
    // wrapper.setAttribute('class','wrapper');
    // wrapper.innerHTML = '<input type="text"></input>';
    // this.appendChild(wrapper);
    this.addEventListener('created', function (e) {
      console.log("Element uuid  got event created: ", e.detail, e);
    }, false, true);
    
    // const loadEvent = new Event("load"); 
    // this.dispatchEvent(loadEvent);
    // button.click();

    // const newUuid = nanoid();
    // // this.setAttribute('requestState', "created");
    // // this.setAttribute('uuid', newUuid);
    // const customEvent = new CustomEvent('created', {detail: newUuid});//{ target: { value: newUuid }});
    // this.dispatchEvent(customEvent);
    
  }
}

customElements.define('uuid-generator', UuidGenerator);