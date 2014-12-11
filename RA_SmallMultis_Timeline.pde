import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.text.ParseException;
import java.util.Map;


//Declare Globals
int rSn; // randomSeed number. put into var so can be saved in file name. defaults to 47
final float PHI = 0.618033989;

// Declare Font Variables
PFont mainTitleF;
PFont rowLabelF;
PFont scaleTicksF;

boolean PDFOUT = false;

// Declare Positioning Variables
float margin;
float PLOT_X1, PLOT_X2, PLOT_Y1, PLOT_Y2, PLOT_W, PLOT_H; // Defining the drawable area of the canvas (inside the margin)
float CHART_AREA_X1, CHART_AREA_X2, CHART_AREA_Y1, CHART_AREA_Y2, CHART_AREA_W, CHART_AREA_H; // Defining the area of the canvas that all the (small multiple) charts will be drawn

//Declare Globals
JSONObject raj; // This is the variable that we load the JSON file into. It's not much use to us after that.
ArrayList<SnapEntry> snapList;
HashMap<String, ArrayList<SnapEntry>> roomSnapsHash;
HashMap<String, ArrayList<SnapEntry>> doWSnapsHash;
StringList roomList; // list of ALL rooms
StringList rooms; // list of rooms to be graphed
String[] DAYS_OF_WEEK = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"};
StringList _days; // list of days to be graphed
String q = "Which room are you in?";



/*////////////////////////////////////////
 SETUP
 ////////////////////////////////////////*/

void setup() {
  background(29);
  size(1300, 650);

  margin = width * pow(PHI, 6);

  PLOT_X1       = margin;
  PLOT_X2       = width - margin;
  PLOT_Y1       = margin;
  PLOT_Y2       = height - margin;
  PLOT_W        = PLOT_X2 - PLOT_X1;
  PLOT_H        = PLOT_Y2 - PLOT_Y1;

  CHART_AREA_X1 = PLOT_X1;
  CHART_AREA_X2 = PLOT_X2;
  CHART_AREA_Y1 = (PLOT_Y1 + (PLOT_H * pow(PHI, 4)));
  CHART_AREA_Y2 = PLOT_Y2;
  CHART_AREA_W  = CHART_AREA_X2 - CHART_AREA_X1;
  CHART_AREA_H  = CHART_AREA_Y2 - CHART_AREA_Y1;

  smooth(4);

  mainTitleF  = loadFont("HelveticaNeue-14.vlw");  //requires a font file in the data folder?
  rowLabelF   = loadFont("HelveticaNeue-14.vlw");  //requires a font file in the data folder?
  mainTitleF  = loadFont("HelveticaNeue-Light-36.vlw");  //requires a font file in the data folder?

  raj = loadJSONObject("reporter-export-20141129.json"); // this file has to be in your /data directory. I've included a small sample file.
  JSONArray snapshots = raj.getJSONArray("snapshots"); // This is the variable that holds all the 'snapshots' recorded by Reporter App. 
  
  roomList = new StringList();

  snapList = loadSnapEntries(snapshots); // The loadSnapEntries() function will take the snapshots JSONArray and create an ArrayList of SnapEntries

  roomSnapsHash = new HashMap<String,ArrayList<SnapEntry>>();
  roomSnapsHash = loadRoomSnapsHash(roomList);

  rooms = new StringList();
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
  rooms.append("Locker room");
  rooms.append("Heaton's office");
  rooms.append("Dining room");
  rooms.append("Screened in porch");
  rooms.append("The dock");

  
  _days = new StringList();
  _days.append("Monday");
  _days.append("Tuesday");
  _days.append("Wednesday");
  _days.append("Thursday");
  _days.append("Friday");
  _days.append("Saturday");
  _days.append("Sunday");


  // Debug / Status info
  println("===================================");
  println("margin: " + margin);
  // println("snapList size = " + snapList.size());
  // println("roomList = " + roomList);
  // print name and count for each room
  /*
  for (String rm : roomList) {
    if(roomSnapsHash.containsKey(rm)){
      ArrayList rmList = (ArrayList)roomSnapsHash.get(rm);
      int roomCount = rmList.size();
      println(rm + " : " + roomCount);
    }
  }
  */
  println("setup done: " + nf(millis() / 1000.0, 1, 2));
  // noLoop();
}



/*////////////////////////////////////////
 DRAW
 ////////////////////////////////////////*/

void draw() {
  background(29);

  renderTitle();
  renderTimelineScale(); // horizontal scale (0-24hrs)
  // renderTimeDayGrid(snapList);
  renderRoomsTimeline(rooms);
  // renderDaysOfWeekLabels();

  fill(255,18);
  textFont(rowLabelF);
  text("sspboyd", PLOT_X2 - textWidth("sspboyd"), PLOT_Y2);

    noFill();
    strokeWeight(.5);
  stroke(100, 255);
  rect(PLOT_X1, PLOT_Y1, PLOT_W, PLOT_H);
  stroke(255, 255);
  rect(CHART_AREA_X1, CHART_AREA_Y1, CHART_AREA_W, CHART_AREA_H);

}



