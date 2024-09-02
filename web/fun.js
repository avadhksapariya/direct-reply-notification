function resFromJs() {
    console.log("Hello world from JS !")
}

function exposeJsQR() {
  if (typeof jsQR !== 'undefined') {
    window.jsQR = jsQR;
  } else {
    console.error('jsQR is not loaded');
  }
}

// Call the function to expose jsQR
exposeJsQR();
