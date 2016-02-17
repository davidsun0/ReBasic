import java.util.Hashtable;
String ver = "0.12";

String filepath = "untitled.8px";
String[] ctokens;

DisposeHandler dh;

Program program;
Exporter exporter;
Importer importer;
ConsoleLog log;

ArrayList<Element> elements;
TextField focus;

void settings(){
  size(800, 500);
}

void setup(){
  dh = new DisposeHandler(this);
  
  log = new ConsoleLog();
  exporter = new Exporter();
  importer = new Importer();
  
  textFont(createFont("Lucida Console", 20));
  //String[] fontList = PFont.list();
  //printArray(fontList);
  
  loadTokens();
  
  elements = new ArrayList<Element>();
  elements.add(focus = new NameField(20, 10));
  elements.add(new ProgramField(20, 40));
  elements.add(new SaveButton(300, 14));
  elements.add(new ExportButton(330, 14));
  elements.add(new OpenButton(360, 14));
  //elements.add(new CommentField(0, 30));
}

void draw(){
  background(250);
  //program = new Program("input.txt");
  //exporter.export(program);
  //importer.decode("CHARTEST.8xp");
  log.render(500, 0);
  for(Element e : elements){
    e.render();
  }
}

void keyPressed(){
  focus.onKeyDown();
}

void mousePressed(){
  for(Element e : elements){
    if(e.isInside(mouseX, mouseY))
      e.onMouseDown();
  }
}

String getname(){
  if(elements.get(0) instanceof NameField)
    return ((NameField)elements.get(0)).gettext();
  else{
    log.error("Element 0 not NameField");
    return "UNTITLED";
  }
}

boolean isalphanum(char c){
  if((c >= 48 && c <= 57) || (c >= 65 && c <= 90))
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
  log.printbar();
}

public class DisposeHandler {
   
  DisposeHandler(PApplet pa)
  {
    pa.registerMethod("dispose", this);
  }
   
  public void dispose()
  {      
    println("Closing sketch");
    // Place here the code you want to execute on exit
    log.notif("Autosaving");
    if(elements.get(1) instanceof ProgramField){
      ((ProgramField)elements.get(1)).outputStrings();
    }
    else{
      log.error("Element 1 is not ProgramField");
    }
  }
}