// Creates HashMap of "Room name" <--> ArrayList of Snapshot Entries
HashMap<String, ArrayList<SnapEntry>> loadRoomSnapsHash(StringList _rmL){
  HashMap<String, ArrayList<SnapEntry>> rmSnpsHash = new HashMap<String,ArrayList<SnapEntry>>(); // create a hashmap object to be returned
                                                                                                 // naming similar things differently is hard...
  for (String currRoom : _rmL) { // for each room name (string) in the roomList StringList object...
    ArrayList<SnapEntry> snaps = new ArrayList<SnapEntry>(); // create an ArrayList to hold any snapshots where the snap's room string matches the current room string
    for (SnapEntry currSnap : snapList) { // for each snapshot in the SnapList ArrayList
      if(currSnap.room != null){ // is there a value in the current snap's room variable
        if(currSnap.room.equals(currRoom)) snaps.add(currSnap);
      }
    }
    rmSnpsHash.put(currRoom, snaps);
  }
  return (HashMap)rmSnpsHash;
}

// Creates HashMap of "Day of Week (Monday)" <--> ArrayList of Snapshot Entries
HashMap<String, ArrayList<SnapEntry>> loadDoWSnapsHash(StringList _d){
  HashMap<String, ArrayList<SnapEntry>> doWSnpsHash = new HashMap<String,ArrayList<SnapEntry>>(); // create a hashmap object to be returned
                                                                                                 // naming similar things differently is hard...
  for (String currDay : _d) { // for each room name (string) in the roomList StringList object...
    ArrayList<SnapEntry> snaps = new ArrayList<SnapEntry>(); // create an ArrayList to hold any snapshots where the snap's room string matches the current room string
    for (SnapEntry currSnap : snapList) { // for each snapshot in the SnapList ArrayList
      if(currSnap.dts != null){ // is there a value in the current snap's room variable
        String dayStr = DAYS_OF_WEEK[getDayOfWeekIndx(currSnap.dts) - 1];
        if(dayStr.equals(currDay)) snaps.add(currSnap);
      }
    }
    doWSnpsHash.put(currDay, snaps);
  }
  return (HashMap)doWSnpsHash;
}

// Render the horizontal Scale
void renderTimelineScale(){
  // put hour indicators along the scale
  for (int i = 0; i < 25; i+=3) {
    float xpos = map(i, 0, 24, CHART_AREA_X1 + CHART_AREA_W * pow(PHI,4), CHART_AREA_X2);
    String tStr = i + ":00"; // tStr stands for time string
    if(i==24) xpos = CHART_AREA_X2 - textWidth(tStr); // last hour of the day mark (24) should be moved a bit left to keep it within the chart borders
    fill(255,175);
    textFont(rowLabelF);
    text(tStr, xpos, CHART_AREA_Y1+textAscent());    
  }
}


void renderRoomsTimeline(StringList rms){
  // next step is to pick a room and make a chart showing when 
  // I'm in that room (0-24hrs)
  // create some chart dimensions
  // room |_______________________________| 
  float ch_bfr_H,totalChBfrH; // the height of the buffer between two charts, and the total buffer height
  ch_bfr_H = CHART_AREA_H * pow(PHI,9); // salt to taste
  totalChBfrH = ch_bfr_H * rms.size()-1; // -1 bc we only want buffer's between charts, not at the bottom

  float chart_X1, chart_X2, chart_Y1, chart_Y2, chart_W, chart_H;
  chart_X1  = CHART_AREA_X1;
  chart_X2  = CHART_AREA_X2;
  chart_W   = CHART_AREA_W;
  textFont(rowLabelF); // this is needed to for the next line with textAscent
  chart_H   = ((CHART_AREA_H - (textAscent()-5)) - totalChBfrH) / (rms.size()); // textAscent included to account for top scale #s
  // chart_Y1  = CHART_AREA_Y1 + chart_H * i;
  // chart_Y2  = chart_Y1 + chart_H;

  for (int i = 0; i < rms.size(); i+=1) {
    String rm = rms.get(i);
    chart_Y1 = (CHART_AREA_Y1 + (textAscent()+5)) + (chart_H * i) + (ch_bfr_H*i);
    chart_Y2 = chart_Y1 + chart_H;
    stroke(100,100,0);
    noFill();
    rectMode(CORNERS);
    rect(chart_X1, chart_Y1, chart_X2, chart_Y2);
    rectMode(CORNER);

    // create an ArrayList of SnapEntries 
    ArrayList<SnapEntry> rmList = new ArrayList();
    rmList = (ArrayList)roomSnapsHash.get(rm);

    for (SnapEntry currSnapEntry : rmList) {
      // get the second of the day for this entry
      int secOfDay = getSecOfDay(currSnapEntry.dts);
      int dayOfWeek = getDayOfWeekIndx(currSnapEntry.dts);

      // use the 'second of the day' value to set the horizontal position
      float seXPos = map(secOfDay, 0, (24*60*60), chart_X1 + chart_W * pow(PHI, 4), chart_X2);
      float seYPos = chart_Y1;
      currSnapEntry.setH(chart_H/1);
      if(currSnapEntry.targetPos.x == 0) currSnapEntry.targetPos.set(seXPos, seYPos);
      currSnapEntry.update();
      currSnapEntry.render();

      // render a line to show the entry along the timeline
      // line(seXPos, chart_Y1, seXPos, chart_Y2);
    }

    // Render row label 
    fill(255,200);
    textFont(rowLabelF);
    text(rm, chart_X1, chart_Y2);

    // Render a faint horizontal line under the chart to help readability
    if (i < rms.size() - 1) { // the -1 is so that we don't draw a line across the bottom
      stroke(255, 29);
      strokeWeight(.5);
      line(chart_X1, chart_Y2 + chart_H*.25, chart_X2, chart_Y2 + chart_H*.25); // the *0.25 seems kind of hacky. Should be a better way of doing this
     } 
  }
}

