


function drawPicture(no,xStart,yStart,width,height) {
    let image = document.getElementById('picture'+no);
    let canvas = document.getElementById('canvas'+no);
    let ctx = canvas.getContext('2d');
    ctx.canvas.width  = width;
    ctx.canvas.height = height;
    ctx.drawImage(image,xStart,yStart,width,height,0,0,width,height);
}


//  onload="loadImage()"
