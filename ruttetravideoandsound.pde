//Christian Attard
//2015 @ introwerks 

//Pierre Puentes
//2016 @ DRLZTN

//Libraries
import processing.video.*;
Capture video;                      // Camere
Movie movie;                        // Video File

import controlP5.*;
ControlP5 cp5;

import spout.*;
Spout spout;

import ddf.minim.*;
import ddf.minim.analysis.*;
Minim minim;
AudioInput in;                    // Input
AudioPlayer song;                 //Song
BeatDetect beat;                  // beat detection objects
BeatListener bl;

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

float kickSize;                    // variable for the size of the Kick

PGraphics pgr;                     // Spout graphics 

// BeatListener Class
class BeatListener implements AudioListener
{
  private BeatDetect beat;
  private AudioPlayer source;

  BeatListener(BeatDetect beat, AudioPlayer source)
  {
    this.source = source;
    this.source.addListener(this);
    this.beat = beat;
  }

  void samples(float[] samps)
  {
    beat.detect(source.mix);
  }

  void samples(float[] sampsL, float[] sampsR)
  {
    beat.detect(source.mix);
  }
}

void setup() {

  size(640, 480, P3D);
  pgr = createGraphics(1024, 768, P3D);
  smooth();

  // Working with external cámeras
  String[] cameras = Capture.list();            // Shows avaliable cameras
  for (int i = 0; i < cameras.length; i++) {
    println(cameras[i]);
  }

  //img = loadImage(name + "." + type);         // If you want to work with images...

  video = new Capture(this, cameras[0]);        // Captures video from selected camera
  video.start();
  movie = new Movie(this, "transit.mov");       // starts video file
  movie.loop();

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

  // Minim object and input
  minim = new Minim(this);
  in = minim.getLineIn(1);                                        // If you want to work with the mic
  song = minim.loadFile("Designer Drugs - Future Body.mp3", 2048);  // Loads the song from the data folder                                                // Play song if you hit P
  song.play();
  beat = new BeatDetect(song.bufferSize(), song.sampleRate());      // creates the beat detectionm
  beat.setSensitivity(50);                                          // Beat detection sensivity

  /* INFO FROM THE MINIM LIBRARIE EXAMPLE
   
   Set the sensitivity to 50 milliseconds
   After a beat has been detected, the algorithm will wait for 50 milliseconds 
   before allowing another beat to be reported. You can use this to dampen the 
   algorithm if it is giving too many false-positives. The default value is 10, 
   which is essentially no damping. If you try to set the sensitivity to a negative value, 
   an error will be reported and it will be set to 10 instead. 
   note that what sensitivity you choose will depend a lot on what kind of audio 
   you are analyzing. in this example, we use the same BeatDetect object for 
   detecting kick, snare, and hat, but that this sensitivity is not especially great
   for detecting snare reliably (though it's also possible that the range of frequencies
   used by the isSnare method are not appropriate for the song).
   
   */

  kickSize = 0.1;
  bl = new BeatListener(beat, song);                                // This says what is going to analyse

  // Credits :v
  println("Christian Attard, 2015, introwerks");
  println("Pierre Puentes, 2016, DRLZTN");
}

void movieEvent(Movie m) {
  m.read();
}

void draw() {

  if (video.available()) {                                    // Use this if you want to work with cam
  //if(movie.available()){                                   // Use this if you want to work with a video file                         
    background(0);

    video.read();                                             // reads and updates camera pixels
    video.loadPixels();

    movie.read();                                             // reads and updates video file pixels
    movie.loadPixels();

    if ( beat.isKick() ) kickSize = 0.7;                      // Set the new size for the kick variable
    kickSize = constrain(kickSize * 0.95, 0.1, 0.7);

    //depthZ=Depth+in.right.get(1);                         // Using the mic
    depthZ=Depth+kickSize;                                  // Using with a File
    //depthZ=Depth;                                         // No music    

    pushMatrix();
    translate(0, 0);
    for (int i = 0; i < video.width; i+=space) {            // You can change video. to img. or movie.
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