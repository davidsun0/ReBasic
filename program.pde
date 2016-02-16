class Program{
  String name;
  String[] bname = new String[8];
  String comment = "REbasic ver " + ver;
  boolean archived = false;
  
  String[] prgm;
  ArrayList<String> bprgm;
  int length;
  
  Program(){
    ;
  }
  
  Program(String file){
    String lines[] = loadStrings(file);
    name = lines[0];
    prgm = new String[lines.length - 1];
    for(int i = 0; i < prgm.length; i ++){
      prgm[i] = lines[i + 1];
    }
    
    encodeName();
    encodeBody();
    //printBody();
    log.debug();
    log.info("program length: " + length);
  }
  
  void tokenbytes(String hex){
    if(hex.length() == 2){
      bprgm.add(hex);
      length ++;
    }
    else if(hex.length() == 4){
      bprgm.add(hex.substring(0, 2));
      bprgm.add(hex.substring(2, 4));
      length += 2;
    }
    else{
      log.debug();
      log.warning("bad bprgm hex: " + hex);
      log.debug();
    }
  }
  
  void encodeName(){
    log.info("encoding name: " + name);
    printbar();
    String namebytes = "";
    for(int i = 0; i < 8; i ++){
      if(i >= name.length() || !isalphanum(name.charAt(i)))
        //pretty sure only alphanumeric chars are allowed
        bname[i] = "00";
      else
        bname[i] = Integer.toHexString(name.charAt(i));
      
      namebytes += (bname[i] + " ");
    }
    log.debug(namebytes);
    log.debug();
  }
  
  void encodeBody(){
    log.info("encoding body...");
    printbar();
    bprgm = new ArrayList<String>();
    for(int i = 0; i < prgm.length; i ++){
      if(i > 0){
        tokenbytes("3F");
      }
      
      for(int j = 0; j < prgm[i].length(); j ++){
        int currchar = prgm[i].charAt(j);
        
        //alpha numeric char (capitals only)
        if(isalphanum(prgm[i].charAt(j))){
          tokenbytes(Integer.toHexString(prgm[i].charAt(j)));
        }
        
        //sign for tokenizer
        else if(currchar == '%'){
          
          //detecting %%% to allow for %
          //but %percent% is prefered
          if(j < prgm[i].length() - 2 && '%' == prgm[i].charAt(j + 1) && '%' == prgm[i].charAt(j + 2)){
            prgm[i] = prgm[i].substring(0, j) + prgm[i].substring(j + 2, prgm[i].length());
            log.debug(prgm[i]);//hopefully this works
            tokenbytes(tokens.get("%"));
          }
          
          //tokenizing
          String token;
          token = prgm[i].substring(j + 1, prgm[i].indexOf('%', j + 1));
          prgm[i] = prgm[i].substring(0, j) + prgm[i].substring(prgm[i].indexOf('%', j + 1) + 1, prgm[i].length());
          log.info("encoding token " + token + " on line " + (i+1) + " to " + tokens.get(token));
          
          //bprgmBytes also increments length
          if(tokens.get(token) != null)
            tokenbytes(tokens.get(token));
          else
            log.warning("bad token: " + token);
          j --;
        }
        else{
          //if the token is in the lookup table
          if(currchar < ctokens.length && ctokens[currchar] != null){
            tokenbytes(ctokens[currchar]);
          }
        }
      }
    }
  }
  
  void printBody(){
    String line = "";
    for(int i = 0; i < bprgm.size(); i ++){
      line = line + bprgm.get(i) + " ";
      if((i + 1) % 16 == 0){
        log.debug(line);
        line = "";
      }
    }
    log.debug(line);
  }
}