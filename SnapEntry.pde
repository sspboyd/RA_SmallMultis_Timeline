/*////////////////////////////////////////
 SnapEntry Objects
 ////////////////////////////////////////*/

class SnapEntry {

  // Question Data
  boolean scrn; // Are you in front of a screen
  StringList whoAreYouWith; // Who are you with?
  String room; // What room are you in
  String dateString;
  String location;
  Date dts; // Java date type version of the dateString var.

  int born;

  float h; // height
  color clr = color(76, 76, 255, 123);
  color hiLiClr = color(255, 255, 255, 76);

  PVector pos = new PVector(random(-width*1000), random(-height*1000));
  PVector targetPos = new PVector();

  color col = 255;

  SnapEntry() {
    whoAreYouWith = new StringList();
  }

  void update() {
    pos.x += (targetPos.x - pos.x) * .1;
    pos.y += (targetPos.y - pos.y) * .1;

    stroke(clr);
    strokeWeight(5);
    if (hiLiCheck()) {
      strokeWeight(1);
      stroke(hiLiClr);
    }
  }

  void render() {
    pushMatrix();
    translate(pos.x, pos.y);
    line(0, 0, 0, h);
    popMatrix();
  }

  boolean hiLiCheck() {
    boolean check = false;
    // if(pos.dist(new PVector(mouseX, mouseY-18)) < 50) {
    if (pos.x > mouseX-(hiLiW/2) && pos.x < mouseX+(hiLiW/2)) {
      check = true;
    }
    return check;
  }

  void setDts(String sdts) {
    // 2014-05-25T12:02:06-0400
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ");
    Date parsedDate = new Date();
    try {
      parsedDate = dateFormat.parse(sdts);
    }
    catch(ParseException pe) {
      println("ERROR: Cannot parse \"" + dateString + "\"");
    }
    dts = parsedDate;
  }

  void setH(float _h) {
    h = _h * pow(PHI, 0);
  }

  String getRoom(){
    return room;
  }

  String getLocation(){
    return location;
  }

  String getDoW(){
    String dow = DAYS_OF_WEEK[getDayOfWeekIndx(dts) - 1];
    return dow;
  }

  String getData(String _dt){
    // println("_dt: "+_dt);
    String currDT="";
    if(_dt.equals("room")) currDT = getRoom();
    if(_dt.equals("location")) currDT = getLocation();
    if(_dt.equals("days")) currDT = getDoW();
    return currDT;
  }
}