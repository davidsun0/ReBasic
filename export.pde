class Exporter{
  ArrayList<String> bytes;
  
  Exporter(){
    //bytes = new ArrayList<String>();
  }
  
  void export(Program p){
    bytes = new ArrayList<String>();
    filepath = p.name + ".8xp";
    log.debug();
    log.info("Exporting program to " + filepath);
    printbar();
    log.info("adding header...");
    addHeader();
    addComment(p.comment);
    log.info("adding metadata...");
    addWord(p.length + 19);
    addByte("0D"); addByte("00");
    addWord(p.length + 2);
      if(p.archived)
        addByte("06");
      else
        addByte("05");
    log.info("adding name...");
    addBytes(p.bname);
    log.info("adding other data...");
    addByte("00"); addByte("00");
    addWord(p.length + 2);
    addWord(p.length);
    log.info("adding body..");
    addBytes(p.bprgm);
    log.info("adding checksum...");
    addCheckSum();
    log.info("saving file...");
    flushBytes();
    log.debug();
    log.info("exported " + filepath);
  }
  
  void toBytes(String s){
    for(int i = 0; i < s.length(); i ++){
      if(isalphanum(s.charAt(i)))
        addByte((int)s.charAt(i));
    }
  }
  
  void addByte(String hex){
    //must be a 2 digit hex code
    //00, 01, etc
    if(hex.length() == 4){
      addByte(hex.substring(0, 2));
      addByte(hex.substring(2, 4));
      return;
    }
    else if(hex.length() != 2){
      log.warning("bad hex code: " + hex);
      return;
    }
    
    bytes.add(hex);
  }
  
  void addBytes(String[] hexes){
    for(int i = 0; i < hexes.length; i ++){
      bytes.add(hexes[i]);
    }
  }
  
  void addBytes(ArrayList<String> hexes){
    for(int i = 0; i < hexes.size(); i ++){
      bytes.add(hexes.get(i));
    }
  }
  
  void addByte(int n){
    if(n > 255 || n < 0){
      log.warning("bad byte inuput");
      return;
    }
    
    bytes.add(Integer.toHexString(n));
  }
  
  void addWord(int n){
    if(n > 65536 || n < 0){
      log.warning("bad word input");
      log.info("... bit shifting...");
      n = n << 24;
      n = n >> 24;
    }
    
    String temp = Integer.toHexString(n);
    if(n < 0x0F)
      temp = "0" + temp;
    
    String a, b;
    a = temp.substring(temp.length() - 2, temp.length());
    if(temp.length() == 4){
      b = temp.substring(0, 2);
    }
    else if(temp.length() == 3){
      b = "0" + temp.charAt(0);
    }
    else if(temp.length() == 2){
      b = "00";
    }
    else{
      b = "";
    }
    log.info("    word " + n + " : " + temp + " -> " + a + " " + b);
    bytes.add(a);
    bytes.add(b);
  }
  
  void addCheckSum(){
    int sum = 0;
    for(int i = 0x37; i < bytes.size(); i ++){
      sum += Integer.valueOf(bytes.get(i), 16);
    }
    sum = sum % 65535;
    addWord(sum);
    //addByte("44");
    //addByte("02");
  }
  
  void flushBytes(){
    log.info("saving to " + filepath);
    int temp;
    byte[] output = new byte[bytes.size()];
    
    String line = "";
    for(int i = 0; i < bytes.size(); i ++){
      if((temp = Integer.decode("0x" + bytes.get(i))) > 127){
        output[i] = (byte)(temp & 0xFF);
        //output[i] = Byte.decode("0x" + bytes.get(i));
      }
      else{
        output[i] = Byte.decode("0x" + bytes.get(i));
      }
      line = line + bytes.get(i) + " ";
      if((i + 1) % 16 == 0){
        log.debug(line);
        line = "";
      }
    }
    log.debug(line);
    saveBytes(filepath, output);
  }
  
  void addHeader(){
    String[] hstrings = split("2A 2A 54 49 38 33 46 2A 1A 0A 00" , " ");
    for(int i = 0; i < hstrings.length; i ++){
      addByte(hstrings[i]);
    }
  }
  
  void addComment(){
    for(int i = 0; i < 42; i ++){
      addByte("00");
    }
  }
  
  void addComment(String comment){
    log.info("adding comment: " + comment);
    for(int i = 0; i < 41; i ++){
      if(i >= comment.length())
        addByte("00");
      else
        addByte(Integer.toHexString(comment.charAt(i)));
    }
    addByte("00");
  }

}