class ShowNoShow extends HTMLElement {
  // connectedCallback() {
  //   // const classproperty = this.getAttribute('classproperty');
  //   // console.log("classproperty", classproperty);
  //   const clas = this.getAttribute('class');
  //     console.log("clas", clas)
  // }

  static get observedAttributes() { 
    return [
    // 'attributeclass', 'class'
    "show"
    ]; 
  }
  attributeChangedCallback(name, oldValue, newValue) {
    // console.log(`Value changed from ${oldValue} to ${newValue}`);


    const totalAnimationTimeStr = getComputedStyle(document.body).getPropertyValue("--transition-complete-time");
    // console.log("totalAnimationTime 23", totalAnimationTimeMs);
    const totalAnimationTimeMs = 1000 * (parseInt(totalAnimationTimeStr.replace("s", "")));


    switch (name) {
      // case 'class':
      //   console.log(`Value changed from ${oldValue} to ${newValue}`);
      //   break;
      // case 'attributeclass':
      //   console.log(`Value changed from ${oldValue} to ${newValue}`);
      //   break;
      case  "show":
        console.log(`Value changed from ${oldValue} to ${newValue}`);
        if (newValue === "true") {
          this.setAttribute('class', "show show_animate");
          window.setTimeout(()=>{
            if (this.getAttribute('class').split(" ").includes("show")) {
              this.setAttribute('class', "show");
            }
          }, totalAnimationTimeMs);
        } else if (newValue === "false") {
          this.setAttribute('class', "noshow noshow_animate");
          window.setTimeout(()=>{
            if (this.getAttribute('class').split(" ").includes("noshow")) {
              this.setAttribute('class', "noshow");
            }
          }, totalAnimationTimeMs)
        }
    }

    // const totalAnimationTime = getComputedStyle(document.documentElement)
    // // .getPropertyValue('--transition-complete-time'); // #999999
    // .getPropertyValue("--transition-time-fade-out");
    // console.log("totalAnimationTime", totalAnimationTime)
  }

  
  
  constructor() {
    // Always call super first in constructor
    super();
    console.log('constructor');

    // const totalAnimationTime = getComputedStyle(document.documentElement).getPropertyValue('--transition-complete-time'); // #999999
    // console.log("totalAnimationTime", totalAnimationTime)
    // Create a shadow root
    // var shadow = this.attachShadow({mode: 'open'});

    // Create spans
    // var wrapper = document.createElement('div');
    // wrapper.setAttribute('class','wrapper');
    // wrapper.innerHTML = "New text!";

    // const classesString = this.getAttribute('class');
    // console.log("classesString",classesString, this.className);

    // // if(this.hasAttribute('classproperty')) {
    //   const classProperty = this.getAttribute('classproperty');
    //   console.log("classproperty", classproperty)
    // // }
    // var icon = document.createElement('span');
    // icon.setAttribute('class','icon');
    // icon.setAttribute('tabindex', 0);
    // var info = document.createElement('span');
    // info.setAttribute('class','info');

    // // Take attribute content and put it inside the info span
    // var text = this.getAttribute('data-text');
    // info.textContent = text;

    // // Insert icon
    // var imgUrl;
    // if(this.hasAttribute('img')) {
    //   imgUrl = this.getAttribute('img');
    // } else {
    //   imgUrl = 'img/default.png';
    // }
    // var img = document.createElement('img');
    // img.src = imgUrl;
    // icon.appendChild(img);

    // Create some CSS to apply to the shadow dom
    // var style = document.createElement('style');

    // style.textContent = '.wrapper {' +
    // // CSS truncated for brevity

    // attach the created elements to the shadow dom

    // shadow.appendChild(style);

    // shadow.appendChild(wrapper);
    // this.appendChild(wrapper);

    // wrapper.appendChild(icon);
    // wrapper.appendChild(info);
  }
}

customElements.define('show-noshow', ShowNoShow);