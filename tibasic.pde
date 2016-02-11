import java.util.Hashtable;
String ver = "0.11";

String filepath = "untitled.8px";
String[] ctokens;

Hashtable<String, String> tokens = new Hashtable<String, String>();

Program program;
Exporter exporter;

void settings(){
  size(500, 500);
}

void setup(){
  exporter = new Exporter();
  textFont(createFont("Lucida Console", 20));
  //String[] fontList = PFont.list();
  //printArray(fontList);
  
  println("Loading Tokens");
  printbar();
  //loading 1 char tokens
  println("loading single char tokens");
  ctokens = new String[128];
  int tokencount = 0;
  String[] loadtokens = loadStrings("tokens1.txt");
  for(int i = 0; i < loadtokens.length; i ++){
    int index = Integer.valueOf(loadtokens[i].substring(0, loadtokens[i].indexOf(',')));
    ctokens[index] = loadtokens[i].substring(loadtokens[i].indexOf(',') + 1, loadtokens[i].length());
    //println(ctokens[index]);
    tokencount ++;
  }
  println("loaded " + tokencount + " single char tokens");
  
  //loading multi char tokens
  println("loading multi-char tokens");
  tokencount = 0;
  loadtokens = loadStrings("tokens2.txt");
  for(int i = 0; i < loadtokens.length; i ++){
    if("//".equals(loadtokens[i].substring(0, 2))){
      println("    [COMMENT] " + loadtokens[i].substring(2, loadtokens[i].length()));
      continue;
    }
    String token, hex;
    token = loadtokens[i].substring(0, loadtokens[i].indexOf(','));
    hex = loadtokens[i].substring(loadtokens[i].indexOf(',') + 1, loadtokens[i].length());
    tokens.put(token, hex);
    tokencount ++;
  }
  println("loaded " + tokencount + " multi-char tokens");
  println();
}

void draw(){
  fill(0);
  textSize(20);
  program = new Program();
  exporter.export(program);
  noLoop();
}

boolean isalphanum(char c){
  if(c >= 48 && c <= 90)
    return true;
  else
    return false;
}

boolean isloweralpha(char c){
  if(c >= 97 && c <= 122)
    return true;
  else
    return false;
}

void printbar(){
  println("----------------");
}