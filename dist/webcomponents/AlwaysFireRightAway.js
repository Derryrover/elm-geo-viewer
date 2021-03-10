class AlwaysFireRightAway extends HTMLElement {

  static get observedAttributes() { 
    return [
    "requeststate"
    ]; 
  }
  attributeChangedCallback(name, oldValue, newValue) {
    const self = this;
    switch (name) {
      case  "requeststate":
        if (newValue === "requested") {
          // this.setAttribute('requestState', "created");
          const dateTimeNowPosix = new Date().getTime(); // miliseconds since 1970
          // this.setAttribute('value', dateTimeNowPosix);
          const customEvent = new CustomEvent('created', {detail: dateTimeNowPosix});
          requestAnimationFrame(() => {
            self.dispatchEvent(customEvent);
          })
        } 
    }
  }

  constructor() {
    super();
  }
}

customElements.define('always-fire-right-away', AlwaysFireRightAway);