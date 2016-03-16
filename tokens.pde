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