/*////////////////////////////////////////
 Date specific functions.
 I'm trying to keep Date related functions separated out as much as possible in the hope that 
 it will make it easier if I switch to another library (or something like P5.js) in the future.
 Jodatime would simplify a lot of these date functions but I'm trying to stick with 
 'out-of-the-box' Processing code to make it easier for other people to download and use this program.
 ////////////////////////////////////////*/

int getSecOfDay(Date d) {
  Calendar c  = Calendar.getInstance();
  c.setTime(d);
  int hours   = c.get(Calendar.HOUR_OF_DAY);
  int minutes = c.get(Calendar.MINUTE);
  int seconds = c.get(Calendar.SECOND);

  return (hours*60*60) + (minutes*60) + seconds;
}

int getDayOfWeekIndx(Date d) {
  Calendar c  = Calendar.getInstance();
  c.setTime(d);
  return c.get(Calendar.DAY_OF_WEEK);
}

Date getOldestDate(ArrayList<SnapEntry> _se) {
  Date oldest = new Date();
  for (SnapEntry currSE : _se) {
    if (currSE.dts.before(oldest)) oldest = currSE.dts;
  }
  return oldest;
}

Date getNewestDate(ArrayList<SnapEntry> _se) {
  Date newest = new Date(Long.MIN_VALUE);
  for (SnapEntry currSE : _se) {
    if (currSE.dts.after(newest)) newest = currSE.dts;
  }
  return newest;
}

// This is function isn't 100% reliable since it doesn't account for Daylight Savings or Leap years.
int daysBtwn(Date _o, Date _n) { 
  return (int)TimeUnit.MILLISECONDS.toDays(_n.getTime() - _o.getTime());
}

String getToD(float _mx){ // using _mx because I am expecting to be passing a var based off the mouseX position
    int minOfDay = floor(map(_mx, CHART_AREA_X1 + CHART_AREA_W * pow(PHI, 4), CHART_AREA_X2, 0, 1439)); // 1439 is number of minutes in a day -1
    int hr = floor(minOfDay / 60);
    int mint = minOfDay % 60; // using 'mint' because 'min' is often used for minimum functions
    return nf(hr, 2) + ":" + nf(mint, 2);
}