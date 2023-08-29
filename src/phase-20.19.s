               JOB  Fortran compiler -- Constants Phase Three -- 20
               CTL  6611
     *
     * Constants are placed in their object-time locations at the
     * lower end of storage.  The object-time addresses replace
     * the constants wherever they appear.
     *
     * On entry, x1 and topcod are the top of the prefix of the top
     * statement, and 81-83 is the next available place in the
     * number table.
     *
     * On exit, x1 is the top of the prefix of the top statement
     * and 81-83 is the bottom of the number table.
     *
     x1        equ  89
     x2        equ  94
     x3        equ  99
     *
     * Stuff in the resident area
     *
     phasid    equ  110  Phase ID, for snapshot dumps
     negar2    equ  142  Looks like negary -- see phase 20
     negar3    equ  157  Looks like negary -- see phase 20
     arysiz    equ  160  Total array size & 2
     negary    equ  163  16000 - arysiz
     arytop    equ  194  Top of arrays in object code
     snapsh    equ  333  Core dump snapshot
     topcor    equ  688  Top core address from PARAM card
     loadnx    equ  700  Load next overlay
     clearl    equ  707  CS at start of overlay loader
     cdovly    equ  769  Read (1) instruction if running from cards
     tpread    equ  780  Tape read instruction in overlay loader
     loadxx    equ  793  Exit from overlay loader
     clrbot    equ  833  Bottom of core to clear in overlay loader
     topcod    equ  840  top of code & x00 - 1
     diff      equ  845  top of core - topcod as five digits
     bndry     equ  848
     *
     110       dcw  @const tri@
     *
               ORG  849
     loaddd    equ  *&1          Load address
     *
     * Convert topcor to decimal
     *
  849beginn    S    w2h
  853          S    w2l
  857          MZ   topcor,w2h-1
  864          MZ   topcor-2,w2l-1
  871          BWZ  *&12,w2l-1,2
  879          A    ka0,w2l
  886          B    *-18
  890          BWZ  *&12,w2h-1,2
  898          A    kq4,w2h
  905          B    *-18
  909          A    w2l-1,w2h
  916          MCW  topcor,aryszw
  923          MCW  w2h
  927          ZA   aryszw
  931          MZ   *-4,aryszw
  938          MCW  x2,sx2
  945          S    w2h2
  949          S    w2l2
     *
     * Convert arytop to decimal
     *
  953          MZ   arytop,w2h2-1
  960          MZ   arytop-2,w2l2-1
  967          BWZ  *&12,w2l2-1,2
  975          A    ka0,w2l2
  982          B    *-18
  986          BWZ  *&12,w2h2-1,2
  994          A    kq4,w2h2
 1001          B    *-18
 1005          A    w2l2-1,w2h2
 1012          MCW  arytop,w5
 1019          MCW  w2h2
 1023          ZA   w5
 1027          MZ   *-4,w5
     *
     * Convert w5-aryszw, whiich is array sizes & 2,  to machine
     * address
     *
 1034          S    w5,aryszw
 1041          C    kp0,aryszw
 1048          BE   noarys
 1053          MN   aryszw,arysiz
 1060          MN
 1061          MN
 1062          SAR  *&4
 1066          MCW  0,x2  why not just MCW  ARYSZW-3,X2 ?
 1073          MCW  k0
 1077          A    x2
 1081          MZ   zones&X2,arysiz
 1088          CW
 1089          SBR  *&7
 1093          MZ   zones-1&X2,0  why not MZ   ZONES-1&X2,ARYSIZ-2 ?
 1100          MCW  k16k,w5b
 1107          S    aryszw,w5b
 1114          MN   w5b,negary
 1121          MN
 1122          MN
 1123          SAR  *&4
 1127          MCW  0,x2  why not MCW  w5b-3,x2 ?
 1134          MCW  k0
 1138          A    x2
 1142          MZ   zones&X2,negary
 1149          CW
 1150          SBR  *&7
 1154          MZ   zones-1&X2,0  why not MZ   ZONES-1&X2,negary-2 ?
 1161noarys    MCW  sx2,x2
 1168          MA   negary,negar2
 1175          MA   negary,negar3
 1182          MCW  topcod,savtop&3
 1189          MZ   s,savtop&2  X2 zone
 1196          MCW  x2,sx2b
 1203          MCW  kb1,2599
 1210loop      BCE  bottom,0&X1,
 1218          MCW  0&X1,seqcod
 1225          LCA  0&X1,prefix
 1232          SAR  x1
 1236          SBR  x3
 1240          LCA  prefix,0&X2
 1247          SBR  x2
 1251          BCE  endstm,seqcod-3,/  End statement?
 1259schund    BCE  gotun6,0&X1,_
 1267          chain5
 1272          BCE  endstm,0&X1,}
 1280          chain5
 1285          SBR  x1
 1289          B    schund
     *
     * Got X1 to within six of underscore.  Get to it exactly.
     *
 1293gotun6    BCE  gotund,0&X1,_
 1301          SBR  x1
 1305          B    gotun6
     *
     * Got X1 to the underscore above a number
     *
 1309gotund    SW   1&X1
 1313          CW
 1314          CW
 1315          CW
 1316          SAR  x1
 1320          BCE  gotgm,4&X1,}  Can this happen?
 1328          LCA  0&X3,0&X2  Move up everything above number.
 1335          SBR  x2
 1339          CW   1&X2
 1343gotgm     SBR  x3,2&X1
     *
     * Get X1 down to a punctuation mark below the number
     *
 1350schpun    MCW  0&X1,w1
 1357          SAR  x1
 1361          MCW  w1,*&8
 1368          BCE  gotpun,punct,0
 1376          chain8
 1384          B    schpun
 1388gotpun    SW   2&X1  at the bottom of the number
 1392          ZA   0&X3,hash
 1399          A    4&X1,hash
 1406          BCE  blank,2&X1,
 1414bback     MZ   kb4,hash
 1421          MZ
 1422          MZ
 1423          MCW
 1424          S    diff-1,hash  Compute
 1431          BWZ  *-14,hash,B    mod
 1439          A    diff-1,hash      (diff-1,hash)
 1446          MZ   kb1,hash
 1453          MCW  x2,sx2c
 1460          MCW
 1461          MCW  hash,x1
 1468          A    x1
 1472          A    hash,x1
 1479savtop    NOP  0
 1483          SAR  x1
 1487          MCW  nop,bothsh
 1494hloop     BCE  notfnd,0&X1,  Not found if hash entry blank
 1502          BCE  bothsh,0&X1,<
 1510          MCW  0&X1,x2
 1517          SAR  x1
 1521          C    0&X3,0&X2
 1528          BU   hloop
 1533          C    0&X2,0&X3
 1540          BU   hloop
     *
     * Found in the hash table
     *
 1545found     MCW  x2,sx2d
 1552          MCW  sx2d,sx2e
 1559          MA   negary,sx2d
 1566          MCW  sx2c,x2
 1573          MCW
 1574          LCA  sx2d,0&X2
 1581          SBR  x2
 1585          CW   1&X2
 1589          MCW  sx2e,*&7
 1596          BWZ  fpnum,0-0,2
 1604          MZ   kb1,2&X2  Set integer zone
 1611numfin    SBR  x1,1&X1
 1618          SBR  x3
 1622          B    schund
     *
     * Not found, enter it
     *
 1626notfnd    MCW  83,x2
 1633          MCW  83,0&X1
 1640          MCW  0&X3,0&X2
 1647          SBR  x1
 1651          SBR  83
 1655          BCE  toobig,0&X1,<
 1663          SW   1&X1
 1667          B    found
     *
     * Bottom of hash table
     *
 1671bothsh    NOP  toobig
 1675          MCW  s,bothsh  Should this be B instead of S?
 1682          MCW  bndry,x1
 1689          B    hloop
     *
     * Found floating-point number
     *
 1693fpnum     MZ   *-6,2&X2  set floating point zone
 1700          B    numfin
     *
     * A blank in the number
     *
 1704blank     SW   3&X1
 1708          B    bback
     *
     * Too big
     *
 1712toobig    CS   332
 1716          CS
 1717          CC   1
 1719          MCW  error2,270
 1726          W
 1727          CC   1
 1729          BCE  halt,cdovly,1
 1737          RWD  1
 1742halt      H    halt
     *
     * Got to within six of a GM without seeing underscore.
     * Move the remainder of the statement up.
     *
 1746endstm    LCA  0&X3,0&X2
 1753          SAR  x3
 1757          C    0&X2
 1761          SAR  x2
 1765          MCW  x3,x1
 1772          B    loop
     *
     * reached the bottom of statements
     *
 1776bottom    MCW  sx2b,x1
 1783          CS   332
 1787          CS
 1788          MCW  consts,223
     *
     * Convert 81-83 to decimal
     *
 1795          S    w2h3
 1799          S    w2l3
 1803          MZ   83,w2h3-1
 1810          MZ   81,w2l3-1
 1817          BWZ  *&12,w2l3-1,2
 1825          A    ka0,w2l3
 1832          B    *-18
 1836          BWZ  *&12,w2h3-1,2
 1844          A    kq4,w2h3
 1851          B    *-18
 1855          A    w2l3-1,w2h3
 1862          MCW  83,w5c
 1869          MCW  w2h3
 1873          ZA   w5c
 1877          MZ   *-4,w5c
 1884          S    aryszw,w5c
 1891          MZ   kb1,w5c
 1898          A    kp1,w5c
 1905          MCW  83,x3
 1912          MA   negary,x3
 1919          SBR  x3,1&X3
 1926          MCW  arytop,247
 1933          MCW  hyphen
 1937          MCW  x3
 1941          MCW  kb3
 1945          MCW  w5
 1949          MCW  to
 1953          MCW  w5c
 1957          CC   J
 1959          W
 1960          CC   J
 1962          BCV  *&5
 1967          B    *&3
 1971          CC   1
     *
     * Load next overlay
     *
 1973          BSS  snapsh,D
 1978          SBR  tpread&6,838
 1985          SBR  clrbot
 1989          SBR  loadxx&3,838
 1996          SBR  clearl&3,2598
 2003          LCA  subscr,phasid
 2010          B    loadnx
     *
     * Data
     *
 2015          DCW  @ 9@
     zones     equ  *&1
 2046          DCW  @9Z9R9I99ZZZRZIZ9RZRRRIR9IZIRIII@
 2048w2h       DCW  #2  High-order zones from topcor
 2050w2l       DCW  #2  Low-order zones from topcor
 2052ka0       DCW  @A0@  Used to convert machine address to decimal
 2054kq4       DCW  @?4@  Used to convert machine address to decimal
 2057sx2       DCW  #3
 2059w2h2      DCW  #2
 2061w2l2      DCW  #2
 2066w5        DCW  #5
 2071aryszw    DCW  #5  array size & 2
 2076kp0       DCW  @0000?@
 2077k0        DCW  @0@
 2082k16k      DCW  @16000@
 2087w5b       DCW  #5
 2088s         dcw  @S@
 2091sx2b      DCW  #3
 2092kb1       DCW  #1
 2096seqcod    DCW  #4  Statement code and sequence number
 2106prefix    DCW  #10  Entire statement prefix
 2107w1        DCW  #1
 2116punct     DCW  @#}@*-&)$,@
 2120hash      DCW  #4
 2124kb4       DCW  #4
 2132sx2c      DCW  #8
 2133nop       NOP
 2136sx2d      DCW  #3
 2139sx2e      DCW  #3
 2175error2    DCW  @MESSAGE 2 - OBJECT PROGRAM TOO LARGE@
 2198consts    DCW  @CONSTANTS LOCATED FROM @
 2200w2h3      DCW  #2
 2202w2l3      DCW  #2
 2203kp1       dcw  &1
 2208w5c       DCW  #5
 2209hyphen    DCW  @-@
 2212kb3       DCW  #3
 2216to        DCW  @ TO @
 2222subscr    DCW  @SUBSCR@
 2223gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
