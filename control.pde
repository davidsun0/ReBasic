//GUI element
abstract class Element{
  float x, y, w, h;
  
  //used to detect if mouse is inside boundaries
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
    w = 36;
    h = 16;
  }
  
  void render(){
    fill(0);
    textSize(15);
    text("SAVE", x, y);
  }
  
  void activate(){
    log.info("saving ProgramField to file");
    if(prgmField.isEmpty()){
      log.warning("nothing to save");
      return;
    }
    //Saves to file at filepath denoted by NameField
    prgmField.outputStrings();
  }
}

//Exports to .8px file
class ExportButton extends SaveButton{
  ExportButton(float x, float y){
    super(x, y);
    w = 54;
  }
  
  void render(){
    fill(0);
    textSize(15);
    text("EXPORT", x, y);
  }
  
  void activate(){
    log.info("exporting ProgramField to file");
    if(prgmField.isEmpty()){
      log.warning("nothing to export");
      return;
    }
    exporter.export(prgmField.outputPrgm());
  }
}

//Brings up file select dialogue to open file
class OpenButton extends SaveButton{
  OpenButton(float x, float y){
    super(x, y);
  }
  
  void render(){
    //fill(255);
    //rect(x, y, w, h);
    fill(0);
    textSize(15);
    text("OPEN", x, y);
  }
  
  void activate(){
    log.debug("opening file...");
    selectInput("Open program:", "openFile");
  }
}

//Clears the name and prgm fields
class NewButton extends SaveButton{
  NewButton(float x, float y){
    super(x, y);
  }
  
  void render(){
    //fill(255);
    //rect(x, y, w, h);
    fill(0);
    textSize(15);
    text("NEW", x, y);
  }
  
  void activate(){
    log.debug("new file");
    prgmField.reset();
    nameField.reset();
    focus = nameField;
  }
}

//activated by selection of a file from OpenButton dialogue
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
  
  //Makes sure typing goes inside this field
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
  
  void reset(){
    text = "";
    i = 0;
  }
  
  String gettext(){
    if(text == null || "".equals(text))
      return "UNTITLED";
    else
      return text;
  }
  
  void onKeyDown(){
    if(keyCode == BACKSPACE && text.length() > 0){
      //Removes char at end of text
      if(i == text.length()){
        i --;
        text = text.substring(0, text.length() - 1);
      }
      //If current char is last char, deletes without moving cursor
      else if(i == text.length() - 1){
        text = text.substring(0, text.length() - 1);
      }
      //Deletes char at cursor index
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
    
    //Moves cursor left or right
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
    
    //Exits out of NameField to PrgmField
    else if(keyCode == ENTER || key == TAB){
      focus = prgmField;
      setCursorDelay(20);
    }
    
    //add letter to cursor position
    else if(text.length() < 8 && i == text.length())
        addchar(key);
    else if(i < text.length())
      replacechar(i, key);
  }
  
  //Name must be uppercase alphanumeric
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
    text(text, x + 53, y);
    text("prgm", x, y);
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

//Cursor rendering
int cursorDelay = 0;

//renders blinking cursor
void renderCursor(float x, float y){
  if(cursorDelay != 0 || second() % 2 == 0){
    fill(0);
    rect(x, y, 12, 20);
  }
  
  if(cursorDelay > 0)
    cursorDelay --;
}

//shaded gray to show you can't type more
void renderCursorFull(float x, float y){
  if(second() % 2 == 0){
    fill(200);
    rect(x, y, 12, 20);
  }
}

//sets delay to keep cursor black for a while
void setCursorDelay(int delay){
  cursorDelay = delay;
}