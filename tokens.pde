//Name -> Hex string
Hashtable<String, String> tokens = new Hashtable<String, String>();

//Hex string -> Name
Hashtable<String, String> rtokens = new Hashtable<String, String>();
//Byte value -> Name (?)
Hashtable<String, String> rbytes = new Hashtable<String, String>();

void loadTokens(){
  log.debug("loading tokens...");
  printbar();
  
  
  //loading 1 char tokens
  log.debug("loading single char tokens");
  ctokens = new String[128];
  int tokencount = 0;
  String[] loadtokens = loadStrings("tokens1.txt");
  for(int i = 0; i < loadtokens.length; i ++){
    int index = Integer.valueOf(loadtokens[i].substring(0, loadtokens[i].indexOf(',')));
    ctokens[index] = loadtokens[i].substring(loadtokens[i].indexOf(',') + 1, loadtokens[i].length());
    tokencount ++;
    
    rbytes.put(ctokens[index], Character.toString((char)index));
  }
  log.info("loaded " + tokencount + " single char tokens");
  
  
  //loading multi char tokens
  log.debug("loading multi-char tokens");
  tokencount = 0;
  loadtokens = loadStrings("tokens2.txt");
  for(int i = 0; i < loadtokens.length; i ++){
    //comments
    if("//".equals(loadtokens[i].substring(0, 2))){
      log.debug("  " + loadtokens[i].substring(2, loadtokens[i].length()));
      continue;
    }
    if('#' == loadtokens[i].charAt(0) &&  ',' != loadtokens[i].charAt(1)){
      //silent comments
      continue;
    }
    String token, hex;
    token = loadtokens[i].substring(0, loadtokens[i].indexOf(','));
    hex = loadtokens[i].substring(loadtokens[i].indexOf(',') + 1, loadtokens[i].length());
    tokens.put(token, hex);
    rtokens.put(hex, token);
    tokencount ++;
  }
  log.info("loaded " + tokencount + " multi-char tokens");
  log.debug();
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
   
    //creates detokenizable token
    return new Token(input, input, true);
  }
  
  boolean isTokenizable(String input){
    Token testToken = getToken(input);
    if(testToken.display == testToken.store)
      return false;
    else
      return true;
  }
}

class Token{
  String display;
  String store;
  color c;
  int start;
  int length;
  
  boolean detokenizable = false;
  
  Token(){}
  
  Token(String store, String display){
    this.display = display;
    this.store = store;
    length = display.length();
    c = color(0);
  }
  
  Token(String store, String display, boolean detokenizable){
    this(store, display);
    this.detokenizable = detokenizable;
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
    fill(c);
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
    //fill(0);
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