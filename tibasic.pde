import java.util.Hashtable;
import java.awt.event.KeyEvent;
final String ver = "0.12";

String filepath = "untitled.8xp";

//1 char tokens
String[] ctokens;

//sets up autosave on close
DisposeHandler dh;

Exporter exporter;
Importer importer;
ConsoleLog log;

//Textfields and GUI elements
ArrayList<Element> elements;
TextField focus;
ProgramField prgmField;
NameField nameField;

void settings(){
  size(800, 500);
}

void setup(){
  surface.setTitle("ReBasic ver " + ver);
  dh = new DisposeHandler(this);
  
  log = new ConsoleLog();
  exporter = new Exporter();
  importer = new Importer();
  tokenFactory = new TokenFactory();
  
  //gets monospace font
  textFont(createFont("Lucida Console", 20));
  println(textWidth("X"));
  
  //loads from tokens1.txt and tokens2.txt
  loadTokens();
  
  //adding GUI elements
  prgmField = new ProgramField(20, 40);
  nameField = new NameField(20, 10);
  elements = new ArrayList<Element>();
  elements.add(focus = nameField);
  elements.add(prgmField);
  elements.add(new NewButton(299, 15));
  elements.add(new OpenButton(336, 15));
  elements.add(new SaveButton(380, 15));
  elements.add(new ExportButton(426, 15));
  
  //importer loads file from last autosave
  importer.importtext("..\\autosave.txt");
  
  textAlign(LEFT, TOP);
}

void draw(){
  background(250);
  log.render(500, 0);
  for(Element e : elements){
    e.render();
  }
}

void keyPressed(){
  //uncomment after can get current char from prgmfield
  //if(keyCode == KeyEvent.VK_F1)
    //((ProgramField)elements.get(1)).getchar();
  if(keyCode == KeyEvent.VK_F12){
    saveFrame("screenshot####.png");
    log.notif("saved screenshot");
  }
  focus.onKeyDown();
}

void mousePressed(){
  for(Element e : elements){
    if(e.isInside(mouseX, mouseY))
      e.onMouseDown();
  }
}

//Gets name text from NameField
String getname(){
  if(elements.get(0) instanceof NameField)
    return ((NameField)elements.get(0)).getFileName();
  else{
    log.error("Element 0 not NameField");
    return "UNTITLED";
  }
}

//is char acceptable to input to program
//alpha-numeric
boolean isalphanum(char c){
  if((c >= 48 && c <= 57) || (c >= 65 && c <= 90))
    return true;
  else
    return false;
}

//lowercase letter
boolean isloweralpha(char c){
  if(c >= 97 && c <= 122)
    return true;
  else
    return false;
}

//just prints "---------" to console
void printbar(){
  log.printbar();
}

//Activates on close
public class DisposeHandler {
   
  DisposeHandler(PApplet pa)
  {
    pa.registerMethod("dispose", this);
  }
   
  public void dispose()
  {      
    //Code executes on exit
    log.notif("Autosaving");
    prgmField.outputStrings("autosave.txt");
  }
}