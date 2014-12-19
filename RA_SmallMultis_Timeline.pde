import java.text.SimpleDateFormat;
import java.text.ParseException;
import java.util.Calendar;
import java.util.concurrent.TimeUnit;
import java.util.Date;
import java.util.Map;


//Declare Globals
final float PHI = 0.618033989;

// Declare Font Variables
PFont mainTitleF;
PFont rowLabelF;

// Declare Positioning Variables
float margin;
float PLOT_X1, PLOT_X2, PLOT_Y1, PLOT_Y2, PLOT_W, PLOT_H; // Defining the drawable area of the canvas (inside the margin)
float CHART_AREA_X1, CHART_AREA_X2, CHART_AREA_Y1, CHART_AREA_Y2, CHART_AREA_W, CHART_AREA_H; // Defining the area of the canvas that all the (small multiple) charts will be drawn
float hiLiW; // (hi)gh(Li)ght (W)idth, used to determine width of area highlighted when user moves over charts

//Declare Globals
ArrayList<SnapEntry> snapList; // master list of all snap entries read out of raj
ArrayList<SnapEntry> smcSnapList; // smc = small multiples chart. List of all snap entries to be used in the charts to be rendered
ArrayList<SnapEntry> hLSnapList; // list of highlighted snap entries (not yet implemented)

StringList rooms; // list of rooms to be graphed

