class Importer{
  ArrayList<String> sbytes;
  
  Importer(){
    sbytes = new ArrayList<String>();
  }
  
  void importtext(String filepath){
    String[] lines = loadStrings(filepath);
    if(lines == null || lines.length == 0)
      return;
    nameField.text = lines[0];
    nameField.setFocus();
    
    log.error("Uncomment me!");
    /*
    prgmField.lines = new ArrayList<String>();
    for(int i = 1; i < lines.length; i ++){
      prgmField.lines.add(lines[i].replace(Character.toString((char)27), ""));
    }
    
    prgmField.curtext = prgmField.lines.get(0);
    //*/
    
    //removing eof char
    /*
    String lastline = pfield.lines.get(pfield.lines.size() - 1);
    if(lastline.length() > 1)
      lastline = lastline.substring(0, lastline.length() - 1);
    else
      lastline = "";
    pfield.lines.set(pfield.lines.size() - 1, lastline);
    
    
    String lastline = prgmField.lines.get(0);
    if(lastline.length() > 1)
      lastline = lastline.substring(0, lastline.length() - 1);
    else
      lastline = "";
    prgmField.lines.set(0, lastline);
    */
  }
  
  void importbin(String filepath){
    log.info("importing " + filepath + " ...");
    log.printbar();
    byte[] bprgm = loadBytes(filepath);
    String temp = "";
    for(int i = 0; i < bprgm.length; i ++){
      sbytes.add(String.format("%02X", bprgm[i]));
      temp = temp + String.format("%02X", bprgm[i]) + " ";
        if((i + 1) % 16 == 0){
          log.debug(temp);
          temp = "";
        }
    }
    log.debug(temp);
    
    log.debug();
    log.debug("checking header...");
    log.printbar();
    //standard header
    log.debug("2A 2A 54 49 38 33 46 2A 1A 0A 00");
    temp = "";
    
    //actual header
    for(int i = 0; i < 0x0B; i ++){
      temp = temp + sbytes.get(i) + " ";
    }
    
    if("2A 2A 54 49 38 33 46 2A 1A 0A 00 ".equals(temp))
      log.debug(temp);
    else{
      log.warning(temp);
      log.warning("file may be corrupted");
    }
    
    log.debug();
    log.debug("reading comment...");
    log.printbar();
    String comment = strFromBytes(0x0B, 0x34);
    log.debug(comment);
    
    log.debug();
    log.debug("reading name...");
    log.printbar();
    temp = strFromBytes(0x3C, 0x43);
    if(temp.indexOf('[') != -1){
      char[] whydoihavetodealwiththeta = temp.toCharArray();
      for(int i = 0; i < whydoihavetodealwiththeta.length; i ++){
        if(whydoihavetodealwiththeta[i] == '[')
          whydoihavetodealwiththeta[i] = 'θ';
      }
      temp = new String(whydoihavetodealwiththeta);
    }
    log.debug(temp);
    nameField.text = temp.replace(" ", "");
    
    ArrayList<String> lines = new ArrayList<String>();
    String cline = "";
    for(int i = 0x4A; i < sbytes.size() - 2; i ++){
      String cur = String.format("%02X", bprgm[i]);
      
      if("3F".equals(cur)){
        //println(cline);
        lines.add(cline);
        cline = "";
      }
      //start of 2 byte command
      else if("BB".equals(cur) ||
         "5C".equals(cur) ||
         "5D".equals(cur) ||
         "5E".equals(cur) ||
         "60".equals(cur) ||
         "61".equals(cur) ||
         "62".equals(cur) ||
         "63".equals(cur) ||
         "7E".equals(cur) ||
         "AA".equals(cur) ||
         "BB".equals(cur) ||
         "EF".equals(cur)){
         cur = cur + String.format("%02X", bprgm[i + 1]);
         //println(detokenize(cur));
         //cline = cline + "%" + detokenize(cur) + "%";
         cline = cline + detokenize(cur);
         i ++;
       }
       else{
         //println(detokenize(cur));
         //cline = cline + "%" + detokenize(cur) + "%";
         cline = cline + detokenize(cur);
       }
    }
    println(cline);
    lines.add(cline);
    
    //ProgramField pfield = (ProgramField)elements.get(1);
    //NameField nfield = (NameField)elements.get(0);
    log.error("Uncomment me too!");
    //prgmField.lines = lines; 
    for(int i = 0; i < lines.size(); i ++){
      println(lines.get(i));
    }
    //prgmField.curtext = lines.get(0);
    nameField.setFocus();
    
  }
  
