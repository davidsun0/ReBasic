class ProgramField extends TextField{
  ArrayList<String> lines;
  int curline = 0;
  String curtext = "";
  int curchar = 0;
  
  int topline = 0;
  
  ProgramField(float x, float y){
    this.x = x;
    this.y = y;
    w = 460;
    h = 440;
    
    lines = new ArrayList<String>();
    addline(curtext);
  }
  
  void onKeyDown(){
    if(key == BACKSPACE){
      if(curtext.length() == 0)
        delline();
      else{
        delchar();
      }
      setCursorDelay(10);
    }
    else if(key == ENTER){
      lines.set(curline, curtext);
      newline();
    }
    else if(key == CODED){
      if(keyCode == LEFT){
        moveLeft();
        setCursorDelay(10);
      }
      else if(keyCode == RIGHT){
        moveRight();
        setCursorDelay(10);
      }
    }
    else if(key < 128){
      replacechar(curchar, key);
      setCursorDelay(10);
    }
  }
  
  void render(){
    fill(255);
    rect(x, y, w, h);
    for(int i = topline; i < lines.size(); i ++){
      if(i != curline)
        renderLine(lines.get(i), y + i * 20 + 20);
      else
        renderLine(curtext, y + i * 20 + 20);
    }
    if(isFocus()){
      if(curtext.length() == 37 && curchar == 37)
        renderCursorFull(x + 12 * curchar + 4, y + curline * 20);
      else
        renderCursor(x + 12 * curchar, y + curline * 20);
    }
  }
  
  void renderLine(String s, float y){
    fill(0);
    boolean intoken = false;
    //text(s, x, y);
    for(int i = 0; i < s.length(); i ++){
      if(s.charAt(i) != '%'){
        text(s.charAt(i), x + i * 12, y);
      }
      else{
        intoken = !intoken;
        if(intoken)
          fill(255, 100, 0);
        else
          fill(0);
      }
    }
  }
  
  void newline(){
    //lines.add("");
    lines.add("");
    curline ++;
    curchar = 0;
    curtext = "";
  }
  
  void addline(String line){
    lines.add(line);
  }
  
  void delline(){
    if(lines.size() <= 1)
      return;
    lines.remove(curline);
    curline --;
    if(lines.size() > 0){
      curtext = lines.get(curline );
      curchar = lines.get(curline).length();
    }
  }
  
  void delchar(){
    if(curchar <= 0)
      return;
    else if(curchar == curtext.length() || curchar == curtext.length() - 1){
      curtext = curtext.substring(0, curtext.length() - 1);
      curchar --;
      return;
    }
    else{
      curtext = curtext.substring(0, curchar) + curtext.substring(curchar + 1, curtext.length());
    }
  }
  
  void addchar(int c){
    if(curtext.length() > 36)
      return;
    else{
      curtext = curtext + (char)c;
      curchar ++;
    }
  }
  
  void replacechar(int index, int c){
    if(index == curtext.length())
      addchar(c);
    else if(c < 128){
      curtext = curtext.substring(0, index) + (char)c + curtext.substring(index + 1);
      curchar ++;
    }
  }
  
  void moveLeft(){
    if(curchar > 0)
      curchar --;
  }
  
  void moveRight(){
    if(curchar < curtext.length())
      curchar ++;
  }
  
  boolean isEmpty(){
    if("".equals(curtext) && lines.size() == 1)
      return true;
    else
      return false;
  }
  
  Program outputPrgm(){
    lines.set(curline, curtext);
    
    Program temp = new Program();
    
    temp.prgm = new String[lines.size()];
    temp.name = getname();
    for(int i = 0; i < lines.size(); i ++){
      temp.prgm[i] = lines.get(i);
    }
    temp.encodeName();
    temp.encodeBody();
    log.debug();
    log.info("program length: " + temp.length);
    return temp;
  }
  
  void outputStrings(){
    if(isEmpty()){
      log.info("nothing to save");
      return;
    }
    
    lines.set(curline, curtext);
    String[] temp = new String[lines.size() + 1];
    temp[0] = getname();
    for(int i = 0; i < lines.size(); i ++){
      temp[i + 1] = lines.get(i);
    }
    saveStrings("\\output\\" + getname() + ".txt" , temp);
    log.info("saved ProgramField to file");
    log.debug();
  }
}