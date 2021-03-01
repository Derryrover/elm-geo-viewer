class EmptyElement extends HTMLElement {  
  constructor() {
    // Always call super first in constructor
    super();
  }
}

customElements.define('empty-element', EmptyElement);