void renderDaysOfWeekLabels(){
  textFont(rowLabelF); // this is needed to for the next line with textAscent // and shouldn't this be the font used for the horiz scale text?
  // chart_H   = ((PLOT_H - (PLOT_H * pow(PHI, 4))) - textAscent() * 2) / (_days.size()); // textAscent included to account for top scale #s
  float chart_H   = ((PLOT_H - (PLOT_H * pow(PHI, 4))) - textAscent() * 2) / _days.size(); // textAscent included to account for top scale #s
  float chart_Y1  = (PLOT_Y1 + (PLOT_H * pow(PHI, 4)));
  // float chart_Y1  = (PLOT_Y1 + (PLOT_H * pow(PHI, 4))) + textAscent();

  float chart_Y2  = PLOT_Y1 + chart_H;
  for (int i = 0; i < _days.size(); i++) {
    text(_days.get(i), PLOT_X1, chart_Y1+(chart_H*i) + 47);
  }
}

void renderTimeDayGrid(ArrayList<SnapEntry> sl){
  float chart_X1, chart_X2, chart_Y1, chart_Y2, chart_W, chart_H;
  chart_X1  = PLOT_X1;
  chart_X2  = PLOT_X2;
  chart_W   = chart_X2 - chart_X1;
  textFont(rowLabelF); // this is needed to for the next line with textAscent // and shouldn't this be the font used for the horiz scale text?
  // chart_H   = ((PLOT_H - (PLOT_H * pow(PHI, 4))) - textAscent() * 2) / (_days.size()); // textAscent included to account for top scale #s
  chart_H   = ((PLOT_H - (PLOT_H * pow(PHI, 4))) - textAscent() * 2) / 1; // textAscent included to account for top scale #s
  chart_Y1  = (PLOT_Y1 + (PLOT_H * pow(PHI, 4)));
  // chart_Y1  = (PLOT_Y1 + (PLOT_H * pow(PHI, 4))) + textAscent();
  chart_Y2  = PLOT_Y1 + chart_H;


  for (SnapEntry currSnapEntry : sl) {
    float csex = map(getSecOfDay(currSnapEntry.dts), 0, 24*60*60, chart_X1+chart_W*pow(PHI,4), chart_X2);
    float csey = map(getDayOfWeekIndx(currSnapEntry.dts), 1,7, chart_Y1, chart_Y2);
    currSnapEntry.targetPos.set(csex, csey);
    currSnapEntry.pos.set(csex, csey);
    currSnapEntry.setH(47);
    currSnapEntry.render();
  }
}

void renderTitle(){
  textFont(mainTitleF);
  fill(255,200);
  text("Time to Report", PLOT_X1, PLOT_Y1+textAscent()*1);
  // text("Which room are you in?", PLOT_X1, PLOT_Y1+textAscent()*2);
}


int getSecOfDay(Date d){
  Calendar c  = Calendar.getInstance();
  c.setTime(d);
  int hours   = c.get(Calendar.HOUR_OF_DAY);
  int minutes = c.get(Calendar.MINUTE);
  int seconds = c.get(Calendar.SECOND);

  return (hours*60*60) + (minutes*60) + seconds;
}

int getDayOfWeekIndx(Date d){
  Calendar c  = Calendar.getInstance();
  c.setTime(d);
  return c.get(Calendar.DAY_OF_WEEK);
}