String[] DAYS_OF_WEEK = { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" };
StringList dayList; // list of days to be graphed

String q = "Which room are you in?";

String chartDT = "room"; // chartDT = chart Data Type eg. days, room, person, location, doing
// String chartDT = "days"; // chartDT = chart Data Type eg. days, room, person, location, doing
StringList chartRL; // chartRL = Chart Row List; 





/*////////////////////////////////////////
 SETUP
 ////////////////////////////////////////*/

void setup() {
  background(29);
  size(1300, 650);
  // size(1900, 1000); // resolution for iMac
  smooth(4);

  margin = width * pow(PHI, 7);

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

  rowLabelF   = loadFont("HelveticaNeue-14.vlw");  //requires a font file in the data folder?
  mainTitleF  = loadFont("HelveticaNeue-Light-36.vlw");  //requires a font file in the data folder?

  snapList = loadSnapEntries("reporter-export-20141129.json"); // The loadSnapEntries() function will take the snapshots JSONArray and create an ArrayList of SnapEntries

  Table chartCounts = loadChartDTCounts(snapList); // every room with its count/frequency in a sorted table

  rooms = new StringList(); // list of rooms to be charted 
  rooms = loadRoomList(chartCounts); // uses the Table to select the top n rooms. This means I don't have to do it manually like the code below did.
  /*  Keeping this here to show how to manually select rows/charts */
   // rooms.append("Main room");
   // rooms.append("Bedroom");

  dayList = new StringList();
  dayList.append("Monday");
  dayList.append("Tuesday");
  dayList.append("Wednesday");
  dayList.append("Thursday");
  dayList.append("Friday");
  dayList.append("Saturday");
  dayList.append("Sunday");

  chartRL = rooms;
  // chartRL = dayList;

  smcSnapList = loadSMCSnapList(chartRL, chartDT); // all snap entries that match the row string + data type

  hiLiW = CHART_AREA_W * pow(PHI, 7); // aiming for something around 40px when 650 canvas width


  // Debug / Status info
  println("===================================");
  println("margin: " + margin);
  println("snapList size = " + snapList.size());

  println("setup done: " + nf(millis() / 1000.0, 1, 2) + "s");
  // noLoop();
}





/*////////////////////////////////////////
 DRAW
 ////////////////////////////////////////*/

void draw() {
  background(29);
  renderTitle();
  renderTimelineScale(); // horizontal scale (0-24hrs)
  // renderSMCTimeline(rooms, smcSnapList);
  renderSMCTimeline(chartRL, smcSnapList);
  renderHL();
  renderSspb();
}




/*////////////////////////////////////////
 Data Logic and Data Structure Functions 
 ////////////////////////////////////////*/

// Create ArrayList of all Snap Entry to be plotted (eg. every snapEntry matching one of the rooms in a list.)
ArrayList<SnapEntry> loadSMCSnapList(StringList _rLabels, String _dt){ // _rLabels = row labels, _dt = data type (eg room, location, person)
  ArrayList<SnapEntry> newSMCSnapList = new ArrayList<SnapEntry>();

  if(_dt.equals("room")){
    for (SnapEntry currSnap : snapList) {
      String currRoom = currSnap.room;
      if(currRoom != null){
        for (String rl : _rLabels) {
          if(currRoom.equals(rl)){
            newSMCSnapList.add(currSnap);
          }
        }
      }
    }

  }else if (_dt.equals("days")) {
    for (SnapEntry currSnap : snapList) {
      String currDay = currSnap.getDoW();
      if(currDay != null){
        for (String rl : _rLabels) {
          if(currDay.equals(rl)){
            newSMCSnapList.add(currSnap);
          }
        }
      }
    }
  }
  return newSMCSnapList;
}


Table loadChartDTCounts(ArrayList<SnapEntry> _se) {
  Table t = new Table(); // is this line done?
  t.addColumn(chartDT, Table.STRING);
  t.addColumn("Count", Table.INT);

  for (SnapEntry currSE : _se) {
    String currSED = currSE.getData(chartDT); // currSED = chartSED is chart SnapEntry Data
    if (currSED != null) {
      TableRow tr = t.findRow(currSED, chartDT);
      if (tr == null) { // if there is no room with this name already...
        TableRow ntr = t.addRow(); // ntr = new table row
        ntr.setString(chartDT, currSED);
        ntr.setInt("Count", 1);
      } else {
        int currCnt = tr.getInt("Count");
        tr.setInt("Count", ++currCnt);
      }
    }
  } 
  t.sortReverse("Count"); // sort the list by most to least room "Count"
  return t;
}

StringList loadRoomList(Table _t) {
  StringList rmList = new StringList();
  for (int i = 0; i < _t.getRowCount (); i++) {
    // for (int i = 0; i < 10; i++) {
    TableRow r = _t.getRow(i);
    if (r.getInt("Count") > 5) { // only return rooms with more than n reports
      rmList.append(r.getString(chartDT));
    }
  }
  return rmList;
}





/*////////////////////////////////////////
 Render Functions 
 ////////////////////////////////////////*/

// Render the horizontal Scale
void renderTimelineScale() {
  // put hour indicators along the scale
  for (int i = 0; i <= 24; i+=3) {
    float xpos = map(i, 0, 24, CHART_AREA_X1 + CHART_AREA_W * pow(PHI, 4), CHART_AREA_X2);
    String tStr = nf(i, 2) + ":00"; // tStr stands for time string
    if (i==24) xpos = CHART_AREA_X2 - textWidth(tStr); // last hour of the day mark (24) should be moved a bit left to keep it within the chart borders
    fill(255, 175);
    textFont(rowLabelF);
    text(tStr, xpos, CHART_AREA_Y1+textAscent());
  }
}


void renderSMCTimeline(StringList _rLabels, ArrayList<SnapEntry> _se) {
  float chartBfr_H; // the height of the buffer between two charts.
  float chart_X1, chart_X2, chart_Y1, chart_Y2, chart_W, chart_H, x_axisH;
  textFont(rowLabelF); // this is needed to for the next line with textAscent
  x_axisH     = textAscent() + 5;
  chart_X1    = CHART_AREA_X1;
  chart_X2    = CHART_AREA_X2;
  chart_W     = CHART_AREA_W;
  chart_H     = (CHART_AREA_H - x_axisH) / _rLabels.size(); // textAscent included to account for top scale #s
  chartBfr_H  = chart_H * pow(PHI, 2); // salt to taste
  chart_H     = chart_H - chartBfr_H;

  for (int i = 0; i < _rLabels.size (); i+=1) {
    String rL = _rLabels.get(i); // rL = row label
    int rLSnapEntryCount = 0;
    int rlHiLiSnapEntryCount = 0;
    chart_Y1 = CHART_AREA_Y1 + x_axisH + (chart_H * i) + (chartBfr_H * i);
    chart_Y2 = chart_Y1 + chart_H;

    for (SnapEntry currSnapEntry : _se) {
      boolean chartMatch = false; // var to test if the currSnapEntry 'matches' and should be rendered on this chart

      if(chartDT.equals("days")){ // maybe use case/switch here instead?
        String dayStr = currSnapEntry.getDoW();
        if(dayStr.equals(rL)){
          chartMatch = true;
        }
      }
      if(chartDT.equals("room")){
        if(currSnapEntry.room.equals(rL)) chartMatch = true;
      }

      if(chartMatch){
        rLSnapEntryCount += 1;
        if(currSnapEntry.hiLiCheck()) rlHiLiSnapEntryCount += 1;
        // get the second of the day for this entry
        int secOfDay = getSecOfDay(currSnapEntry.dts);
        int dayOfWeek = getDayOfWeekIndx(currSnapEntry.dts);

        // use the 'second of the day' value to set the horizontal position
        float seXPos = map(secOfDay, 0, (24*60*60), chart_X1 + chart_W * pow(PHI, 4), chart_X2);
        float seYPos = chart_Y1;
        currSnapEntry.setH(chart_H/1);
        currSnapEntry.targetPos.set(seXPos, seYPos); // need to eventually move this somewhere else. doesn't need to be updated every frame.
        currSnapEntry.update();
        currSnapEntry.render();
      }
    }

    // Render row label 
    fill(255, 200);
    textFont(rowLabelF);
    text(rL + ", " +rLSnapEntryCount, chart_X1, chart_Y2);
    if(rlHiLiSnapEntryCount > 0) text(rlHiLiSnapEntryCount, mouseX + (hiLiW/2), chart_Y2);

    // Render a faint horizontal line under the chart to help readability
    if (i < _rLabels.size() - 1) { // the -1 is so that we don't draw a line across the bottom
      stroke(255, 18);
      strokeWeight(.5);
      line(chart_X1, chart_Y2 + chartBfr_H/2, chart_X2, chart_Y2 + chartBfr_H/2); // the *0.25 seems kind of hacky. Should be a better way of doing this
    }
  }
}


void renderTitle() {
  textFont(mainTitleF);
  float txtY1 = PLOT_Y1+textAscent()*1;
  float txtY2 = PLOT_Y1+textAscent()*2;
  fill(255, 200);
  text("Time to Report", PLOT_X1, txtY1);
  textFont(rowLabelF);
  SimpleDateFormat tdf = new SimpleDateFormat("MMMMM yyyy");
  String dateCpy = "From " + tdf.format(getOldestDate(smcSnapList));
  dateCpy += " to " + tdf.format(getNewestDate(smcSnapList)) + ". ";
  dateCpy += daysBtwn(getOldestDate(smcSnapList), getNewestDate(smcSnapList)) + " days. ";
  dateCpy += smcSnapList.size() + " reports. ";

  text(dateCpy, PLOT_X1, txtY2);
}


void renderHL() {
  stroke(255, 176);
  fill(255, 11);
  strokeWeight(.25);
  line(mouseX, CHART_AREA_Y1, mouseX, CHART_AREA_Y2);
  noStroke();
  rect(mouseX-20, CHART_AREA_Y1, 40, CHART_AREA_H);

  if ((mouseX>CHART_AREA_X1 + CHART_AREA_W * pow(PHI, 4)) && (mouseX<CHART_AREA_X2) && (mouseY>CHART_AREA_Y1) && (mouseY < CHART_AREA_Y2)) {
    int hLMinOfDay = floor(map(mouseX, CHART_AREA_X1 + CHART_AREA_W * pow(PHI, 4), CHART_AREA_X2, 0, 1439));
    int hlHr = floor(hLMinOfDay/60);
    int hlMin = hLMinOfDay%60;
    fill(255, 176);
    text(nf(hlHr, 2) + ":" + nf(hlMin, 2), mouseX+hiLiW, mouseY);
    strokeWeight(.75);
    stroke(255, 176);
    line(mouseX, mouseY, mouseX+hiLiW+textWidth("00:00"), mouseY);
  }
}


void renderSspb() {
  fill(255, 18);
  textFont(rowLabelF);
  text("sspboyd", PLOT_X2 - textWidth("sspboyd"), PLOT_Y2);
}