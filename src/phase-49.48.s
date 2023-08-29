               JOB  Fortran compiler -- Resort 3 Phase -- phase 49
               CTL  6611
     *
     * The source program is resorted back to its original order.
     * The statement number table is filled with the current location
     * of each statement.
     *
     * On entry X3 is at the bottom entry in  the sort table and
     * X2 is one above the colon that marks the top of the sort table.
     *
     x1        equ  89
     x2        equ  94
     x3        equ  99
     *
     * Stuff in the resident area
     *
     phasid    equ  110  Phase ID, for snapshot dumps
     seqtab    equ  148  Bottom of sequence number table - 2
     snapsh    equ  333  Core dump snapshot
     topcor    equ  688  Top core address from PARAM card
     loadnx    equ  700  Load next overlay
     clearl    equ  707  CS at start of overlay loader
     *
     * Stuff from the previous phase
     *
     topa      equ  841  tabbot plus 3 x number of statements
     sx1       equ  844  sx3a in previous phase
     next      equ  850  next sort table entry to process
     sx3a      equ  853  sx2 in previous phase
     sx3       equ  856
     w3        equ  859
     topc      equ  862  tabbot plus 3 x number of statements plus 1
     seqno     equ  865  sequence number of statement being processed
     topc5     equ  870  topc as five digits
     times6    equ  875  docnt times 6
     w5        equ  880
     flag      equ  884
     adr5b     equ  891
     adr5      equ  896
     conv35    equ  969  Convert address in adr5 to digits in adr5b
     findgm    equ  1052  find next higher GM
     toobig    equ  1092
     *
     sortab    equ  2499  Sort table
     *
     110       dc   3
     *
               ORG  1175
     loaddd    equ  *&1          Load address
 1175beginn    SW   gm
 1179          B    *&8
 1183loop      SBR  x3,0-0
 1190          SBR  next
 1194middle    BCE  empty,0&X3,
 1202          SBR  loop&6,3&X3
 1209          MN   0&X3
 1213          SAR  *&7
 1217          BWZ  indir,0-0,S
 1225          MCW  0&X3,x1
 1232indirb    SBR  topc,0&X3
 1239inner     MCW  x1,sx1a
 1246          MCW  x1,x3
 1253          B    findgm  get address & 1 of GM above statement
 1257          MCW  x3,adr5
 1264          B    conv35
 1268          MCW  adr5b,w5   Address &1 of GM above statement
 1275          A    k1,w5
 1282          MCW  sx1a,adr5  Address of statement
 1289          B    conv35
 1293          MCW  adr5b,w5b
 1300          S    w5b,w5     length of statement
 1307          MCW  x2,adr5
 1314          B    conv35
 1318          MCW  adr5b,topc5  top of table & 2
 1325          B    test
 1329          BL   moved1
 1334newstm    MCW  sx1a,x1
 1341          BCE  *&12,f1,1
 1349          A    k1,208
 1356          B    report
     *
 1360          MCW  k0,f1
 1367          MCW  x3,sx3b&6
 1374          MCW  3&X1,x3
 1381          MCW  0&X3,x3
 1388          SBR  3&X1,4&X3
 1395          MA   w3,3&X1
 1402          MCW  x1,sx1b
 1409dezone    MZ   *-4,9&X3
 1416          MZ   *-4,12&X3
 1423          MZ   *-4,15&X3
 1430          MZ   *-4,18&X3
 1437          BCE  dezonx,22&X3,
 1445          MCW  22&X3,x1
 1452          MCW  0&X1,22&X3
 1459          MA   k004,22&X3
 1466          MA   w3,22&X3
 1473          MCW  0&X1,x3
 1480          B    dezone 
 1484dezonx    SBR  22&X3,4&X2
 1491          MA   w3,22&X3
 1498          MCW  sx1b,x1
 1505          BCE  *&8,0&X1,B
 1513          SBR  3&X1,918  ???
 1520sx3b      SBR  x3,0-0
 1527report    MCW  w3,227
 1534          MA   x2,227
 1541          MCW  227,x3
 1548          MCW  x3,adr5
 1555          B    conv35  convert adr5 to adr5b
 1559          MCS  adr5b,244
 1566          MCW  x3,256
 1573          MA   k004,256
 1580          W
 1581          BCV  *&5
 1586          B    *&3
 1590          CC   1
 1592          MCW  x2,link2&6
 1599          BCE  endstm,0&X1,}  gm
 1607          MN   0&X2
 1611          SAR  x2
 1615more      MCM  0&X1
 1619          SAR  newx1&6
 1623          MCM  0&X1,1&X2  move code down
 1630          MN
 1631          SBR  x2
 1635newx1     SBR  x1,0-0
 1642          BCE  more,0&X2,|
 1650          BWZ  *&5,0&X1,2
 1658          B    link1
 1662          BWZ  mark,2&X1,2
 1670          B    link1
 1674endstm    SBR  x1,1&X1
 1681          MCW  branch,switch
 1688link1     MCW  2&X1,x3   prefix is addr of statement number
 1695link2     SBR  0&X3,0-0  start of statement to stmt num tbl
 1702mark      MCW  colon,0&X1
 1709switch    NOP  endst2
 1713          MN   0&X1
 1717          MN
 1718          SAR  x1
 1722          MN   0&X2
 1726          SAR  *&7
 1730setwms    LCA  0&X1,0&X2  set word marks in moved-down code
 1737          SBR  *-4
 1741          C    0&X1
 1745          SAR  x1
 1749          BCE  *&5,0&X1,}  gm
 1757          B    setwms
     *
 1761endst2    MCW  nop,switch
 1768          C    next,topa
 1775          BU   contin
     *
 1780done      LCA  colon,0&X2
 1787          SBR  x3
 1791          BSS  snapsh,C
 1796          SBR  clearl&3,gmwm
 1803          LCA  resort,phasid
 1810          B    loadnx
     *
 1814contin    BCE  indir2,flag,1
 1822          B    loop
     *
     * Sort table entry is the address of another one
     *
 1826indir     MCW  0&X3,x3
 1833          MCW  0&X3,x1
 1840          SBR  newx3&3,3&X3
 1847          MCW  k1,flag
 1854          B    indirb
     *
 1858indir2    MCW  k0,flag
 1865newx3     MCW  0-0,x1
 1872          MCW  newx3&3,topc
 1879          MCW  k1,f1
 1886          B    inner
     *
 1890test      SBR  testx&3
 1894          MCW  sx3,adr5
 1901          B    conv35  convert adr5 to adr5b
 1905          MCW  adr5b,times6
 1912          S    topc5,times6
 1919          C    w5,times6
 1926testx     B    0-0
     *
     * Empty cell in sort table
     *
 1930empty     A    k1,208
 1937          C    next,topa
 1944          BE   done
 1949          SBR  x3,3&X3
 1956          SBR  next
 1960          B    middle
     *
 1964moved     SBR  sx3,2&X3
 1971moved1    MCW  sx3,x3
 1978          SBR  x3,2&X3
 1985          B    findgm
 1989          BCE  moved,0&X3,:  colon means statement already moved
 1997          B    test
 2001          BL   *&5
 2006          B    newstm
     *
 2010          SBR  sx2a&6,0&X2
 2017tsttop    C    x3,topcor
 2024          BE   attop
 2029          SBR  x1,3&X3
 2036          BCE  nextab,0&X1,}  gm
 2044attop     B    test
 2048          BL   toobig
 2053          B    sx2a
 2057nextab    SBR  x3,4&X3
 2064nextb1    B    findgm
 2068          C    0&X3,colon
 2075          BU   tsttop
 2080          SBR  nextx1&6,0&X3
 2087          SBR  sx3a,2&X3
 2094          SBR  x3,3&X3
 2101loop2     LCA  0&X1,0&X3
 2108          SAR  x1
 2112          C    0&X3
 2116          SAR  x3
 2120          BCE  *&5,0&X1,}  gm
 2128          B    loop2
 2132          MN   0&X1
 2136          SAR  sx1
 2140nextx1    SBR  x1,0-0
 2147          BWZ  *&5,1&X1,S
 2155          B    *&8
 2159          MCW  k1,f2
 2166          BWZ  *&5,0&X1,2
 2174          B    *&9
 2178          BWZ  *&19,2&X1,2
 2186          MCW  2&X1,x1
 2193          MCW  0&X1,x2
 2200          B    *&8
 2204          MCW  2&X1,x2
 2211          SBR  seqno,0&X2
 2218          SBR  *&14
 2222          MZ   x2zone,*&6
 2229          SBR  x2,0-0
 2236          MCW  seqno,*&14
 2243          MZ   x2zone,*&6
 2250          SBR  x2,0-0
 2257          BWZ  *&12,sortab-1&X2,S
 2265          SBR  sortab&X2,1&X3
 2272          B    skip2
 2276          MCW  sortab&X2,x1
 2283          BCE  *&12,f2,1
 2291          SBR  3&X1,1&X3
 2298          B    *&15
 2302          SBR  0&X1,1&X3
 2309          MCW  k0,f2
 2316skip2     C    sx1,sx3
 2323          BE   loop2x
 2328          MCW  sx1,x1
 2335          MN   0&X3
 2339          MN
 2340          MN
 2341          SAR  nextx1&6
 2345          SBR  x1,1&X1
 2352          B    loop2
 2356loop2x    LCA  gm,0&X3
 2363          SBR  sx3
 2367          C    seqtab,sx3a
 2374          BE   atbot
 2379          MCW  sx3a,x3
 2386          SBR  x1,1&X3
 2393          SBR  x3,2&X3
 2400          B    nextb1
     *
     * At bottom of sort table
     *
 2404atbot     B    test
 2408          BL   toobig
 2413sx2a      SBR  x2,0-0
 2420          MCW  topc,x3
 2427          MCW  0&X3,sx1a
 2434          B    newstm
     *
     * Data
     *
 2442w5b       DCW  00000
 2443f1        DCW  0
 2444f2        DCW  0
 2447sx1a      DCW  #3
 2448k1        dcw  1
 2449k0        DCW  0
 2452sx1b      DCW  #3
 2455k004      DSA  4
 2456branch    B
 2457colon     DCW  @:@
 2458nop       NOP
 2466resort    DCW  @RESORT 4@
 2467x2zone    DCW  @R@
 2468gm        dc   @}@
 2469gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
