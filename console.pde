class ConsoleLog{
  ArrayList<ConsoleEntry> messages;
  
  ConsoleLog(){
    messages = new ArrayList<ConsoleEntry>();
  }
  
  void render(float x, float y){
    int start = messages.size() - 50;
    if(start < 0)
      start = 0;
    pushMatrix();
    translate(x, y);
    fill(255);
    rect(0, 0, 300, 500);
    textSize(10);
    for(int i = start; i < messages.size(); i ++){
      messages.get(i).render(0, (i - start) * 10 + 10);
    }
    popMatrix();
  }
  
  void debug(String s){
    messages.add(new ConsoleEntry(s));
    println(s);
  }
  
  void debug(){
    messages.add(new ConsoleEntry());
    println(); 
  }
  
  void warning(String s){
    s = "[WARNING] " + s;
    messages.add(new WarningEntry(s));
    println(s);
  }
  
  void error(String s){
    s = "[ERROR] " + s;
    messages.add(new ErrorEntry(s));
    println(s);
  }
  
  void info(String s){
    s = "[INFO] " + s;
    messages.add(new InfoEntry(s));
    println(s);
  }
  
  void notif(String s){
    messages.add(new NotifEntry(s));
    println(s);
  }
  
  void printbar(){
    messages.add(new ConsoleEntry("----------------"));
    println("----------------");
  }
}

class ConsoleEntry{
  String message;
  ConsoleEntry(){
    message = "";
  }
  
  ConsoleEntry(String m){
    message = m;
  }
  
  void render(float x, float y){
    fill(0);
    text(message, x + 4, y);
  }
}

class WarningEntry extends ConsoleEntry{
  WarningEntry(String m){
    message = m;
  }
  
  void render(float x, float y){
    fill(255, 200, 0);
    text(message, x + 4, y);
  }
}

class ErrorEntry extends ConsoleEntry{
  ErrorEntry(String m){
    message = m;
  }
  
  void render(float x, float y){
    fill(230, 0, 0);
    text(message, x + 4, y);
  }
}

class InfoEntry extends ConsoleEntry{
  InfoEntry(String m){
    message = m;
  }
  
  void render(float x, float y){
    fill(100, 100, 250);
    text(message, x + 4, y);
  }
}

class NotifEntry extends ConsoleEntry{
  NotifEntry(String m){
    message = m;
  }
  
  void render(float x, float y){
    fill(100, 250, 100);
    text(message, x + 4, y);
  }
}