               JOB  Fortran compiler -- Resort 1 Phase -- phase 47
               CTL  6611
     *
     * An area is made available for a table to assist in resorting
     * the statements into their original order.
     *
     x1        equ  89
     x2        equ  94
     x3        equ  99
     *
     * Stuff in the resident area
     *
     phasid    equ  110  Phase ID, for snapshot dumps
     docnt     equ  151  Count of DO statements
     nstmts    equ  183  Number of statements, including generated stop
     snapsh    equ  333  Core dump snapshot
     loadnx    equ  700  Load next overlay
     clearl    equ  707  CS at start of overlay loader
     cdovly    equ  769  1 if running from cards, N if from tape
     tpread    equ  780  Tape read instruction in overlay loader
     loadxx    equ  793  Exit from overlay loader
     clrbot    equ  833  Bottom of core to clear in overlay loader
     *
     sortab    equ  2499  Sort table
     *
     110       dcw  @resort 1@
     *
               ORG  838
     loaddd    equ  *&1          Load address
  838w1        DCW  0
  841topa      DCW  000  tabbot plus 3 x number of statements
  844          DCW  000
  847tabbot    DCW  000  bottom of resort table
  850          DCW  000
  853          DCW  000
  856sx3       DCW  000
  859          DCW  000
  862topc      DCW  000  tabbot plus 3 x number of statements plus 1
  865          DCW  000
  870topc5     DCW  00000  topc as five digits
  875times6    DCW  00000  docnt times 6
  880w5        DCW  00000
  883topb      DCW  000  tabbot plus 3 x number of statements plus 1
  884          DCW  0
  886zontst    DCW  99   for testing zones
  891adr5b     DCW  #5
  896adr5      DCW  #5
  898zones     DCW  @99@
  900          DCW  @Z9@
  902          DCW  @R9@
  904          DCW  @I9@
  906          DCW  @9Z@
  908          DCW  @ZZ@
  910          DCW  @RZ@
  912          DCW  @IZ@
  914          DCW  @9R@
  916          DCW  @ZR@
  918          DCW  @RR@
  920          DCW  @IR@
  922          DCW  @9I@
  924          DCW  @ZI@
  926          DCW  @RI@
  928          DCW  @II@
     *
     * Convert five-digit address in adr5 to machine form
     *
  929conv53    SBR  conv5x&3
  933          ZA   adr5-3,x1
  940          MZ   nozone,x1
  947          A    x1
  951          MZ   zones-1&X1,adr5-2
  958          MZ   zones&X1,adr5
  965conv5x    B    0-0
     *
     * Convert three-character address in adr5 to five digits in adr5b
     *
  969conv35    SBR  conv3x&3
  973          MCW  k5b,adr5b
  980          MN   adr5,adr5b
  987          MN
  988          MN
  989          MZ   adr5,zontst
  996          MZ   adr5-2,zontst-1
 1003          MCW  azones,*&11
 1010          S    adr5
 1014tstzon    C    zontst,0-0
 1021conv3x    BE   0-0
 1026          A    k1,adr5b-3
 1033          SW   tstzon&4
 1037          A    k002,tstzon&6
 1044          CW   tstzon&4
 1048          B    tstzon
     *
     * Find next higher GMWM.  Leave its address & 1 in x3.
     *
 1052findgm    SBR  findgx&3
 1056          MN   0&X3
 1060          SAR  x3
 1064more      MCM  1&X3
 1068          MN
 1069          SBR  x3
 1073          BCE  more,0&X3,|
 1081          SBR  x3,1&X3
 1088findgx    B    0-0
     *
     * Program is too big
     *
 1092toobig    CS   332
 1096          CS
 1097          CC   1
 1099          MCW  error2,270
 1106          W
 1107          CC   1
 1109          BCE  halt,cdovly,1
 1117          RWD  1
 1122halt      H    halt
     *
 1126nozone    DCW  #1
 1131k5b       DCW  #5
 1134azones    DSA  zones
 1135k1        dcw  1
 1138k002      DCW  002
 1174error2    DCW  @MESSAGE 2 - OBJECT PROGRAM TOO LARGE@
     *
 1175beginn    SBR  sx3,0&X3
 1182          SBR  x1,sortab
 1189          SBR  tabbot  Bottom of code in low core
 1193          MCW  nstmts,*&14
 1200          MZ   x1zone,*&6
 1207nsx3      SBR  x1,0    Compute
 1214          A    k1a,w1    tabbot plus
 1221          C    w1,k3       number of statements
 1228          BH   nsx3          times 3
 1233          SBR  topa,0&X1
 1240          SBR  topb,1&X1
 1247          MCW  kb,w1
 1254          BCE  *&5,docnt,
 1262          B    have
 1266          SBR  topc,1&X1
 1273          SBR  adr5
 1277          B    conv35
 1281          MCW  adr5b,topc5
 1288          B    not
 1292have      MCW  docnt,times6
 1299          A    times6
 1303          A    times6
 1307          A    docnt
 1311          A    docnt,times6
 1318          SBR  adr5,1&X1
 1325          B    conv35
 1329          MCW  adr5b,topc5
 1336          A    times6,topc5
 1343          MCW  topc5,adr5
 1350          B    conv53
 1354          MCW  adr5,topc
 1361not       MCW  sx3,adr5
 1368          B    conv35
 1372          MCW  adr5b,w5
 1379          C    topc5,w5
 1386          BH   *&5
 1391          B    toobig
 1395          CC   1
 1397          CS   332
 1401          CS
 1402          MCW  strtng,243
 1409          W
 1410          CC   K
 1412          CS   332
 1416          CS
 1417          MCW  seq,208
 1424          MCW  strta,242
 1431          MCW  displa,256
 1438          W
 1439          CC   J
 1441          CS   332
 1445          CS
 1446          LCA  k000,208
 1453          MCW  sx3,x1
 1460          SBR  x1,2&X1
 1467          SBR  x3
 1471          B    findgm
 1475          MCW  x3,x2
 1482          BSS  snapsh,C
 1487          SBR  tpread&6,1175
 1494          SBR  clrbot
 1498          SBR  loadxx&3,1175
 1505          SBR  clearl&3,gmwm
 1512          LCA  resort,phasid
 1519          B    loadnx
     *
     * Data
     *
 1523x1zone    DCW  @Z@
 1524k1a       dcw  1
 1525k3        dcw  3
 1526kb        DCW  #1
 1556strtng    DCW  @STARTING ADDRESS OF STATEMENTS@
 1559seq       DCW  @SEQ@
 1575strta     DCW  @STARTING ADDRESS@
 1582displa    DCW  @DISPLAY@
 1585k000      dcw  000
 1593resort    DCW  @RESORT 2@
 1594gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
