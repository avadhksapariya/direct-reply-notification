// script.js file

function domReady(fn) {
    if (
        document.readyState === "complete" ||
        document.readyState === "interactive"
    ) {
        setTimeout(fn, 1000);
    } else {
        document.addEventListener("DOMContentLoaded", fn);
    }
}

domReady(function () {
    let selectedCameraId;
    let htmlscanner;

    // Function to handle successful QR code scans
    function onScanSuccess(decodeText, decodeResult) {
        alert("Your QR code is: " + decodeText);

        console.log("Scanned output: ", decodeText);
        window.parent.postMessage(decodeText, '*');
    }

    // Function to handle errors
    function onScanError(errorMessage) {
        console.error("Error during scanning: ", errorMessage);
    }

    // Start QR scanner with the selected camera
    function startScanner(cameraId) {
        if (htmlscanner) {
            htmlscanner.clear().catch(error => {
                console.error("Failed to clear QR scanner.", error);
            });
        }
        htmlscanner = new Html5QrcodeScanner(
            "my-qr-reader",
            { fps: 10, qrbox: 250 }
        );
        htmlscanner.render(onScanSuccess, onScanError, cameraId);

        // Disable the scan image file option
        htmlscanner.getUi().then(ui => {
            const scanTypeSwitch = ui.getElement("#html5-qrcode-anchor-scan-type-change");
            if (scanTypeSwitch) {
                scanTypeSwitch.style.display = "none";
                scanTypeSwitch.removeAttribute("href");
                scanTypeSwitch.addEventListener("click", (e) => {
                    e.preventDefault();
                    e.stopPropagation();
                });
            }
        }).catch(err => {
            console.error("Error accessing UI elements.", err);
        });
    }

    // Get cameras and initialize the scanner after permissions are granted
    Html5Qrcode.getCameras().then(cameras => {
        if (cameras && cameras.length) {
            selectedCameraId = cameras[0].id;
            startScanner(selectedCameraId);

            const cameraSwitchContainer = document.createElement("div");
            cameraSwitchContainer.style.marginTop = "10px";

            cameras.forEach(camera => {
                const button = document.createElement("button");
                button.textContent = camera.label || `Camera ${camera.id}`;
                button.style.marginRight = "5px";

                button.addEventListener("click", () => {
                    selectedCameraId = camera.id;
                    startScanner(selectedCameraId);
                });

                cameraSwitchContainer.appendChild(button);
            });

            document.querySelector(".container").appendChild(cameraSwitchContainer);
        } else {
            console.error("No cameras found.");
        }
    }).catch(err => {
        console.error("Error getting cameras.", err);
    });
});
