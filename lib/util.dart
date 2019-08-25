String IntToIp(int i) {
  var a = i & 255;
  var b = i >> 8 & 255;
  var c = i >> 16 & 255;
  var d = i >> 24 & 255;
  return '$a.$b.$c.$d';
}

String IpsIdToName(int i) {
  switch(i) {
    case 1: return '电信';
    case 2: return '联通';
    case 32: return '移动';
    default:
      return 'unknow';
  }
}

String GetUrl(String args) {
  if (args.startsWith('/')) {
    args = args.substring(1);
  }
  return 'http://127.0.0.1:1986/' + args;
}