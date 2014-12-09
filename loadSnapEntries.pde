ArrayList<SnapEntry> loadSnapEntries(JSONArray _snapshots){
  ArrayList<SnapEntry> _snapList = new ArrayList();

  for (int i = 0; i < _snapshots.size(); i+=1) { // iterate through every snapshot in the snapshots array...
    JSONObject snap = _snapshots.getJSONObject(i); // create a new json object (snap) with the current snapshot

    // create a new SnapEntry object for this snapshot
    SnapEntry s = new SnapEntry();
    
    String sdts = snap.getString("date"); // sdts = snapshot datetime string. This is an example of how to grab variables in the snap json object.
    s.dateString = sdts;
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
          if(ans.size() > 1) println("ans @ " + sdts + " has more than one room: \n" + ans);
          if(ans.size() < 1) println("ans has no rooms! ->" + ans);
          if(ans.size() > 0){
            JSONObject ansRm = ans.getJSONObject(0);
            // println("ansRm: "+ansRm);
            String rm = ansRm.getString("text");
            s.room = rm;
            if(!roomList.hasValue(rm)) roomList.append(rm);
          }
        }
      }
    }
    _snapList.add(s);
  }
  return _snapList;
}
