               JOB  Fortran compiler -- Resort 2 Phase -- phase 48
               CTL  6611
     *
     * The resort table is filled with the current location
     * of each statement.
     *
     * On entry, x1 and x2 are the bottom of the prefix of the
     * bottommost statement in high core, and x3 is the bottom
     * of the bottommost statement in high core.
     *
     x1        equ  89
     x2        equ  94
     x3        equ  99
     *
     * Stuff in the resident area
     *
     phasid    equ  110  Phase ID, for snapshot dumps
     seqtab    equ  148  Bottom of sequence number table - 2
     nstmts    equ  183  Number of statements, including generated stop
     *                 Beginning of generated code on exit.
     snapsh    equ  333  Core dump snapshot
     loadnx    equ  700  Load next overlay
     clearl    equ  707  CS at start of overlay loader
     *
     * Stuff from the previous phase
     *
     sx3       equ  844
     tabbot    equ  847  bottom of resort table
     sx2       equ  853
     w3        equ  859
     topc      equ  862  tabbot plus 3 x number of statements plus 1
     seqno     equ  865  sequence number of statement being processed
     topc5     equ  870  topc as five digits
     times6    equ  875  docnt times 6
     topb      equ  883  tabbot plus 3 x number of statements plus 1
     flag      equ  884
     adr5b     equ  891
     adr5      equ  896
     conv53    equ  929  convert five digits in adr5 to address
     conv35    equ  969  Convert address in adr5 to digits in adr5b
     findgm    equ  1052  find next higher GM
     *
     sortab    equ  2499  Sort table
     *
     110       dc   2
     *
               ORG  1175
     loaddd    equ  *&1          Load address
 1175beginn    MCW  topb,x3
 1182          B    first
 1186loop      SBR  x2,2&X2
 1193          MZ   x3,sx3
 1200          MCW  x2,x3
 1207          B    findgm
 1211          MCW  x3,x2
 1218          MCW  sx3,x3
 1225first     SBR  sx2,2&X2
 1232          BWZ  *&5,0&X2,2
 1240          B    *&9
 1244          BWZ  *&19,2&X2,2
 1252          MCW  2&X2,x2
 1259          MCW  0&X2,x2  get sequence number from table to x2
 1266          B    *&8
 1270          MCW  2&X2,x2  get sequence number to x2
 1277          SBR  seqno,0&X2
 1284          SBR  *&14
 1288          MZ   x2zone,*&6
 1295          SBR  x2,0
 1302          MCW  seqno,*&14
 1309          MZ   x2zone,*&6
 1316          SBR  x2,0     double sequence number the hard way???
 1323          C    sortab&X2,kb3  sort table entry emtpy?
 1330          BU   *&12     no
 1335          MCW  x1,sortab&X2
 1342          B    linked
 1346          SW   3&X3     link another statement
 1350          MCW  sortab&X2,5&X3  of the same sequence number
 1357          CW   3&X3              to the table.  this can
 1361          MCW  x1,2&X3             happen with
 1368          MCW  k1,flag               do statements
 1375          SBR  sortab&X2,2&X3
 1382          MZ   x1zone,sortab-1&X2  mark first as linked
 1389          SBR  x3,6&X3
 1396linked    MCW  sx2,x2
 1403          C    seqtab,sx2
 1410          BU   what
 1415          BCE  one,flag,0
 1423          MCW  k0,flag
 1430          MCW  x1,x3
 1437          B    findgm
 1441          MZ   x1zone,1&X3
 1448one       MCW  topc,x2
 1455          LCA  colon,0&X2
 1462          MCW  tabbot,x3
 1469          SBR  x3,3&X3
 1476          MCW  86,adr5
 1483          B    conv35
 1487          MCW  adr5b,topc5
 1494          SBR  adr5,0&X2
 1501          B    conv35
 1505          MCW  adr5b,times6
 1512          S    times6,topc5
 1519          BM   *&5,topc5
 1527          B    *&8
 1531          A    k16k,topc5
 1538          MCW  topc5,adr5
 1545          B    conv53
 1549          MCW  adr5,w3
 1556          SBR  x2,1&X2
 1563          SBR  nstmts
 1567          BSS  snapsh,C
 1572          SBR  clearl&3,gmwm
 1579          LCA  resort,phasid
 1586          B    loadnx
     *
 1590what      MCW  x3,sx3
 1597          MCW  x1,x3
 1604          B    findgm  get up to next statement
 1608          MCW  x3,x1
 1615          MCW  sx3,x3
 1622          BCE  oneb,flag,0
 1630          MCW  k0,flag
 1637          MZ   x1zone,1&X1
 1644oneb      SBR  x1,4&X1
 1651          B    loop
     *
     * Data
     *
 1655x2zone    DCW  @R@
 1658kb3       DCW  #3
 1659k1        dcw  1
 1660x1zone    dcw  @Z@
 1661k0        DCW  0
 1662colon     DCW  @:@
 1667k16k      DCW  16000
 1675resort    DCW  @RESORT 3@
 1676gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
