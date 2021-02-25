class RequestAnimFrame extends HTMLElement {

  // static get observedAttributes() { 
  //   return [
  //   "requeststate"
  //   ]; 
  // }
  // attributeChangedCallback(name, oldValue, newValue) {
  //   switch (name) {
  //     case  "requeststate":
  //       if (newValue === "requested") {
  //         this.setAttribute('requestState', "created");
  //         const dateTimeNowPosix = new Date().getTime(); // miliseconds since 1970
  //         this.setAttribute('value', dateTimeNowPosix);
  //         const customEvent = new CustomEvent('created', {detail: dateTimeNowPosix});
  //         this.dispatchEvent(customEvent);
  //       } else if (newValue === "reset") {
  //         this.setAttribute('requestState', "idle");
  //         this.setAttribute('value', "");
  //       }
  //   }
  // }

  constructor() {
    super();
    const that = this;
    that.currentTime = 0;

    function step(timestamp) {
      if (that.currentTime == 0) {
        const customEvent = new CustomEvent('created', {detail: 0});
        that.dispatchEvent(customEvent);
      } else {
        const customEvent = new CustomEvent('created', {detail: timestamp - that.currentTime});
        that.dispatchEvent(customEvent);
      }
      that.currentTime = timestamp;
      if (document.body.contains(that)) {
        window.requestAnimationFrame(step);
      }
      
    }
    
    window.requestAnimationFrame(step);
  }
}

customElements.define('requestanimframe-component', RequestAnimFrame);