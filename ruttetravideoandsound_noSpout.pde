//Christian Attard
//2015 @ introwerks 

//Pierre Puentes
//2016 @ DRLZTN

//Libraries
import processing.video.*;
Capture video;                     
Movie movie;                        

import controlP5.*;
ControlP5 cp5;

import ddf.minim.*;
import ddf.minim.analysis.*;
Minim minim;
AudioInput in;                    
AudioPlayer song;                 
BeatDetect beat;                  
BeatListener bl;

// Image

PImage img;
String name = "aster";          
String type = "png";             
int count = int(random(666));
color col;
int c;

// Parameters

int musicMode=0;
// 0 -> No Music
// 1 -> Sound File
// 2 -> Microphone
int imageMode=2;
// 0 -> Image File
// 1 -> Video File
// 2 -> Camera

int space = 5;                     // Space between lines
float weight = 1;                  // Line weight
int zoom = 1;                      // Zoom image
int translatex = 0;                // translate the image if necesary
int translatey = 0;
float depthZ;                      // Depth
float Depth = 1.0;                 // Max value for slider

float kickSize;                    // Sound Kick variable

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
  smooth();

  // Working with external cámeras
  String[] cameras = Capture.list();            
  for (int i = 0; i < cameras.length; i++) {
    println(cameras[i]);
  }

  // Working with image file
  img = loadImage(name + "." + type);         

  // Working with Camera
  video = new Capture(this, cameras[0]);
  if (imageMode==2) {
    video.start();
  }

  // Working with video file
  movie = new Movie(this, "transit.mov");
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

  // Minim object and input
  minim = new Minim(this);
  // Microphone
  in = minim.getLineIn(1); 
  // Sound File
  song = minim.loadFile("Designer Drugs - Future Body.mp3", 2048);                                                 // Play song if you hit P

  // Beat detection
  beat = new BeatDetect(song.bufferSize(), song.sampleRate());      
  beat.setSensitivity(50);                                          

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

  // Kick size and what analyses
  kickSize = 0.1;
  bl = new BeatListener(beat, song);

  // Credits :v
  println("Christian Attard, 2015, introwerks");
  println("Pierre Puentes, 2016, DRLZTN");
}

void movieEvent(Movie m) {
  m.read();
}

void draw() {

  background(0);

  // Slider
  gui();

  // New size for the kick variable
  if ( beat.isKick() ) kickSize = 0.7;                      
  kickSize = constrain(kickSize * 0.95, 0.1, 0.7);

  // Changes depth depending on musicMode
  switch(musicMode) {
  case 0:
    depthZ=Depth;
    break;
  case 1:
    song.play();
    depthZ=Depth+kickSize;
    break;
  case 2:
    depthZ=Depth+in.right.get(1);
    break;
  }

  // Changes the image source depending on imageMode
  switch(imageMode) {
  case 0:
    pushMatrix();
    translate(translatex, translatey);
    for (int i = 0; i < img.width; i+=space) {            // You can change video. to img. or movie.
      beginShape();
      for (int j = 0; j < img.height; j+=space) {
        c = i+(j*img.width);
        col = img.pixels[c];
        stroke(red(col), green(col), blue(col), 255);
        strokeWeight(weight);
        noFill();
        vertex (i, j, (depthZ * brightness(col))-zoom);
      }
      endShape();
    }
    popMatrix();
    break;
  case 1:
    if (movie.available()) {
      movie.read();                                             // reads and updates video file pixels
      movie.loadPixels();
      pushMatrix();
      translate(translatex, translatey);
      for (int i = 0; i < movie.width; i+=space) {            // You can change video. to img. or movie.
        beginShape();
        for (int j = 0; j < movie.height; j+=space) {
          c = i+(j*movie.width);
          col = movie.pixels[c];
          stroke(red(col), green(col), blue(col), 255);
          strokeWeight(weight);
          noFill();
          vertex (i, j, (depthZ * brightness(col))-zoom);
        }
        endShape();
      }
      popMatrix();
    }
    break;
  case 2:
    if (video.available()) {
      video.read();                                             // reads and updates video file pixels
      video.loadPixels();
      pushMatrix();
      translate(translatex, translatey);
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
    }
    break;
  }
}

// Slider function for working with 3D
void gui() {
  hint(DISABLE_DEPTH_TEST);
  cp5.draw();
  hint(ENABLE_DEPTH_TEST);
}
