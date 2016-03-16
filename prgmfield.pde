/*
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
      else if(curline > 0 && curchar == 0){
        if(curtext.length() == 1){
          delchar();
        }
        else if(curline > 0){
          curtext = lines.get(curline - 1) + curtext;
          curline --;
          curchar = lines.get(curline).length();
          lines.remove(curline + 1);
        }
      }
      else if(curchar > 0){
        if(curchar == curtext.length())
          delchar();
        else{
          delchar();
          curchar --;
        }
      }
      
      else if(curchar == 0){
        //delchar();
      }
      
      if(curline < topline)
        topline --;
      setCursorDelay(10);
    }
    else if(key == DELETE){
      if(curchar != curtext.length())
        delchar();
      if(curchar == curtext.length() && curline < lines.size() - 1){
        curtext = curtext + lines.get(curline + 1);
        lines.remove(curline + 1);
      }
    }
    else if(key == ENTER){
      if(curchar != curtext.length()){
        lines.add(curline + 1, curtext.substring(curchar, curtext.length()));
        lines.set(curline, curtext.substring(0, curchar));
        curline ++;
        curchar = 0;
        curtext = lines.get(curline);
      }
      else{
        lines.set(curline, curtext);
        newline();
      }
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
      else if(keyCode == DOWN){
        moveDown();
        setCursorDelay(10);
      }
      else if(keyCode == UP){
        moveUp();
        setCursorDelay(10);
      }
    }
    else if(key == TAB){
      
    }
    else if(key < 128){
      replacechar(curchar, key);
      setCursorDelay(10);
    }
  }
  
  void onMouseDown(){
    setFocus();
  }
  
  void render(){
    fill(255);
    rect(x, y, w, h);
    for(int i = topline; i < lines.size(); i ++){
      if(i != curline)
        renderLine(lines.get(i), y + (i - topline) * 20);
      else
        renderLine(curtext, y + (i - topline) * 20);
        
      if(i > topline + 20)
        break;
    }
    if(isFocus()){
      if(curtext.length() == 37 && curchar == 37)
        renderCursorFull(x + 12 * curchar + 4, y + (curline - topline) * 20);
      else
        renderCursor(x + 12 * curchar, y + (curline - topline) * 20);
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
  
  void reset(){
    lines = new ArrayList<String>();
    topline = 0;
    curline = 0;
    curchar = 0;
    curtext = "";
    addline(curtext);
  }
  
  void newline(){
    curline ++;
    curchar = 0;
    curtext = "";
    lines.add(curline, "");
    if(curline > topline + 20)
      topline ++;
  }
  
  void addline(String line){
    lines.add(line);
  }
  
  void delline(){
    if(lines.size() <= 1 || curline == 0)
      return;
    lines.remove(curline);
    curline --;
    if(lines.size() > 0){
      curtext = lines.get(curline);
      curchar = lines.get(curline).length();
    }
  }
  
  void delchar(){
    if(curchar <= 0)
      return;
    else if(curchar == curtext.length()){
      curtext = curtext.substring(0, curtext.length() - 1);
      curchar --;
      return;
    }
    else if(curchar == curtext.length() - 1){
      curtext = curtext.substring(0, curtext.length() - 1);
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
  
  void getchar(){
    if(curchar < curtext.length())
      println((int)curtext.charAt(curchar));
  }
  
  void moveLeft(){
    if(curchar > 0)
      curchar --;
  }
  
  void moveRight(){
    if(curchar < curtext.length())
      curchar ++;
  }
  
  void moveDown(){
    if(curline < lines.size() - 1){
      lines.set(curline, curtext);
      curline ++;
      curtext = lines.get(curline);
      if(curchar > curtext.length())
        curchar = curtext.length();
      if(curline > topline + 21)
        topline ++;
    }
  }
  
  void moveUp(){
    if(curline > 0){
      lines.set(curline, curtext);
      curline --;
      curtext = lines.get(curline);
      if(curchar > curtext.length())
        curchar = curtext.length();
      if(curline < topline)
      topline --;
    }
  }
  
  boolean isEmpty(){
    if(lines.size() > 0)
      lines.set(curline, curtext);
    
    if(lines.size() == 0)
      return true;
    if("".equals(lines.get(0)) && lines.size() == 1)
      return true;
    else
      return false;
  }
  
  Program outputPrgm(){
    if(lines.size() > 0)
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
    outputStrings("\\output\\" + getname() + ".txt");
  }
  
  void outputStrings(String filepath){
    if(isEmpty()){
      return;
    }
    
    lines.set(curline, curtext);
    String[] temp = new String[lines.size() + 1];
    temp[0] = getname();
    for(int i = 0; i < lines.size(); i ++){
      temp[i + 1] = lines.get(i);
    }
    saveStrings(filepath , temp);
    log.info("saved ProgramField to file");
    log.debug();
  }
}
*/