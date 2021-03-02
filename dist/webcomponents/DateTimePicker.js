function pad2(n) {  // always returns a string
  return (n < 10 ? '0' : '') + n;
}

function getUserTimeYYYYMMDDHHMM (date) {
  // seconds somehow does not work
  return `${date.getFullYear()}-${pad2(date.getMonth() + 1)}-${pad2(date.getDate())}T${pad2(date.getHours())}:${pad2(date.getMinutes())}`;//.${pad2(date.getSeconds())}`;
}
     

class DateTimePicker extends HTMLElement {

  static get observedAttributes() { 
    return [
    "posix"
    ]; 
  }
  async attributeChangedCallback(name, oldValue, newValue) {
    switch (name) {
      case  "posix":
        const intPosix = parseInt(newValue, 10);
        const date = new Date(intPosix);
        const valueStr = getUserTimeYYYYMMDDHHMM(date);
        console.log('valueStr', valueStr)

        this.dateTimeInput.setAttribute('value',valueStr);
    }

  }

  
  
  
  constructor() {
    // Always call super first in constructor
    super();
    

    const shadow = this.attachShadow({mode: 'open'});
    const input = document.createElement('input');
    shadow.appendChild(input);
    input.setAttribute('type','datetime-local');
    this.dateTimeInput = input;

    // console.log("this.getAttribute('value')",this.getAttribute('value'));
    // input.setAttribute('value','2020-10-29T10:00:00');

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
    
    const self = this;
    input.addEventListener("change", function (event) {
      // console.log('datetimepicker', event, event.target.value);
      const date = new Date(event.target.value);
      // const isoStr = date.toISOString();
      // console.log('isoStr', isoStr);
      const posix = date.getTime();
      
      const customEvent = new CustomEvent('valuechanged', {detail: posix});
      requestAnimationFrame(() => {
        // console.log("posix", posix);
        self.dispatchEvent(customEvent);
      })
    })
  }
}

customElements.define('datetime-picker', DateTimePicker);