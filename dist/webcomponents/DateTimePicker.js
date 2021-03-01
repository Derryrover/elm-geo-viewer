class DateTimePicker extends HTMLElement {

  static get observedAttributes() { 
    return [
    "value"
    ]; 
  }
  async attributeChangedCallback(name, oldValue, newValue) {
    switch (name) {
      case  "value":
        this.dateTimeInput.setAttribute('value',newValue);
    }

  }

  
  
  
  constructor() {
    // Always call super first in constructor
    super();
    const self = this;

    const shadow = this.attachShadow({mode: 'open'});
    const input = document.createElement('input');
    shadow.appendChild(input);
    input.setAttribute('type','datetime-local');
    input.setAttribute('value','2020-10-29T10:00:00');
    this.dateTimeInput = input;

    // const dropDownStr = `
    //   <select>
    //     <option value="Idle">Idle</option>
    //     <option value="Requested">Requested</option>
    //     <option value="Created">Created</option>
    //     <option value="Reset">Reset</option>
    //   </select>
    // `;
    // const div = document.createElement('div');
    // shadow.appendChild(div);
    // div.setAttribute('class','status_dropdown');
    // div.innerHTML = dropDownStr;

    input.addEventListener("change", function (event) {
      // console.log('datetimepicker', event, event.target.value);
      const date = new Date(event.target.value);
      const isoStr = date.toISOString();
      // console.log('isoStr', isoStr);
      const customEvent = new CustomEvent('created', {detail: isoStr});
      this.dispatchEvent(customEvent);
    })
  }
}

customElements.define('datetime-picker', DateTimePicker);