//Christian Attard
//2015 @ introwerks 

//Pierre Puentes
//2016 @ DRLZTN

//Libraries
import processing.video.*;
Capture video;

import controlP5.*;
ControlP5 cp5;

import spout.*;
Spout spout;

// Working with images (JPG, PNG, ect)

PImage img;
String name = "pintura";           //file name 
String type = "jpg";               //file type
int count = int(random(666));
color col;
int c;

// Lines parameters

int space = 5;                     // space between lines
float weight = 1;                  // line weight
int zoom = 1;                      // zoom image
float depthZ;                      // z depth
float Depth = 1.0;                 // max value for the slider

PGraphics pgr;                     // Spout graphics 

void setup() {

  size(640, 480, P3D);
  pgr = createGraphics(1280, 720, P3D);

  // Working with external cámeras
  String[] cameras = Capture.list();            // Shows avaliable cameras
  for (int i = 0; i < cameras.length; i++) {
    println(cameras[i]);
  }

  //img = loadImage(name + "." + type);         // If you want to work with images...

  video = new Capture(this, cameras[0]);        // Captures video from selected camera
  video.start();  

  // Depth control slider
  cp5 = new ControlP5(this);
  cp5.addSlider("Depth")
    .setRange(0.0, 1)
    .setValue(0.0)
    .setPosition(20, height-30)
    .setSize(100, 10)
    ;
  cp5.setAutoDraw(false);

  // Spout object and sender
  spout = new Spout(this);
  spout.createSender("Rutt");
  
  // Credits :v
  println("Christian Attard, 2015, introwerks");
  println("Pierre Puentes, 2016, DRLZTN");
}

void draw() {

  if (video.available()) {
    background(0);

    video.read();
    video.loadPixels();

    depthZ=Depth;

    pushMatrix();
    translate(0, 0);
    for (int i = 0; i < video.width; i+=space) {            // If you want to work with image, change video. to img.
      beginShape();
      for (int j = 0; j < video.height; j+=space) {
        c = i+(j*video.width);
        col = video.pixels[c];
        stroke(red(col), green(col), blue(col), 255);
        strokeWeight(weight);
        noFill();
        vertex (i, j, (depthZ * brightness(col))-zoom);
      }
      endShape();
    }
    popMatrix();
    gui();                                                  // Draws the slider
  }
  spout.sendTexture();                                      // Sends image via Spout
}

// Slider function for working with 3D
void gui() {
  hint(DISABLE_DEPTH_TEST);
  cp5.draw();
  hint(ENABLE_DEPTH_TEST);
}

// If you want to save the image, press S
void keyPressed() {
  if (key=='s') {
    save(name + "_" + count + "." + type);
  }
}