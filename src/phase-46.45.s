               JOB  Fortran compiler -- DO Phase -- phase 46
               CTL  6611
     *
     * Strings of unconditional BRANCH instructions and parameters
     * are generated in-line.  An unconditional BRANCH is generated
     * to follow the last statement within the range of the DO
     *
     x1        equ  89
     x2        equ  94
     x3        equ  99
     *
     * Stuff in the resident area
     *
     phasid    equ  110  Phase ID, for snapshot dumps
     negar2    equ  142  Looks like negary -- see phase 20
     docnt     equ  151  Count of DO statements
     glober    equ  184  Global error flag -- WM means error
     snapsh    equ  333  Core dump snapshot
     loadnx    equ  700  Load next overlay
     clearl    equ  707  CS at start of overlay loader
     cdovly    equ  769  1 if running from cards, N if from tape
     loadxx    equ  793  Exit from overlay loader
     *
     110       dcw  @domsk@
     094       dcw  000
     096       dc   00
     *
               ORG  838
     loaddd    equ  *&1          Load address
  838beginn    SW   gm,gm3
  845          SW   gm4,gm2
  852          MCW  x3,sx3
  859loop      BW   done,0&X1
  867          MCW  kless,2&X1  mark top of code -- bottom of free
  874          SBR  tstles&6,2&X1
  881          C    0&X1
  885          SAR  x1
  889          C    2&X1,kd  Do statement?
  896          BU   almost   no
  901          CW   111,112
  908          CW   113,114
  915          MCW  5&X1,x2  address of sequence number
  922          MCW  0&X2,seqno
  929          MCW  0&X1,x2
  936          SAR  x1
  940          MCW  0&X2,seqend
  947          ZA   seqno,seqdif
  954          S    seqend,seqdif
  961          MCW  nop,swich1
  968          BWZ  msg38,seqdif,B  illegal range if positive
  976          MCW  x1,x2
  983          MCW  kb3,f5
  990          MCW  kt,longop
  997          MCW  branch,swich2
 1004nested    C    0&X2  down to body of stmt below DO
 1008          C
 1009          SAR  x2
 1013          C    2&X2,kd  Is it a DO statement?
 1020          BU   notdo
 1025          MCW  0&X2,x3
 1032          C    0&X3,seqno  properly nested?
 1039          BH   nested      yes
 1044          C    0&X3,seqend
 1051          BH   msg39  illegal DO nesting
 1056          BCE  *&8,1&X2,H  co-ending?
 1064          MCW  ke,1&X2  not co-ending
 1071          BL   notdo
 1076          MCW  kh,1&X2  co-ending after all
 1083          MCW  5&X2,f5
 1090notdo     BCE  coend,4&X1,H
 1098          MCW  nop,swich2
 1105          BCE  *&8,4&X1,}
 1113          MCW  branch,longop
 1120coend     MCW  seqend,long
 1127          SW   6&X1
 1131          MCW  8&X1,short
 1138          MCW  8&X1,f6
     *
     * Test syntax and generate code
     *
 1145gen       B    sub
 1149          dcw  @,@
 1152          DSA  f4
 1153          B    sub
 1157          dcw  @#@
 1160          DSA  f1
 1161          B    sub
 1165          dcw  @,@
 1168          DSA  f2
 1169          BW   nrbot,0&X1
 1177          B    sub
 1181          dcw  @,@
 1184          DSA  f3
 1185          BW   bottom,0&X1
 1193          B    msg40  syntax error
     *
 1197bottom    MCW  sx3,x3
 1204          MN   0&X1
 1208          SAR  x1
 1212swich1    NOP  tstles
 1216swich2    NOP  skip
 1220          A    kp1,docnt
 1227          LCA  long,0&X3
 1234          LCA
 1235          LCA
 1236          SBR  x3
 1240skip      LCA  short,0&X3
 1247          chain8
 1255          SBR  sx3
 1259tstles    BCE  loop,0,<
 1267          CS   332
 1271          CS
 1272          CC   1
 1274          MCW  error2,270
 1281          W
 1282          CC   1
 1284          BCE  halt,cdovly,1
 1292          RWD  1
 1297halt      H    halt
     *
     * Check the next character against the one at 0&x1, then
     * check that the next three have numeric parts in 0..9,
     * that is, they constitute an address.         
     *
 1301sub       SBR  x2
 1305          C    0&X1,0&X2
 1312          SAR  x1
 1316          BU   msg40  Syntax error if not the expected char
 1321          MCW  3&X2,*&7
 1328          MCW  0&X1,0
 1335          S    w1
 1339gotdig    A    kp1,w1
 1346          BCE  4&X2,w1,D  Exit if three times through loop
 1354          MN   0&X1,*&12
 1361          SAR  x1
 1365          BCE  gotdig,digits,0
 1373          chain9
 1382          B    msg40  Special character means syntax error
     *
 1386nrbot     MCW  negar2,f3
 1393          B    bottom
     *
     * Illegal range of DO
     *
 1397msg38     CS   332
 1401          CS
 1402          SW   glober
 1406          MN   seqno,245
 1413          MN
 1414          MN
 1415          MCW  err38
 1419          W
 1420          BCV  *&5
 1425          B    *&3
 1429          CC   1
 1431set1      MCW  branch,swich1
 1438          B    gen
     *
     * Illegal nesting
     *
 1442msg39     CS   332
 1446          CS
 1447          SW   glober
 1451          MN   seqno,241
 1458          MN
 1459          MN
 1460          MCW  err39
 1464          W
 1465          BCV  *&5
 1470          B    *&3
 1474          CC   1
 1476          B    set1
     *
     * Syntax error
     *
 1480msg40     CS   332
 1484          CS
 1485          SW   glober
 1489          MN   seqno,235
 1496          MN
 1497          MN
 1498          MCW  err40
 1502          W
 1503          BCV  *&5
 1508          B    *&3
 1512          CC   1
 1514          C    1&X1
 1518          SAR  x1
 1522          B    tstles
     *
 1526almost    SBR  x1,5&X1
 1533done      MCW  sx3,x3
 1540          MN   0&X3
 1544          SAR  x2
 1548csloop    CS   0&X2
 1552          SBR  x2
 1556          C    0&X2,1899  Should this be @1899@???
 1563          BU   csloop
 1568          BSS  snapsh,E
 1573          SBR  loadxx&3,1175
 1580          SBR  clearl&3,2499
 1587          LCA  resort,phasid
 1594          B    loadnx
 1598gm        DC   @}@
     *
     * Generated code template
     *
 1602          DCW  @T924@
 1606          DCW  @T921@
 1609f1        DCW  #3
 1612f2        DCW  #3
 1615f3        DCW  #3
 1618f4        DCW  #3
 1621f5        DCW  #3
 1622gm2       dc   @}@
 1625short     dc   #3
 1626gm3       dc   @}@
 1627longop    DCW  @T@
 1630f6        DC   #3
 1631gm4       dc   @}@
 1634long      dc   #3
     *
     * Data
     *
 1637sx3       DCW  #3
 1638kless     DCW  @<@
 1639kd        DCW  @D@
 1642seqno     DCW  #3  sequence number of do
 1645seqend    DCW  #3  sequence number of final statement of do
 1648seqdif    DCW  #3  seqno - seqend -- better be negative
 1649nop       NOP
 1652kb3       DCW  #3
 1653kt        DCW  @T@
 1654branch    B
 1655ke        DCW  @E@
 1656kh        DCW  @H@
 1657kp1       dcw  &1
 1693error2    DCW  @MESSAGE 2 - OBJECT PROGRAM TOO LARGE@
 1694w1        DCW  #1
 1704digits    DCW  @0123456789@
 1746err38     DCW  @ERROR 38 - ILLEGAL RANGE OF DO, STATEMENT @
 1784err39     DCW  @ERROR 39 - ILLEGAL NESTING, STATEMENT @
 1816err40     DCW  @ERROR 40 - DO SYNTAX, STATEMENT @
 1824resort    DCW  @RESORT 1@
 1825          DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
