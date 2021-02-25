class FilesystemapiOpenfolder extends HTMLElement {

  static get observedAttributes() { 
    return [
    "requeststate"
    ]; 
  }
  async attributeChangedCallback(name, oldValue, newValue) {
    switch (name) {
      case  "requeststate":
        if (newValue === "requested") {
          const directoryhandle =  this.directoryHandle;
          const filename = this.getAttribute('filename')
          const newFileHandle = await directoryhandle.getFileHandle(filename || "defaultfilename", { create: true });
          this.setAttribute('requestState', "created");
          const customEvent = new CustomEvent('created', {file: newFileHandle});
          this.dispatchEvent(customEvent);

          
        } else if (newValue === "reset") {
          this.setAttribute('requestState', "idle");
        }
    }

  }

  
  
  
  constructor() {
    // Always call super first in constructor
    super();
    this.directoryHandle = null;
    const self = this;

    const shadow = this.attachShadow({mode: 'open'});
    const button = document.createElement('button');
    shadow.appendChild(button);
    button.setAttribute('class','button_choose_folder');
    button.innerHTML = "Chose folder";

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

    button.addEventListener("click", async function () {
      window.showDirectoryPicker().then( async function (dirHandle) {
        self.directoryHandle = dirHandle;
        const customEvent = new CustomEvent('folderchosen', {detail: ""});//{ target: { value: newUuid }});
        self.dispatchEvent(customEvent);
        // for await  (const entry of dirHandle.values()) {
        //   console.log(entry.kind, entry.name);
        // }
        const fileIter = dirHandle.values();
        let containerItem = await fileIter.next();
        while (!containerItem.done) {
          console.log(containerItem.value.kind, containerItem.value.name);
          containerItem = await fileIter.next();
        }
        // const permission = await verifyPermission(dirHandle, true);
        // In this new directory, create a file named "My Notes.txt".
        try {
          const newFileHandle = await dirHandle.getFileHandle('MyNotes_2132.txt', { create: true });
        } catch (error) {
          console.log(error, error.name)
        }
      }).catch((error)=>{
        console.log('choosing folder failed because error', error)
      });
        
    })
    
    
    
    
  }
}

customElements.define('filesystemapi-openfolder', FilesystemapiOpenfolder);