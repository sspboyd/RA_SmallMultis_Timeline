import processing.pdf.*;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.text.ParseException;

//Declare Globals
int rSn; // randomSeed number. put into var so can be saved in file name. defaults to 47
final float PHI = 0.618033989;

// Declare Font Variables
PFont mainTitleF;

boolean PDFOUT = false;

// Declare Positioning Variables
float margin;
float PLOT_X1, PLOT_X2, PLOT_Y1, PLOT_Y2, PLOT_W, PLOT_H;


//Declare Globals
JSONObject raj; // This is the variable that we load the JSON file into. It's not much use to us after that.
JSONArray snapshots; // This is the variable that holds all the 'snapshots' recorded by Reporter App. We'll use this variable a lot.
ArrayList<SnapEntry> snapList = new ArrayList();





/*////////////////////////////////////////
 SETUP
 ////////////////////////////////////////*/

void setup() {
  background(29);
  if (PDFOUT) {
    size(800, 450, PDF, generateSaveImgFileName(".pdf"));
  }
  else {
    size(1300, 650); // quarter page size
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

  raj = loadJSONObject("reporter-export-20141129.json"); // this file has to be in your /data directory. I've included a small sample file.
  // raj = loadJSONObject("reporter-export-20140903.json"); // this file has to be in your /data directory. I've included a small sample file.
  snapshots = raj.getJSONArray("snapshots"); 
  String q = "Which room are you in?";
  // Create snapshot objects for each snapshot
  // Begin parsing the JSON from Reporter App
  for (int i = 0; i < snapshots.size(); i+=1) { // iterate through every snapshot in the snapshots array...
    JSONObject snap = snapshots.getJSONObject(i); // create a new json object (snap) with the current snapshot
    // create a new SnapEntry object for this snapshot
    SnapEntry s = new SnapEntry();
    
    String sdts = snap.getString("date"); // sdts = snapshot datetime string. This is an example of how to grab variables in the snap json object.
    // s.dateString = sdts;
    s.setDts(sdts);

    JSONArray resps = snap.getJSONArray("responses"); // Create a new array to grab the responses from the current snapshot
    
    String questionPrompt = ""; // declare and initialize this variable before it's used in the if() statement coming next.
    
    for (int j = 0; j < resps.size(); j+=1) {  // iterate through each response
      JSONObject resp = resps.getJSONObject(j); // Create a new json object called resp to grab each of the responses individually
      if (resp.hasKey("questionPrompt")) {  // test to make sure there is a question prompt associated with this response. I've found a few times that responses are missing question prompts!
        questionPrompt = resp.getString("questionPrompt");
        // println("resp question: " + question);
      }
      if (questionPrompt.equals(q) == true) { // check to see if the questionPrompt string matches the question we're looking for...
        // One of the answer types is "answeredOptions"
        if (resp.hasKey("answeredOptions")) {  // again, check to see if the resp JSONObject has a key called "answeredOptions"
        }
        if (resp.hasKey("tokens")) {  // again, check to see if the resp JSONObject has a key called "tokens"
          JSONArray ans = resp.getJSONArray("tokens"); // create another JSONArray of the answers
          if(ans.size() > 1) println("ans has more than one room: " + ans);
          if(ans.size() < 1) println("ans has no rooms! ->" + ans);
          if(ans.size() > 0){
            JSONObject ansRm = ans.getJSONObject(0);
            // println("ansRm: "+ansRm);
            String rm = ansRm.getString("text");
            s.room = rm;
            // println("rm: "+rm);
          }
        }
      }
    }
    if(s.room != null){
      snapList.add(s);
    }
  }

  println("snapList size = " + snapList.size());

  StringList rooms = new StringList();
  rooms.append("Main room");
  rooms.append("Bedroom");
  rooms.append("My den");
  rooms.append("My office at CBC");
  rooms.append("Outside");
  rooms.append("The kitchen");
  rooms.append("Patio");
  rooms.append("9A204 CBC mtg room");
  rooms.append("Backyard");
  rooms.append("Lexus");

  renderTimeline(rooms);

  println("setup done: " + nf(millis() / 1000.0, 1, 2));
  noLoop();
}

void draw() {
  //background(255);
  fill(0);
  textFont(mainTitleF);
  // text("sspboyd", PLOT_X2-textWidth("sspboyd"), PLOT_Y2);


  if (PDFOUT) exit();
}

void renderTimeline(StringList rms){
    // next step is to pick a room and make a chart showing when 
  // I'm in that room (0-24hrs)
  // create some chart dimensions
  // room |_______________________________| 
  float chart_X1, chart_X2, chart_Y1, chart_Y2, chart_W, chart_H;
  chart_X1 = PLOT_X1;
  chart_X2 = PLOT_X2;
  chart_W = chart_X2 - chart_X1;
  chart_H = PLOT_H/(rms.size());
  chart_Y1 = PLOT_Y1;
  chart_Y2 = PLOT_Y1 + chart_H;

  // put hour indicators along the scale
  for (int i = 0; i < 25; i+=3) {
    float xpos = map(i, 0, 24, chart_X1+chart_W*pow(PHI,3), chart_X2);
    if(i==24) xpos = chart_X2-textWidth("24");
    fill(255,200);
    textSize(14);
    text(i, xpos, PLOT_Y1-5);    
  }


  int cntr=0;
  for (String rm : rms) {

    chart_Y1 = PLOT_Y1 + (chart_H * cntr);
    chart_Y2 = chart_Y1 + chart_H-5;

    String r = rm;
    // create an ArrayList of SnapEntries 
    ArrayList<SnapEntry> rmList = new ArrayList();
    for (SnapEntry se : snapList) {
      if(se.room.equals(r)) rmList.add(se);
    }
    // println("rmList.size(): "+rmList.size());

    for (SnapEntry se : rmList) {
      // get the second of the day for this entry
      int secOfDay = 0;
      Calendar calendar = Calendar.getInstance();
      calendar.setTime(se.dts);
      int hours = calendar.get(Calendar.HOUR_OF_DAY);
      int minutes = calendar.get(Calendar.MINUTE);
      int seconds = calendar.get(Calendar.SECOND);

      secOfDay = (hours*60*60) + (minutes*60) + seconds;

      float seXPos = map(secOfDay, 0, (24*60*60), chart_X1+chart_W*pow(PHI,3), chart_X2);
      stroke(76,76,255,200);
      line(seXPos, chart_Y1, seXPos, chart_Y2);
      stroke(0);
      // line(chart_X1+chart_W*pow(PHI,4), chart_Y1,chart_X1+chart_W*pow(PHI,4), chart_Y2);
      noFill();
      // rectMode(CORNERS);
      // rect(chart_X1+chart_W*pow(PHI,3),chart_Y1, chart_X2, chart_Y2);
    }
    fill(255,200);
    textFont(mainTitleF);
    textSize(18);
    text(r, chart_X1, chart_Y2);
    cntr += 1;
  }

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