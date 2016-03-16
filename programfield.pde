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
        
      }
      if(keyCode == DOWN){
        
      }
      if(keyCode == RIGHT){
        
      }
    }
    
    else if(key == BACKSPACE){
      if(!"".equals(curline.current))
        curline.removeChar(curline.current.length());
      else
        curline.detokenize();
    }
    else if(key == DELETE){
      
    }
    else if(key == ENTER){
      if("".equals(curline.current))
        ;//new line
      else
        curline.tokenize();
    }
    else if(key == TAB){
      
    }
    else if(key < 128){
      curline.addChar(key);
    }
  }
  
  void onKeyUp(){
    
  }
  
  void render(){
    fill(255);
    rect(x, y, w, h);
    
    curline.render(x, y);
    
    if(isFocus())
      curline.renderCur(x, y + (clindex - tlindex) * 20);
  }
  
  void addchar(int c){
    
  }
  
  void replacechar(int index, int c){
    
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
  
  Line(){
    
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
  String current;
  int curchar;
  int currentTokenIndex;
  
  OpenLine(){
    tokens = new ArrayList<Token>();
    current = "";
    curchar = 0;
  }
  
  void render(float x, float y){
    for(Token t : tokens){
      t.render(x + t.start, y);
    }
    fill(0);
    text(current, x + 12 * currentTokenIndex, y);
  }
  
  void renderCur(float x, float y){
    renderCursor(x + 12 * curchar, y);
  }
  
  void addChar(char c){
    if(curchar - currentTokenIndex == current.length()){
      current = current + c;
      curchar ++;
    }
  }
  
  void removeChar(int index){
    if(index == current.length() && index > 0){
      current = current.substring(0, current.length() - 1);
      curchar --;
    }
    else if(index > 0)
      current = current.substring(0, index) + current.substring(index + 1, current.length());
  }
  
  void removeToken(int index){
    if(index > 0 && index < tokens.size()){
      tokens.remove(index);
    }
    else if(index == tokens.size() && index > 0){
      tokens.remove(tokens.size() - 1);
    }
    spaceTokens();
  }
  
  void tokenize(){
    if("".equals(current))
      return;
    tokens.add(tokenFactory.getToken(current));
    current = "";
    spaceTokens();
  }
  
  void detokenize(){
    tokenize();
    if(!tokens.isEmpty()){
      current = tokens.get(tokens.size() - 1).store;
      if(current.charAt(0) == '%' && current.charAt(current.length() - 1) == '%')
        current = current.substring(1, current.length() - 1);
      tokens.remove(tokens.size() - 1);
      spaceTokens();
      curchar = currentTokenIndex + current.length();
    }
  }
  
  void spaceTokens(){
    if(tokens == null)
      return;
      
    int start = 0;
    for(int i = 0; i < tokens.size(); i ++){
      if(tokens.get(i) != null){
        tokens.get(i).start = start;
        start += tokens.get(i).length;
      }
    }
    currentTokenIndex = start;
    curchar = start;
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

class Token{
  String display;
  String store;
  color c;
  int start;
  int length;
  
  Token(){}
  
  Token(String store, String display){
    this.display = display;
    this.store = store;
    length = display.length();
    c = color(0);
  }
  
  Token(String store, String display, color c){
    this(store, display);
    this.c = c;
  }
  
  void render(float x, float y){
    fill(c);
    text(display, x + 11 * start, y);
  }
}

//special rendering for ^-1
class InverseToken extends Token{
  InverseGlyph inverseGlyph;
  
  InverseToken(){
    display = " ";
    store = "%^-1%";
    c = color(0);
    length = 1;
    inverseGlyph = new InverseGlyph(0);
  }
  
  void render(float x, float y){
    inverseGlyph.render(x + 11 * start, y);
  }
}

class GlyphToken extends Token{
  Glyph[] glyphs;
  
  GlyphToken(String store, String display, Glyph ... sglyphs){
    this.store = store;
    this.display = display;
    glyphs = sglyphs;
    c = color(0);
    
    length = display.length();
  }
  
  GlyphToken(color c, String store, String display, Glyph ... sglyphs){
    this(store, display, sglyphs);
    this.c = c;
  }
  
  void render(float x, float y){
    fill(c);
    text(display, x + 11 * start, y);
    for(int i = 0; i < glyphs.length; i ++){
      glyphs[i].render(x + 11 * start, y);
    }
  }
}

TokenFactory tokenFactory; //loaded in setup()

class TokenFactory{
  String[][] prettyTokens;
  
  TokenFactory(){
    String[] rawPretty = loadStrings("tokens3.txt");
    int plength = 0;
    for(int i = 0; i < rawPretty.length; i ++){
      if(rawPretty[i].length() > 2 && !"//".equals(rawPretty[i].substring(0, 2)))
        plength ++;
    }
    
    int index = 0;
    prettyTokens = new String[plength][2];
    for(int i = 0; i < rawPretty.length; i ++){
      if(rawPretty[i].length() > 2 && !"//".equals(rawPretty[i].substring(0, 2)) && rawPretty[i].indexOf(',') != -1){
        prettyTokens[index][0] = rawPretty[i].substring(0, rawPretty[i].indexOf(','));
        prettyTokens[index][1] = rawPretty[i].substring(rawPretty[i].indexOf(',') + 1, rawPretty[i].length());
        index ++;
      }
    }
  }
  
  Token getToken(String input){
    if("^-1".equals(input)){
      return new InverseToken();
    }
    
    if("xroot(".equals(input))
      return new GlyphToken("%xroot(%", " √(", new SuperscriptGlyph('x', 0));
      
    if("rad".equals(input))
      return new GlyphToken("%rad%", " ", new SuperscriptGlyph('r', 0));
      
    //arcsin
    if("arcsin(".equals(input) || "sin^-1(".equals(input))
      return new GlyphToken("%" + input + "%", "sin (", new InverseGlyph(3));
    //arccos
    if("arccos(".equals(input) || "cos^-1(".equals(input))
      return new GlyphToken("%" + input + "%", "cos (", new InverseGlyph(3));
    //arctan
    if("arctan(".equals(input) || "tan^-1(".equals(input))
      return new GlyphToken("%" + input + "%", "tan (", new InverseGlyph(3));
      
    //arcsinh
    if("arcsinh(".equals(input) || "sinh^-1(".equals(input))
      return new GlyphToken("%" + input + "%", "sinh (", new InverseGlyph(4));
    //arccosh
    if("arccosh(".equals(input) || "cosh^-1(".equals(input))
      return new GlyphToken("%" + input + "%", "cosh (", new InverseGlyph(4));
    //arctanh
    if("arctanh(".equals(input) || "tanh^-1(".equals(input))
      return new GlyphToken("%" + input + "%", "tanh (", new InverseGlyph(4));
    
    //User variable tokens :Lists, r, Y
    if(input.length() == 2 && input.charAt(1) >= 48 && input.charAt(1) <= 57){
      int subscript = input.charAt(1) - 48;
      //L1 to L6
      if(input.charAt(0) == 'L' && subscript >= 1 && subscript <= 6)
        return new GlyphToken("%" + input + "%", "L ", new SubscriptGlyph((char)(input.charAt(1)), 1));
      //r1 to r6
      if(input.charAt(0) == 'r' && subscript >= 1 && subscript <= 6)
        return new GlyphToken("%" + input + "%", "r ", new SubscriptGlyph((char)(input.charAt(1)), 1));
      //Y0 to Y9
      if(input.charAt(0) == 'Y')
        return new GlyphToken("%" + input + "%", "Y ", new SubscriptGlyph((char)(input.charAt(1)), 1));
    }
    
    //X?T and Y?T
    if(input.length() == 3 && input.charAt(2) == 'T' && input.charAt(1) >= 49 && input.charAt(1) <= 54){
      if(input.charAt(0) == 'X' || input.charAt(0) == 'Y')
        return new GlyphToken("%" + input + "%", input.charAt(0) + "  ", new SubscriptGlyph((char)(input.charAt(1)), 1), new SubscriptGlyph('T', 2));
    }
    
    //xbar
    if("xbar".equals(input)){
      return new GlyphToken("%xbar%", "x", new AccentGlyph('¯', 0));
    }
    //ybar
    if("ybar".equals(input)){
      return new GlyphToken("%ybar%", "y", new AccentGlyph('¯', 0));
    }
    
    //p hat and variants
    if("phat".equals(input) || "char phat".equals(input) || "char p-hat".equals(input))
      return new GlyphToken("%" + input + "%", "p", new AccentGlyph('ˆ', 0));
    if("phat1".equals(input))
      return new GlyphToken("%phat1%", "p ", new AccentGlyph('ˆ', 0), new SubscriptGlyph('1', 1));
    if("phat2".equals(input))
      return new GlyphToken("%phat2%", "p ", new AccentGlyph('ˆ', 0), new SubscriptGlyph('2', 1));
    if("char phat".equals(input) || "char p-hat".equals(input)){
      return new GlyphToken("%char phat%", "p", new AccentGlyph('ˆ', 0));
    }
    
    //statistics n1 and n2
    if(input.length() == 2 && input.charAt(0) == 'n' && (input.charAt(1) == '1' || input.charAt(1) == '2')){
      return new GlyphToken("%" + input + "%", "n ", new SubscriptGlyph(input.charAt(1), 1));
    }
    
    //x1, x2, x3, y1, y2, y3
    if(input.length() == 7 && "stat ".equals(input.substring(0, 5)) && (input.charAt(6) == '1' || input.charAt(6) == '2' || input.charAt(6) == '3')){
      if(input.charAt(5) == 'x')
        return new GlyphToken("%" + input + "%", "x ", new SubscriptGlyph(input.charAt(6), 1));
      if(input.charAt(5) == 'y')
        return new GlyphToken("%" + input + "%", "y ", new SubscriptGlyph(input.charAt(6), 1));
    }
    
    //Statistics Sx1, Sx2, xbar1, xbar2
    if("Sx1".equals(input) || "Sx2".equals(input))
      return new GlyphToken("%" + input + "%", "Sx ", new SubscriptGlyph(input.charAt(2), 2));
    if("xbar1".equals(input) || "xbar2".equals(input))
      return new GlyphToken("%" + input + "%", "x ", new AccentGlyph('¯', 0), new SubscriptGlyph(input.charAt(4), 1));
    
    //image tokens
    if("invertedequal".equals(input) || "biguparrow".equals(input) || "bigdownarrow".equals(input) || "squaremark".equals(input))
      return new GlyphToken("%" + input + "%", " ", new ImageGlyph("glyphs/" + input + ".png", 0));
    if("+mark".equals(input) || "crossmark".equals(input) || "plusmark".equals(input))
      return new GlyphToken("%crossmark%", " ", new ImageGlyph("glyphs/plusmark.png", 0));
    if(".mark".equals(input) || "dotmark".equals(input))
      return new GlyphToken("%dotmark%", " ", new ImageGlyph("glyphs/dotmark.png", 0));
    if("angle".equals(input))
      return new GlyphToken("%angle%", " ", new ImageGlyph("glyphs/angleglyph.png", 0));
    
    for(int i = 0; i < prettyTokens.length; i ++){
      if(prettyTokens[i][0].equals(input)){
        return new Token("%" + input + "%", prettyTokens[i][1]);
      }
    }
    
    if(tokens.containsKey(input)){
      return new Token("%" + input + "%", input, color(255, 100, 0));
    }
    return new Token(input, input);
  }
}

//for symbols not included in Unicode
abstract class Glyph{ 
  int index;
  abstract void render(float x, float y);
}

class InverseGlyph extends Glyph{
  InverseGlyph(int index){
    this.index = index;
  }
  
  void render(float x, float y){
    fill(0);
    textSize(10);
    text("-1", x + 1 + 11 * index, y);
    textSize(20);
  }
}

class SubscriptGlyph extends Glyph{
  char c;
  
  SubscriptGlyph(char c){
    this.c = c;
  }
  
  SubscriptGlyph(char c, int i){
    this.c = c;
    this.index = i;
  }
  
  void render(float x, float y){
    textSize(10);
    text(c, x + index * 11, y + 10);
    textSize(20);
  }
}

class SuperscriptGlyph extends Glyph{
  char c;
  
  SuperscriptGlyph(char c, int i){
    this.c = c;
    this.index = i;
  }
  
  void render(float x, float y){
    textSize(10);
    text(c, x + index * 11 + 4, y);
    textSize(20);
  }
}

class AccentGlyph extends Glyph{
  char c;
  
  AccentGlyph(char accent, int i){
    this.c = accent;
    index = i;
  }
  
  void render(float x, float y){
    text(c, x + index * 11, y + 2);
  }
}

class ImageGlyph extends Glyph{
  PImage image;
  
  ImageGlyph(String filepath, int i){
    image = loadImage(filepath);
    this.index = i;
  }
  
  void render(float x, float y){
    image(image, x + index * 11, y);
  }
}

//*/