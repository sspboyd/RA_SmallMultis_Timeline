import processing.pdf.*;

//Declare Globals
int rSn; // randomSeed number. put into var so can be saved in file name. defaults to 47
final float PHI = 0.618033989;

// Declare Font Variables
PFont mainTitleF;

boolean PDFOUT = false;

// Declare Positioning Variables
float margin;
float PLOT_X1, PLOT_X2, PLOT_Y1, PLOT_Y2, PLOT_W, PLOT_H;


/*////////////////////////////////////////
 SETUP
 ////////////////////////////////////////*/

void setup() {
  background(255);
  if (PDFOUT) {
    size(800, 450, PDF, generateSaveImgFileName(".pdf"));
  }
  else {
    size(800, 450); // quarter page size
  }

  margin = width * pow(PHI, 6);
  println("margin: " + margin);
  PLOT_X1 = margin;
  PLOT_X2 = width-margin;
  PLOT_Y1 = margin;
  PLOT_Y2 = height-margin;
  PLOT_W = PLOT_X2 - PLOT_X1;
  PLOT_H = PLOT_Y2 - PLOT_Y1;


  rSn = 47; // 29, 18;
  randomSeed(rSn);

  mainTitleF = createFont("Helvetica", 18);  //requires a font file in the data folder?

  println("setup done: " + nf(millis() / 1000.0, 1, 2));
}

void draw() {
  background(255);
  fill(0);
  textFont(mainTitleF);
  text("sspboyd", PLOT_X1, PLOT_Y1);


  if (PDFOUT) exit();
}

void keyPressed() {
  if (key == 'S') screenCap(".tif");
}

void mousePressed() {
}

String generateSaveImgFileName(String fileType) {
  String fileName;
  // save functionality in here
  String outputDir = "out/";
  String sketchName = getSketchName() + "-";
  String randomSeedNum = "rS" + rSn + "-";
  String dateTimeStamp = "" + year() + nf(month(), 2) + nf(day(), 2) + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
  fileName = outputDir + sketchName + dateTimeStamp + randomSeedNum + fileType;
  return fileName;
}

void screenCap(String fileType) {
  String saveName = generateSaveImgFileName(fileType);
  save(saveName);
  println("Screen shot saved to: " + saveName);
}

String getSketchName() {
  String[] path = split(sketchPath, "/");
  return path[path.length-1];
}