var url = app.scriptArgs.getValue("url") || "www.allianz.de";
var boxName = app.scriptArgs.getValue("boxName") || "qrcode_bub";
var color = app.scriptArgs.getValue("color") || "C=0 M=0 Y=0 K=88";
var censhareTargetDocument = app.scriptArgs.getValue("censhareTargetDocument");
var targetDocument;

if (censhareTargetDocument != "") {
    targetDocument = app.documents.itemByID(parseInt(censhareTargetDocument));
}
else {
    targetDocument = app.documents.item(0);
}

try {
    var frame = getQrBoxItem();
    if (frame && url) {
        frame.createHyperlinkQRCode(url, color);
    }
}
catch ( error ) {
	app.scriptArgs.setValue( "censhareResult", " failure: " + error.toString() );
}

function getQrBoxItem() {
    var allItems = targetDocument.allPageItems;
    var result;
    for (i = 0; i < allItems.length; i++) {
        if (allItems[i].name == boxName) {
            result = allItems[i];
        }
    }
    return result;
}
