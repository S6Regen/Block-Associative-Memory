// Vector to vector associative memory using a Locality Sensitive Hash (LSH.)
class AM {
  // vecLen must be 2,4,8,16,32.....
  constructor(vecLen, density,blockBits, hash) {
    this.vecLen = vecLen;	// input output vector length
    this.density = density; // affects capacity, speed and accuracy
    this.blockBits=blockBits; // affects capacity. log_2 of number of vector weight blocks
    this.blockCt=1<<blockBits;  // number of vector blocks per density index
    this.hash = hash;		 
    this.workA = new Float32Array(vecLen);
    this.workB = new Float32Array(vecLen);
    this.indexes=new Int32Array(density); // which vector blocks to use
    this.lsh=[];	// avoid recalculation of LSH signs
    this.weights =[];
    for(let i=0;i<density;i++){
		this.lsh.push(new Int8Array(vecLen));
		let db=[];
		for(let j=0;j<this.blockCt;j++){
		  db.push(new Float32Array(vecLen)); // make array of vector blocks
		}
		this.weights.push(db);
    }
  }
  
  recall(result, input) {
    copyVec(this.workA, input);
    zeroVec(result);
    for (let i = 0; i < this.density; i++) {
      rpVec(this.workA, this.hash+i); // random projection
      let index=extractIndex(this.workA,this.blockBits); //index into vector blocks by second LSH
      this.indexes[i]=index;
      for (let j = 0; j < this.vecLen; j++) {
         this.lsh[i][j] = this.workA[j] < 0 ? -1 : 1; // LSH bit
       } 
       multiplyAddToVec(result,this.lsh[i],this.weights[i][index]); //selected weight block by
    }																 // LSH (+1,-1) of input
  }

  train(target, input) {
    this.recall(this.workB, input); //Recall and store LSH
    subtractVec(this.workB, target, this.workB); // error vector
    scaleVec(this.workB, this.workB, 1 / this.density); //scale correctly before distributing over the weights
    for (let i = 0; i < this.density; i++) {
	    multiplyAddToVec(this.weights[i][this.indexes[i]],this.lsh[i],this.workB);
    }
  }

  clear() {
    for (let i = 0; i < this.density; i++) {
		for(let j=0;j<this.blockCt;j++){
			zeroVec(this.weights[i][j]);
        }
    }
  }
}
// Functions for associative memory (AM) class.
// Fast Walsh Hadamard Transform
function whtVec(vec) {
  let n = vec.length;
  let hs = 1;
  while (hs < n) {
    let i = 0;
    while (i < n) {
      const j = i + hs;
      while (i < j) {
        var a = vec[i];
        var b = vec[i + hs];
        vec[i] = a + b;
        vec[i + hs] = a - b;
        i += 1;
      }
      i += hs;
    }
    hs += hs;
  }
  scaleVec(vec, vec, 1.0 / Math.sqrt(n));
}

// Pseudorandom sign flip of elements of vec based on hash value.
// Used with WHT to create fast invertible random projections.
function signFlipVec(vec, hash) {
  for (let i = 0, n = vec.length; i < n; i++) {
    hash += 0x3C6EF35F;
    hash *= 0x19660D;
    hash &= 0xffffffff;
    if (((hash * 0x9E3779B9) & 0x80000000) === 0) {
      vec[i] = -vec[i];
    }
  }
}

// Fast random projection
function rpVec(vec, hash) {
  signFlipVec(vec, hash);
  whtVec(vec);
}

function scaleVec(rVec, xVec, sc) {
  for (let i = 0, n = rVec.length; i < n; i++) {
    rVec[i] = xVec[i] * sc;
  }
}

// r=x-y
function subtractVec(rVec, xVec, yVec) {
  for (let i = 0, n = rVec.length; i < n; i++) {
    rVec[i] = xVec[i] - yVec[i];
  }
}

function multiplyAddToVec(rVec, xVec, yVec) {
  for (let i = 0, n = rVec.length; i < n; i++) {
    rVec[i] += xVec[i] * yVec[i];
  }
}

function copyVec(rVec, xVec) {
  for (let i = 0, n = rVec.length; i < n; i++) {
    rVec[i] = xVec[i];
  }
}

function zeroVec(x) {
  for (let i = 0, n = x.length; i < n; i++) {
    x[i] = 0;
  }
}

// select which weight vector block to use, again by locality sensitive hash of input
function extractIndex(vec,nBits){
  let res=0;
  for(let i=0;i<nBits;i++){
	  if(vec[i]>=0.0){
	    res |=1<<i;
	  }
   }
   return res;
}
  

// Example useage of the associative memory

let vec = new Float32Array(4096);
let am = new AM(4096, 10,3, 0); // capacity=10*(2^3)=80
let img;
let view;
let trainingData = [];
let training = false;
let trainingCount = 0;

function preload() {
  img = loadImage('Lübeck.jpg');
}

function setup() {
  createCanvas(800, 600);
  view=createImage(32,32);
  view.loadPixels();
}

function draw() {
  if (trainingData.length === 0) {
    background('grey');
  }
  image(img, 0, 0);
  if (training) {
    trainingCount++;
    fill(255);
    strokeWeight(10);
    textSize(30);
    text('Training Cycles:' + trainingCount, 5, 30);
    for (var i = 0; i < trainingData.length; i++) {
      am.train(trainingData[i], trainingData[i]);
    }
    return;
  }
  noFill();
  strokeWeight(1);
  if (mouseX < 600 - 33 && mouseY < 400 - 33) {
    square(mouseX - 1, mouseY - 1, 34);
  }
    getData(vec, mouseX, mouseY);
    am.recall(vec, vec);
    setData(vec);
    image(view,10,420,128,128);
}

function mouseClicked() {
  if (trainingData.length < 32) { // new training square   
    let x = trainingData.length;
    let y = int(x / 4);
    x %= 4;
    let sub = get(mouseX, mouseY, 32, 32);
    set(620+x * 40, y * 40 + 10, sub);
    let d = new Float32Array(4096);
    getData(d, mouseX, mouseY);
    trainingData.push(d);
  }
}

function keyPressed() {
  if (keyCode === 49) { // 1  train
    if (training) {
      training = false;
    } else {
      training = trainingData.length > 0;
      trainingCount = 0;
    }
  }
  if (keyCode === 48) { // 0 delete training squares
    trainingData = [];
    am.clear();
  }
}

function getData(d, x, y) {
  let idx = 0;
  for (let px = 0; px < 32; px++) {
    for (let py = 0; py < 32; py++) {
      let c = get(x + px, y + py);
      d[idx++] = red(c) - 127.5;
      d[idx++] = green(c) - 127.5;
      d[idx++] = blue(c) - 127.5;
      d[idx++] = 0;
    }
  }
}

function setData(d) {
  let idx = 0;
  for (let px = 0; px < 32; px++) {
    for (let py = 0; py < 32; py++) {
      let r = constrain(d[idx++] + 127.5, 0, 255);
      let g = constrain(d[idx++] + 127.5, 0, 255);
      let b = constrain(d[idx++] + 127.5, 0, 255);
      idx++;
      view.set(px,py, color(r, g, b));
    }
  }
  view.updatePixels();
}


