class ProgramField extends TextField{
  int clindex = 0;//current line index
  int tlindex = 0;//top line index
  OpenLine curline;
  
  int curchar = 0;
  
  ArrayList<Line> lines = new ArrayList<Line>();
  
  ProgramField(float x, float y){
    this.x = x;
    this.y = y;
    this.w = 460;
    this.h = 440;
    
    curline = new OpenLine();
  }
  
  void onKeyDown(){
    if(key == CODED){
      if(keyCode == UP){
        
      }
      if(keyCode == LEFT){
        curline.moveLeft();
      }
      if(keyCode == DOWN){
        
      }
      if(keyCode == RIGHT){
        curline.moveRight();
      }
    }
    
    else if(key == BACKSPACE){
      if(!curline.current.isEmpty())
        curline.removeChar();
      else{
        curline.removeToken();
      }
    }
    else if(key == DELETE){
      
    }
    else if(key == ENTER){
      
    }
    else if(key == TAB){
      
    }
    else if(key < 128){
      //space
      if(key == ' ')
        curline.tokenize();
      else
        curline.addChar(key);
    }
  }
  
  void onKeyUp(){
    
  }
  
  void render(){
    fill(255);
    rect(x - 2, y - 2, w + 4, h + 4);
    
    curline.render(x, y);
    
    if(isFocus())
      curline.renderCur(x, y + (clindex - tlindex) * 20);
  }
  
  void addChar(int c){
    
  }
  
  void replaceChar(int index, int c){
    
  }
  
  void reset(){
    
  }
  
  boolean isEmpty(){
    return false;
  }
  
  void outputStrings(String filepath){
    
  }
  
  void outputStrings(){
    outputStrings("\\output\\" + getname() + ".txt");
  }
  
  Program outputPrgm(){
    return null;
  }
}

class Line{
  Token[] tokens;
  
  Line(OpenLine oline){
    oline.tokenize();
    tokens = new Token[oline.tokens.size()];
    for(int i = 0; i < tokens.length; i ++){
      tokens[i] = oline.tokens.get(i);
    }
  }
  
  void render(float x, float y){
    for(int i = 0; i < tokens.length; i ++){
      if(tokens[i] != null)
        tokens[i].render(x, y);
    }
  }
  
  void spaceTokens(){
    if(tokens != null){
      int start = 0;
      for(int i = 0; i < tokens.length; i ++){
        if(tokens[i] != null){
          tokens[i].start = start;
          start += tokens[i].length;
        }
      }
    }
  }
  
  String getText(){
    String line = "";
    for(int i = 0; i < tokens.length; i ++){
      if(tokens[i] != null)
        line = line + tokens[i].store;
    }
    return line;
  }
}

class OpenLine extends Line{
  ArrayList<Token> tokens;
  OpenToken current;
  
  OpenLine(){
    tokens = new ArrayList<Token>();
    current = new OpenToken();
  }
  
  void render(float x, float y){
    for(Token t : tokens){
      t.render(x + t.start, y);
    }
    current.render(x, y);
  }
  
  void renderCur(float x, float y){
    renderInsertCursor(x + 12 * (current.start + current.curchar), y);
  }
  
  void addChar(char c){
    current.addChar(c);
    if(current.index <= tokens.size()){
      for(int i = current.index; i < tokens.size(); i ++){
        tokens.get(i).start ++;
      }
    }
  }

  void removeChar(){
    current.removeChar();
     if(current.index <= tokens.size()){
      for(int i = current.index; i < tokens.size(); i ++){
        tokens.get(i).start --;
      }
    }
  }
  /*
  void removeToken(int index){
    if(index > 0 && index < tokens.size()){
      tokens.remove(index);
      if(current.index > index)
        current.index --;
    }
    else if(index == tokens.size() && index > 0){
      tokens.remove(tokens.size() - 1);
      if(current.index > index)
        current.index --;
    }
    spaceTokens();
  }
  */
  void removeToken(){
    if(tokens.size() > 0 && current.index > 0 && current.index <= tokens.size()){
      current.index --;
      if(tokens.get(current.index).detokenizable){
        detokenize();
        current.text = current.text.substring(0, current.text.length() - 1);
        spaceTokens();
        current.curchar = current.length();
        return;
      }
      else
        tokens.remove(current.index);
    }
    spaceTokens();
    current.curchar = 0;
  }
  
