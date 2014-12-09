


/*////////////////////////////////////////
 SnapEntry Objects
 ////////////////////////////////////////*/

class SnapEntry {

  // Question Data
  boolean scrn; // Are you in front of a screen
  StringList whoAreYouWith; // Who are you with?
  String room; // What room are you in
  String dateString;
  Date dts; // Java date type version of the dateString var.

  int born;

  color clr = color(200,123,123,247);

  
  PVector pos = new PVector();
  PVector targetPos = new PVector();

  color col = 255;

  SnapEntry(){
    whoAreYouWith = new StringList();
  }

  void update() {
    pos.x += (targetPos.x - pos.x) * .1;
    pos.y += (targetPos.y - pos.y) * .1;
  }


  void render() {
    pushMatrix();
    translate(pos.x, pos.y);
      //fill(col, 255);
      stroke(clr);
      if(pos.dist(new PVector(mouseX, mouseY)) < 10) {
        stroke(255);
      }
      strokeWeight(5);
      line(0, 0, 0, 7);
    popMatrix();
  }

  void setDts(String sdts){
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

}