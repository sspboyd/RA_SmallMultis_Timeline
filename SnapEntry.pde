/*////////////////////////////////////////
 SnapEntry Objects
 ////////////////////////////////////////*/

class SnapEntry {

  // Question Data
  boolean scrn; // Are you in front of a screen
  StringList whoAreYouWith; // Who are you with?
  StringList doing;
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

  StringList getRoomL(){
    StringList roomL = new StringList();
    roomL.append(room);
    return roomL;
  }

  StringList getLocationL(){
    StringList locL = new StringList();;
    locL.append(location);
    return locL;
  }

  StringList getDoWL(){
    StringList dowL = new StringList();;
    String dow = DAYS_OF_WEEK[getDayOfWeekIndx(dts) - 1];
    dowL.append(dow);
    return dowL;
  }

  StringList getPpl(){
    return whoAreYouWith;
  }

  

  String getData(String _dt){ // this doesn't work for whoAreYouWith or doing variables. Maybe turn everything into a StringList?
    String currDT = "";
    if(_dt.equals("room")) currDT = getRoom();
    if(_dt.equals("location")) currDT = getLocation();
    if(_dt.equals("days")) currDT = getDoW();
    return currDT;
  }

  StringList getDataL(String _dt){ // this doesn't work for whoAreYouWith or doing variables. Maybe turn everything into a StringList?
    StringList sed = new StringList(); // sed = snap entry data
    if(_dt.equals("room")) sed = getRoomL();
    if(_dt.equals("location")) sed = getLocationL();
    if(_dt.equals("days")) sed = getDoWL();
    if(_dt.equals("person")) sed = getPpl();
    return sed;
  }
}