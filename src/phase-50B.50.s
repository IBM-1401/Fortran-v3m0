               JOB  Fortran compiler -- Shift CFL Phase -- phase 50B
               CTL  6611
     *
     * Constants, formats and list strings are moved into their
     * object core-storage locations above array storage.  Array
     * storage-area is cleared.
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
     arysiz    equ  160  Total array size & 2
     negary    equ  163  16000 - arysiz
     arytop    equ  194  Top of arrays in object code
     snapsh    equ  333  Core dump snapshot
     topcor    equ  688  Top core address from PARAM card
     loadnx    equ  700  Load next overlay
     clearl    equ  707  CS at start of overlay loader
     tpread    equ  780  Tape read instruction in overlay loader
     loadxx    equ  793  Exit from overlay loader
     clrbot    equ  833  Bottom of core to clear in overlay loader
     *
     * Stuff from the previous phase
     *
     adr5b     equ  891
     adr5      equ  896
     conv35    equ  969  Convert address in adr5 to digits in adr5b
     toobig    equ  1092
     *
     110       dcw  @shift cfl@
     *
               ORG  1175
     loaddd    equ  *&1          Load address
 1175beginn    C    topcor,arytop
 1182          BE   done
 1187          MCW  seqtab,x1
 1194          MCW  seqtab,x2
 1201          MA   negary,x2
 1208          SBR  sx3&6,0&X3
 1215          CW   adr5-2
 1219          MCW  x2,adr5
 1226          B    conv35
 1230          MCW  adr5b,w5a
 1237          MCW  x3,adr5
 1244          B    conv35
 1248          MCW  adr5b,w5b
 1255          C    w5a,w5b
 1262          BH   toobig
 1267          MCW  seqtab,adr5
 1274          B    conv35
 1278          MCW  adr5b,w5c
 1285          MCW  arytop,adr5
 1292          B    conv35
 1296          MCW  adr5b,w5d
 1303          C    w5c,w5d
 1310          BL   nosqmv
     *
     * Move sequence number table down by the array size
     *
 1315seqmv     MA   ka001,x1
 1322          MA   ka001,x2
 1329          BW   seqmv3,0&X1
 1337          CW   0&X2
 1341          MN   0&X1,0&X2
 1348          MZ   0&X1,0&X2
 1355seqmv2    CW   0&X1
 1359          C    x1,arytop
 1366          BU   seqmv
 1371          MCW  arytop,x3
 1378          B    nosqv2
 1382seqmv3    LCA  0&X1,0&X2
 1389          B    seqmv2
     *
     * Don't move the sequence number table
     *
 1393nosqmv    MCW  seqtab,x3
 1400nosqv2    BW   *&9,1&X3
 1408          CW   flag
 1412          SW   1&X3
     *
     * Move constants and strings up
     *
 1416          MCW  topcor,x1
 1423          MCW  arytop,x2
 1430moveup    LCA  0&X1,0&X2
 1437          SBR  x2
 1441          SBR  x1
 1445          MA   arysiz,x1
 1452          C    x1,x3
 1459          BU   moveup
 1464          BW   sx3,flag
 1472          MA   negary,x3
 1479          CW   1&X3
 1483sx3       SBR  x3,0
 1490          MA   negary,83
 1497          MA   negary,tblbot
 1504          MA   negary,seqtab
 1511          MCW  topcor,x1
 1518csloop    C    x1,arytop
 1525          BE   done
 1530          MCW  kb1,0&X1
 1537          CW   0&X1
 1541          SBR  x1
 1545          B    csloop
     *
 1549done      BSS  snapsh,C
 1554          SBR  tpread&6,838
 1561          SBR  clrbot
 1565          SBR  loadxx&3,838
 1572          SBR  clearl&3,gmwm
 1579          LCA  replac,phasid
 1586          B    loadnx
     *
     * Data
     *
 1594w5a       DCW  #5
 1599w5b       DCW  #5
 1604w5c       DCW  #5
 1609w5d       DCW  #5
 1612ka001     DSA  1
 1613flag      DCW  #1
 1614kb1       DCW  #1
 1623replac    DCW  @REPLACE 1@
 1624gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
