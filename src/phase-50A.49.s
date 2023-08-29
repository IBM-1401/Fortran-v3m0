               JOB  Fortran compiler -- Resort 4 Phase -- phase 50A
               CTL  6611
     *
     * The statements are relocated to the positions they will occupy
     * at object time.  The statement number table is adjusted to
     * to show the object time locations of the statements.
     *
     * On entry X3 is at the top of the moved-down code.
     *
     x1        equ  89
     x2        equ  94
     x3        equ  99
     *
     * Stuff in the resident area
     *
     phasid    equ  110  Phase ID, for snapshot dumps
     tblbot    equ  145  One below numbers, formats, I/O lists
     seqtab    equ  148  Bottom of sequence number table - 2
     nstmts    equ  183  Number of statements, including generated stop
     snapsh    equ  333  Core dump snapshot
     loadnx    equ  700  Load next overlay
     clearl    equ  707  CS at start of overlay loader
     *
     * Stuff from the previous phase
     *
     w3        equ  859
     topc5     equ  870  topc as five digits
     adr5b     equ  891
     adr5      equ  896
     conv35    equ  969  Convert address in adr5 to digits in adr5b
     toobig    equ  1092
     *
     110       dc   4
     *
               ORG  1175
     loaddd    equ  *&1          Load address
 1175beginn    MCW  seqtab,x1
 1182          SBR  x1,1&X1
 1189          C    tblbot,x1
 1196          BE   atbot
 1201loop      SBR  x1,3&X1
 1208          MCW  0&X1,x2
 1215          BWZ  *&12,x2-1,2
 1223          MCW  0&X2,0&X1
 1230          B    tstbot
 1234          MA   w3,x2
 1241          MCW  x2,0&X1
 1248tstbot    C    x1,tblbot
 1255          BU   loop
 1260atbot     MCW  w3,x1
 1267          MA   x3,x1
 1274          MCW  x1,newx3&6
 1281          SBR  adr5,0&X3
 1288          B    conv35
 1292          MCW  adr5b,topc5
 1299          MCW  adr5b,w5
 1306          MCW  w3,adr5
 1313          B    conv35
 1317          A    adr5b,topc5
 1324          C    k16000,topc5
 1331          BL   *&8
 1336          S    k16000,topc5
 1343          MCW  seqtab,adr5
 1350          B    conv35
 1354          C    adr5b,topc5
 1361          BH   toobig
 1366          MZ   x1,tstzon&7
 1373          MCW  x1-2,tstchr&7
 1380          MCW  nstmts,x2
 1387          MA   w3,nstmts
 1394          C    topc5,w5
 1401          BH   findw2
 1406more      LCA  0&X3,0&X1
 1413          SAR  x3
 1417          C    0&X1
 1421          SAR  x1
 1425          BCE  *&5,0&X3,:  At top of moved-up code
 1433          B    more
     *
     * Done
     *
 1437csloop    CS   0&X1
 1441          SBR  x1
 1445          C    x1,botclr  At the bottom of core to clear?
 1452          BU   csloop     no, clear more
 1457          CW   0&X1
 1461          CW
 1462          CW
 1463newx3     SBR  x3,0
 1470          SW   0&X1,1&X3
 1477          MCW  w3,x2
 1484          BSS  snapsh,D
 1489          SBR  clearl&3,gmwm
 1496          LCA  shift,phasid
 1503          B    loadnx
     *
     * Move the code to its final place
     *
 1507findwm    A    kp1,x2
 1514findw2    BW   *&5,1&X2
 1522          B    findwm
 1526          MCW  x2,x1
 1533          MA   w3,x1
 1540          LCA  0&X2,0&X1  move one field to its final place
 1547          C    x2,x3
 1554          BU   findwm
 1559          LCA  kb2,2&X3
 1566          CW   1&X3
 1570tstzon    BWZ  tstchr,x3,2  clear moved-away code
 1578          CS   0&X3
 1582          SBR  x3
 1586          B    tstzon
 1590tstchr    BCE  clr00f,x3-2,0
 1598          CS   0&X3
 1602          SBR  x3
 1606          B    tstchr
 1610clr00f    C    x3,x1
 1617          BE   clrfin
 1622          LCA  kb1,0&X3
 1629          CW   0&X3
 1633          SBR  x3
 1637          B    clr00f
 1641clrfin    MCW  nstmts,x1
 1648          MA   k15999,x1
 1655          B    csloop
     *
     * Data
     *
 1663k16000    DCW  16000
 1668w5        DCW  #5
 1671botclr    DSA  downto  test for bottom of clearing
 1680shift     DCW  @SHIFT CFL@
 1681kp1       dcw  &1
 1683kb2       DCW  #2
 1684kb1       DCW  #1
 1687k15999    DSA  15999
 1688gmwm      DCW  @}@
               org  *&x00
     downto    equ  *
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
