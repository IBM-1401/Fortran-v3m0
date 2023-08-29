               JOB  Fortran compiler -- IF Cond Phase -- phase 44
               CTL  6611
     *
     * In-line instructions are generated for IF ( SENSE SWITCH i )
     * and IF ( SENSE LIGHT i )
     *
     x1        equ  89
     x2        equ  94
     x3        equ  99
     *
     * Stuff in the resident area
     *
     phasid    equ  110  Phase ID, for snapshot dumps
     glober    equ  184  Global error flag -- WM means error
     snapsh    equ  333  Core dump snapshot
     loadnx    equ  700  Load next overlay
     clearl    equ  707  CS at start of overlay loader
     cdovly    equ  769  1 if running from cards, N if from tape
     *
     110       dcw  @ifcond@
     094       dcw  000
     096       dc   00
     *
               ORG  838
     loaddd    equ  *&1          Load address
  838beginn    BCE  done,0&X1,
  846          MCW  0&X1,seqno
  853          MCW       code
  854          BCE  ifcond,code,W  if ( sense switch i )
  862          BCE  ifcond,code,K  if ( sense light i )
  870done      BSS  snapsh,C
  875          SBR  clearl&3,gmwm
  882          LCA  cont,phasid
  889          B    loadnx
  893ifcond    MCW  kless,2&X1
  900          SBR  tstles&6,2&X1
  907          LCA  0&X1,0&X3  seqno, code, gmwm
  914          SAR  x1
  918          C    0&X3
  922          SAR  x3
  926          LCA  1&X3,2&X3  replace statement code with gmwm
  933          SBR  x3
  937          MCW  0&X1,on
  944          MCW
  945          SAR  x1
  949          MZ   x2zone,on-1
  956          MZ   x2zone,off-1
  963          BWZ  *&5,seqno,2
  971          B    *&9
  975          BWZ  *&15,seqno-2,2
  983          MCW  seqno,x2
  990          MCW  0&X2,seqno
  997          B    more
     *
 1001bottom    C    0&X1
 1005          SAR  x1
 1009          SBR  x3,4&X3
 1016          B    beginn
     *
 1020more      MN   0&X1
 1024          SAR  x1
 1028          BCE  slite,code,K
     *
     * if ( sense switch i ) on, off
     *
 1036          MCW  0&X1,ch
 1043          MCW  ch,*&8
 1050          BCE  oksw,k0to6,0
 1058          B
 1059          B
 1060          B
 1061          B
 1062          B
 1063          B
 1064          CS   332
 1068          CS
 1069          SW   glober
 1073          MN   seqno,246
 1080          MN
 1081          MN
 1082          MCW  err37
 1086          W
 1087          BCV  *&5
 1092          B    *&3
 1096          CC   1
 1098          B    bottom
     *
     * Sense switch number is OK
     *
 1102oksw      A    kp1,ch
 1109          MN   ch,bin
 1116          MCW  on,bin-1
 1123          MCW  off,x2
 1130          MCW  0&X2,x2
 1137          S    kp10,x2&1
 1144          C    seqno,x2
 1151          BE   same
 1156          MCW  off,branch
 1163          LCA  branch,0&X3
 1170          LCA  bin
 1174          SBR  x3
 1178almost    C    0&X1
 1182          SAR  x1
 1186          LCA  1&X1,0&X3
 1193          SBR  x3
 1197tstles    BCE  beginn,0,<  not too big if less-than not clobbered
 1205          CS   332
 1209          CS
 1210          CC   1
 1212          MCW  error2,270
 1219          W
 1220          CC   1
 1222          BCE  halt,cdovly,1
 1230          RWD  1
 1235halt      H    halt
     *
 1239same      LCA  bin,0&X3
 1246          SBR  x3
 1250          B    almost
     *
 1254slite     MCW  0&X1,ch
 1261          MCW  ch,1275
 1268          BCE  oklite,k1234,0
 1276          B
 1277          B
 1278          B
 1279          CS   332
 1283          CS
 1284          SW   glober
 1288          MN   seqno,245
 1295          MN
 1296          MN
 1297          MCW  err36
 1301          W
 1302          BCV  *&5
 1307          B    *&3
 1311          CC   1
 1313          B    bottom
     *
 1317oklite    MCW  k080,w3
 1324          A    ch,w3
 1331          MCW  w3,bw-1
 1338          MCW  off
 1342          MCW  w3,sw
 1349          MCW  on,x2
 1356          MCW  0&X2,x2
 1363          S    kp10,x2&1
 1370          C    seqno,x2
 1377          BE   same2
 1382          MCW  on,branch
 1389          LCA  branch,0&X3
 1396          LCA  sw
 1400          LCA  bw
 1404          SBR  x3
 1408          B    almost
 1412same2     LCA  sw,0&X3
 1419          LCA  bw
 1423          SBR  x3
 1427          B    almost
     *
     * Data
     *
 1433off       DCW  #3
 1436on        DCW  #3
 1441bin       DCW  @B   &@
 1442code      DCW  #1
 1445seqno     DCW  #3
 1449branch    DCW  @B   @
 1457bw        DCW  @V      1@
 1461sw        DCW  @,   @
 1469cont      DCW  @CONTINUE@
 1470kless     DCW  @<@
 1471x2zone    DCW  @K@
 1472ch        DCW  #1
 1479k0to6     DCW  @0123456@
 1522err37     DCW  @ERROR 37 - ILLEGAL SENSE SWITCH, STATEMENT @
 1523kp1       dcw  &1
 1525kp10      DCW  &10
 1561error2    DCW  @MESSAGE 2 - OBJECT PROGRAM TOO LARGE@
 1565k1234     dcw  1234
 1607err36     DCW  @ERROR 36 - ILLEGAL SENSE LIGHT, STATEMENT @
 1610k080      DSA  80
 1613w3        DCW  #3
 1614gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