  void tokenize(){
    if(current.isEmpty())
      return;
    tokens.add(current.index, current.toToken());
    current.clear();
    current.index ++;
    spaceTokens();
    current.curchar = 0;
  }
  
  void detokenize(){
    if(!current.isEmpty())
      return;
    if(!tokens.isEmpty()){
      current.fromToken(tokens.get(tokens.size() - 1));
      current.index = tokens.size() - 1;
      tokens.remove(tokens.size() - 1);
    }
  }
  
  void spaceTokens(){
    if(tokens == null)
      return;
      
    int start = 0;
    for(int i = 0; i < tokens.size(); i ++){
      if(i == current.index){
        current.start = start;
        start += current.length();
        current.curchar = start;
      }
      if(tokens.get(i) != null){
        tokens.get(i).start = start;
        start += tokens.get(i).length;
      }
    }
    if(current.index == tokens.size()){
      current.start = start;
      current.curchar = 0;
      start += current.length();
    }
  }
  
  void moveLeft(){
    if((current.isEmpty() || current.curchar == 0 ) && current.index > 0){
      //move left a token
      tokenize();
      current.index --;
      spaceTokens();
      current.curchar = 0;
    }
    else if(current.curchar > 0){
      current.curchar --;
    }
    setCursorDelay(10);
  }
  
  void moveRight(){
    if(current.isEmpty() || (current.curchar == current.length() && current.index < tokens.size())){
      //move right a token
      tokenize();
      if(current.index < tokens.size())
        current.index ++;
      spaceTokens();
      current.curchar = 0;
    }
    else if(current.curchar < current.length()){
      current.curchar ++;
    }
    setCursorDelay(10);
  }
  
  String getText(){
    if(tokens == null)
      return null;
    String line = "";
    for(Token t : tokens){
      line = line + t.store;
    }
    return line;
  }
}

class OpenToken{
  int index;
  int start;
  int curchar;
  String text;
  
  OpenToken(){
    index = 0;
    start = 0;
    curchar = 0;
    text = "";
  }
  
  void fromToken(Token token){
    this.start = token.start;
    this.text = token.store;
    //is a token
    /*
    if(current.charAt(0) == '%' && current.charAt(current.length() - 1) == '%')
      current = current.substring(1, current.length() - 1);
    */
  }
  
  void addChar(char c){
    if(curchar == text.length()){
      text = text + c;
      curchar ++;
    }
    else if(curchar >= 0){
      text = text.substring(0, curchar) + c + text.substring(curchar);
      curchar ++;
    }
    
    if(start + curchar > 38){
      //print("new line");
    }
  }
  
  //removes character at curchar
  void removeChar(){
    if(curchar == text.length() && text.length() > 0){
      text = text.substring(0, text.length() - 1);
      curchar --;
    }
    else if(curchar > 0){
      text = text.substring(0, curchar - 1) + text.substring(curchar, text.length());
      curchar --;
    }
  }
  
  void clear(){
    text = "";
    curchar = 0;
  }
  
  void render(float x, float y){
    fill(0);
    text(text, x + 12 * start, y);
    line(x + 12 * start, y + 20, x + 12 * (start + length()), y + 20);
    
    text(index, 100, 100);
    text(start, 100, 120);
    text(curchar, 100, 140);
  }
  
  boolean isEmpty(){
    if(text == null || "".equals(text))
      return true;
    else
      return false;
  }
  
  int length(){
    if(text != null)
      return text.length();
    else{
      text = "";
      return 0;
    }
  }
  
  Token toToken(){
    return tokenFactory.getToken(text);
  }
}