class ProgramField extends TextField{
  int clindex = 0;//current line index
  int tlindex = 0;//top line index
  OpenLine curline;
    
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
        if(clindex > 0){
          setLine();
          clindex --;
          curline = new OpenLine(lines.get(clindex));
          if(clindex < tlindex)
            tlindex --;
        }
        setCursorDelay(10);
      }
      if(keyCode == LEFT){
        curline.moveLeft();
      }
      if(keyCode == DOWN){
        if(clindex + 1 < lines.size()){
          setLine();
          clindex ++;
          curline = new OpenLine(lines.get(clindex));
          if(clindex - tlindex > 21)
            tlindex ++;
        }
        setCursorDelay(10);
      }
      if(keyCode == RIGHT){
        curline.moveRight();
      }
    }
    
    else if(key == BACKSPACE){
      if(!curline.current.isEmpty())
        curline.removeChar();
      else if(curline.isEmpty() && clindex > 0){
        if(clindex < lines.size())
          lines.remove(clindex);
        clindex --;
        if(clindex < tlindex)
          tlindex --;
        curline = new OpenLine(lines.get(clindex));
      }
      else{
        curline.removeToken();
      }
    }
    else if(key == DELETE){
      if(!curline.current.isEmpty())
        curline.delChar();
      else if(curline.isEmpty() && clindex + 1 < lines.size()){
        
      }
      else{
        curline.deleteToken();
      }
    }
    else if(key == ENTER){
      if(curline.current.isEmpty()){
        lines.add(clindex, new Line(curline));
        curline = new OpenLine();
        clindex ++;
        if(clindex - tlindex > 21)
          tlindex ++;
      }
      else{
        curline.textTokenize();
      }
    }
    else if(key == TAB){
      return;
    }
    else if(key < 128){
      //space
      if(key == ' '){        
        if(curline.current.isEmpty()){
          curline.addChar(key);
          curline.tokenize();
          setCursorDelay(10);
        }
        else if(!tokenFactory.isTokenizable(curline.current.text)){
          curline.addChar(key);
        }
        else
          curline.tokenize();
      }
      else
        curline.addChar(key);
    }
  }
  
  void setLine(){
    if(clindex == lines.size())
      lines.add(new Line(curline));
    else
      lines.set(clindex, new Line(curline));
  }
  
  void onKeyUp(){ return; }
  
  void render(){
    fill(255);
    rect(x - 2, y - 2, w + 4, h + 4);
    
    for(int i = tlindex; i < lines.size(); i ++){
      if(i != clindex)
        lines.get(i).render(x, y + (i - tlindex) * 20);
    }
    
    curline.render(x, y + (clindex - tlindex) * 20);
    
    if(isFocus())
      curline.renderCur(x, y + (clindex - tlindex) * 20);
    }
  
  void addChar(int c){ return; }
  void replaceChar(int index, int c){ return; }
  
  void reset(){
    clindex = 0;
    tlindex = 0;
    curline = new OpenLine();
    lines = new ArrayList<Line>();
  }
  
  boolean isEmpty(){
    if(lines.isEmpty() && curline.isEmpty())
      return true;
    else
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
  Line(){}
  
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
        tokens[i].render(x + tokens[i].start, y);
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
  
  OpenLine(Line line){
    tokens = new ArrayList<Token>();
    for(int i = 0; i < line.tokens.length; i ++){
      tokens.add(line.tokens[i]);
    }
    current = new OpenToken();
    current.index = tokens.size();
    spaceTokens();
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
    if(current.removeChar()){
      if(current.index <= tokens.size()){
        for(int i = current.index; i < tokens.size(); i ++){
          tokens.get(i).start --;
        }
      }
    }
  }
  
  void delChar(){
    if(current.delChar()){
      if(current.index <= tokens.size()){
        for(int i = current.index; i < tokens.size(); i ++){
          tokens.get(i).start --;
        }
      }
    }
  }

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
  
  void deleteToken(){
    if(tokens.size() > 0 && current.index > 0 && current.index + 1 < tokens.size()){
      current.index ++;
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
  
  void textTokenize(){
    if(current.isEmpty())
      return;
    tokens.add(current.index, new Token(current.text, current.text, true));
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
  
  boolean isEmpty(){
    if(tokens.isEmpty() && current.isEmpty())
      return true;
    else
      return false;
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
  }
  
  //removes character at curchar
  boolean removeChar(){
    if(curchar == text.length() && text.length() > 0){
      text = text.substring(0, text.length() - 1);
      curchar --;
      return true;
    }
    else if(curchar > 0){
      text = text.substring(0, curchar - 1) + text.substring(curchar, text.length());
      curchar --;
      return true;
    }
    return false;
  }
  
  //removes character at curchar + 1
  //too lazy to write a seperate function for DELETE
  boolean delChar(){
    if(curchar == 0 && text.length() > 0){
      text = text.substring(1, text.length());
      return true;
    }
    else if(curchar < text.length()){
      text = text.substring(0, curchar) + text.substring(curchar + 1, text.length());
      return true;
    }
    return false;
  }
  
  void clear(){
    text = "";
    curchar = 0;
  }
  
  void render(float x, float y){
    fill(0);
    text(text, x + 12 * start, y);
    line(x + 12 * start, y + 20, x + 12 * (start + length()), y + 20);
    
    //text(index, 100, 100);
    //text(start, 100, 120);
    //text(curchar, 100, 140);
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