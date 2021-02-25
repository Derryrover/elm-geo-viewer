class AlwaysFireRightAway extends HTMLElement {

  static get observedAttributes() { 
    return [
    "requeststate"
    ]; 
  }
  attributeChangedCallback(name, oldValue, newValue) {
    switch (name) {
      case  "requeststate":
        if (newValue === "requested") {
          this.setAttribute('requestState', "created");
          const dateTimeNowPosix = new Date().getTime(); // miliseconds since 1970
          this.setAttribute('value', dateTimeNowPosix);
          const customEvent = new CustomEvent('created', {detail: dateTimeNowPosix});
          this.dispatchEvent(customEvent);
        } else if (newValue === "reset") {
          this.setAttribute('requestState', "idle");
          this.setAttribute('value', "");
        }
    }
  }

  constructor() {
    super();
  }
}

customElements.define('always-fire-right-away', AlwaysFireRightAway);