  void decode(String filepath){
    Program writeto = new Program();
    
    log.info("importing " + filepath + " ...");
    log.printbar();
    byte[] bprgm = loadBytes(filepath);
    String temp = "";
    for(int i = 0; i < bprgm.length; i ++){
      sbytes.add(String.format("%02X", bprgm[i]));
      temp = temp + String.format("%02X", bprgm[i]) + " ";
        if((i + 1) % 16 == 0){
          log.debug(temp);
          temp = "";
        }
    }
    log.debug(temp);
    
    log.debug();
    log.info("checking header...");
    log.printbar();
    //standard header
    log.debug("2A 2A 54 49 38 33 46 2A 1A 0A 00");
    temp = "";
    
    //actual header
    for(int i = 0; i < 0x0B; i ++){
      temp = temp + sbytes.get(i) + " ";
    }
    log.debug(temp);
    
    log.debug();
    log.debug("reading comment...");
    log.printbar();
    writeto.comment = strFromBytes(0x0B, 0x34);
    log.debug(writeto.comment);
    
    log.debug();
    log.debug("reading name...");
    log.printbar();
    writeto.name = strFromBytes(0x3C, 0x43);
    log.debug(writeto.name);
    
    ArrayList<String> lines = new ArrayList<String>();
    String cline = "";
    for(int i = 0x4A; i < sbytes.size() - 2; i ++){
      String cur = String.format("%02X", bprgm[i]);
      
      if("3F".equals(cur)){
        println(cline);
        lines.add(cline);
        cline = "";
      }
      //start of 2 byte command
      else if("BB".equals(cur) ||
         "5C".equals(cur) ||
         "5D".equals(cur) ||
         "5E".equals(cur) ||
         "60".equals(cur) ||
         "61".equals(cur) ||
         "62".equals(cur) ||
         "63".equals(cur) ||
         "7E".equals(cur) ||
         "AA".equals(cur) ||
         "BB".equals(cur) ||
         "EF".equals(cur)){
         cur = cur + String.format("%02X", bprgm[i + 1]);
         //println(detokenize(cur));
         //cline = cline + "%" + detokenize(cur) + "%";
         cline = cline + detokenize(cur);
         i ++;
       }
       else{
         //println(detokenize(cur));
         //cline = cline + "%" + detokenize(cur) + "%";
         cline = cline + detokenize(cur);
       }
    }
    //println(cline);
    lines.add(cline);
    
    String[] prgm = new String[lines.size() + 1];
    prgm[0] = writeto.name;
    for(int i = 0; i < lines.size(); i ++){
      prgm[i + 1] = lines.get(i);
    }
    saveStrings(writeto.name + ".txt", prgm);
    
  }
  
  String strFromBytes(int sbyte, int ebyte){
    String str = "";
    for(int i = sbyte; i <= ebyte; i ++){
      int chr = Integer.valueOf(sbytes.get(i), 16);
      if(chr != 0)
        str = str + (char)chr;
    }
    return str;
  }
  
  String detokenize(String hex){
    String output = "";
    int chr;
    if(rbytes.get(hex) != null){
      output = rbytes.get(hex);
      return output;
    }
    else if((output = rtokens.get(hex)) != null)
      return "§" + output + "§";
    else if((chr = Integer.valueOf(hex, 16)) < 128 && isalphanum((char)chr)){
      return Character.toString((char)chr);
    }
    else{
      log.error("can't detokenize " + hex);
      return "";
    }
  }
}