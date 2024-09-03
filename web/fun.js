function resFromJs() {
    console.log("Hello world from JS !")
}

function exposeJsQR() {
  window.jsQR = jsQR;
}

// Call the function to expose jsQR
exposeJsQR();
