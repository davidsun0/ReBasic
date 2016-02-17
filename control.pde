abstract class Element{
  float x, y, w, h;
  
  boolean isInside(float x, float y){
    if(this.x < x && this.y < y && this.x + w > x && this.y + h > y)
      return true;
    else
      return false;
  }
  
  abstract void render();
  
  abstract void onMouseDown();
  abstract void onMouseUp();
  
  abstract void onKeyDown();
  abstract void onKeyUp();
}

abstract class Button extends Element{
  abstract void activate();
  
  void onMouseDown(){
    activate();
  }
  
  void onMouseUp(){
    return;
  }
  
  void onKeyDown(){
    return;
  }
  
  void onKeyUp(){
    return;
  }
}

class SaveButton extends Button{
  SaveButton(float x, float y){
    this.x = x;
    this.y = y;
    w = 20;
    h = 16;
  }
  
  void render(){
    fill(100, 255, 100);
    rect(x, y, w, h);
  }
  
  void activate(){
    log.info("saving ProgramField to file");
    if(elements.get(1) instanceof ProgramField)
      ((ProgramField)elements.get(1)).outputStrings();
    else
      log.error("Element 1 not ProgramField");
  }
}

class ExportButton extends SaveButton{
  ExportButton(float x, float y){
    super(x, y);
  }
  
  void render(){
    fill(100, 100, 255);
    rect(x, y, w, h);
  }
  
  void activate(){
    log.info("exporting ProgramField to file");
    if(elements.get(1) instanceof ProgramField)
      exporter.export(((ProgramField)elements.get(1)).outputPrgm());
    else
      log.error("Element 1 not ProgramField");
  }
}

class OpenButton extends SaveButton{
  OpenButton(float x, float y){
    super(x, y);
  }
  
  void render(){
    fill(255);
    rect(x, y, w, h);
  }
  
  void activate(){
    log.debug("opening file");
    selectInput("Select a file to process:", "openFile");
  }
}

void openFile(File selected){
  if(selected == null){
    log.info("no file selected");
    return;
  }
  
  String path = selected.getAbsolutePath();
  log.info("loading " + path);
  String extention = path.substring(path.length() - 4, path.length());
  if(".txt".equals(extention)){
    importer.importtext(path);
  }
  else if(".8xp".equals(extention)){
    importer.importbin(path);
  }
  else{
    log.error("unsupported file type");
  }
}

abstract class TextField extends Element{
  
  abstract void addchar(int c);
  abstract void replacechar(int index, int c);
  abstract void render();
  
  void setFocus(){
    focus = this;
  }
  
  boolean isFocus(){
    if(this != focus)
      return false;
    else
      return true;
  }
  
  void onMouseDown(){
    setFocus();
  }
  
  void onMouseUp(){
    return;
  }
  
  void onKeyUp(){
    return;
  }
}

class NameField extends TextField{
  String text = "";
  int i = 0;
  
  NameField(float x, float y){
    this.x = x;
    this.y = y;
    w = 164;
    h = 24;
  }
  
  String gettext(){
    if(text == null || "".equals(text))
      return "UNTITLED";
    return text;
  }
  
  void onKeyDown(){
    if(keyCode == BACKSPACE && text.length() > 0){
      if(i == text.length()){
        i --;
        text = text.substring(0, text.length() - 1);
      }
      else if(i == text.length() - 1){
        text = text.substring(0, text.length() - 1);
      }
      else{
        text = text.substring(0, i) + text.substring(i + 1);
      }
    }
    else if(key == DELETE){
      if(i == text.length() - 1)
        text = text.substring(0, text.length() - 1);
      else if(text.length() > 0){
        text = text.substring(0, i) + text.substring(i + 1, text.length());
      }
    }
    else if(key == CODED){
      if(keyCode == LEFT){
        if(i > 0)
          i --;
      }
      else if(keyCode == RIGHT){
        if(i < 7 && i < text.length())
          i ++;
      }
    }
    else if(keyCode == ENTER || key == TAB){
      //hopefully that's the prgmfield
      if(elements.get(1) instanceof ProgramField){
        focus = (ProgramField)elements.get(1);
        setCursorDelay(20);
      }
      else
        log.error("Element 1 not ProgramField");
    }
    else if(text.length() < 8 && i == text.length())
        addchar(key);
    else if(i < text.length())
      replacechar(i, key);
  }
  
  void addchar(int c){
    if(c < 128 && (isalphanum((char)c) || isloweralpha((char)c))){
      text = text + (char)c;
      text = text.toUpperCase();
      i ++;
    }
  }
  
  void replacechar(int index, int c){
    if(c < 128 && (isalphanum((char)c) || isloweralpha((char)c))){
      text = text.substring(0, index) + (char)c + text.substring(index + 1);
      text = text.toUpperCase();
      i ++;
    }
  }
  
  void render(){
    fill(0);
    textSize(20);
    text(text, x + 53, y + 18);
    text("prgm", x, y + 18);
    if(isFocus()){
      if(i == 8 && text.length() == 8){
        renderCursorFull(x + 54 + i * 12, y);
      }
      else
        renderCursor(x + 53 + i * 12, y);
    }
  }
  
  void setFocus(){
    focus = this;
    i = text.length();
  }
}

class CommentField extends TextField{
  String text = "";
  
  CommentField(float x, float y){
    this.x = x;
    this.y = y;
    w = 492;
    h = 20;
  }
  
  void onKeyDown(){
    if(keyCode == BACKSPACE){
      if(text.length() > 0)
        text = text.substring(0, text.length() - 1);
      //else if(line.length() == 1)
        //line = "";
    }
    else if(keyCode == ENTER || keyCode == RETURN){
      
    }
    else if(text.length() < 41){
      addchar(key);
    }
  }
  
  void addchar(int c){
    if(key < 128){
      text = text + (char)c;
    }
  }
  
  void replacechar(int index, int c){
    
  }
  
  void render(){
    //fill(255);
    //rect(x, y, 100, 20);
    fill(0);
    textSize(20);
    text(text, x + 2, y + 18);
  }
}

int cursorDelay = 0;

void renderCursor(float x, float y){
  if(cursorDelay != 0 || second() % 2 == 0){
    fill(0);
    rect(x, y, 12, 20);
  }
  
  if(cursorDelay > 0)
    cursorDelay --;
}

void renderCursorFull(float x, float y){
  if(second() % 2 == 0){
    fill(200);
    rect(x, y, 12, 20);
  }
}

void setCursorDelay(int delay){
  cursorDelay = delay;
}