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
  // println("!!! Amount of days : " + String.valueOf(days));
}

