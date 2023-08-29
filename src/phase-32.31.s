               JOB  Fortran compiler -- Input/Output One -- phase 32
               CTL  6611
     *
     * The linkage to the object format routine from the input-output
     * statements is generated in-line.
     *
     * On entry, X1 is the top of statements, and X3 is one below
     * the label table at the top of core.
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
     botfmt    equ  154  Bottom of format strings or number table - 1
     *
     110       dcw  @i/o one@
     094       dcw  000
     096       dc   00
     *
               ORG  838
     loaddd    equ  *&1          Load address
  838beginn    SW   gm
  842loop      BCE  other,0&X1,
  850          LCA  0&X1,codadr
  857          CW   flag
  861          SW   codadr-3
  865          MCW  codadr-3,*&8
  872          BCE  intrst,stmts,0
  880          chain6
     *
     * Clear from 0&x3 down to top of code & x00
     * 
  886other     SBR  x1,1&X1
  893          MZ   x3,k999x3
  900          MZ
  901          MCW
  902          MZ   x1,k999x1
  909          MZ
  910          MCW
  911          C    k999x3,k999x1
  918          BE   clrx
  923clrl      CS   0&X3
  927          SBR  clrl&3
  931          C    clrl&3,k999x1
  938          BU   clrl
  943clrx      MCW  k999x1,x2
     *
     * Clear from top of code & x00 down to top of code
     *
  950clrl2     C    x2,x1
  957          BE   clrx2
  962          LCA  kb1,0&X2
  969          CW   0&X2
  973          SAR  x2
  977          B    clrl2
     *
     * Load next overlay
     *
  981clrx2     MN   0&X1
  985          SAR  x1
  989          BSS  snapsh,C
  994          SBR  clearl&3,gmwm
 1001          LCA  arith1,phasid
 1008          B    loadnx
     *
     * Interesting statement -- one containing a format reference
     *
 1012intrst    SW   codadr-2
 1016          MCW  kless,2&X1
 1023          SBR  check&6,2&X1
 1030          C    0&X1  get to top
 1034          SAR  x1      of statement body
 1038          LCA  codadr,0&X3  move up code and address
 1045          LCA  gm             and put a GMWM below it
 1049          SBR  x3
 1053          CW   2&X3         under statement code
 1057          BWZ  nofmt,codadr-1,B
 1065          BCE  rwtp,codadr-3,1    read tape
 1073          BCE  rwtp,codadr-3,3    write tape
 1081          BCE  rdprpu,codadr-3,L  read
 1089          BCE  rdprpu,codadr-3,P  print
 1097          BCE  rdprpu,codadr-3,U  punch
 1105          MCW  0&X1,format        read/write input/output tape
 1112          SAR  x1
 1116rwtp      MCW  0&X1,tapvar  tape variable or constant
 1123          SAR  x1
 1127          MCW  0&X1,iolstg  i/o list and GMWM
 1134          BCE  const,iolstg-1,}  tape number const with I/O list
 1142          BCE  const,tapvar-1,}  tape number const, no I/O list
 1150          MN   k1,tapcon
 1157          BCE  varnol,iolstg,}   tape number var, no I/O list
 1165rwtp2     MCW  0&X1,iolist
 1172          SAR  x1
 1176rwtp3     LCA  iolist,0&X3
 1183          SBR  x3
 1187          LCA  format,0&X3
 1194          SBR  x3
 1198          LCA  tapcon,0&X3
 1205          LCA  doio&3  load branch to start I/O routine
 1209          SBR  x3
 1213          BCE  gotzon,codadr-3,L  read
 1221          BCE  gotzon,codadr-3,P  print
 1229          BCE  gotzon,codadr-3,U  punch
 1237          BCE  gotzon,codadr-3,1  read tape
 1245          MZ   azone,5&X3
 1252          BCE  gotzon,codadr-3,3  write tape
 1260          MZ   bzone,5&X3
 1267          BCE  gotzon,codadr-3,5  read input tape
 1275          MZ   abzone,5&X3
 1282gotzon    BW   novar,flag
 1290          BWZ  novar,tapvar-1,2
 1298          MCW  tapvar,mn-3
 1305          MZ   kb1,mn-4  clobber integer zone tag
 1312          LCA  mn,0&X3
 1319          SBR  x3
 1323          MCW  kb3,tapvar
 1330novar     LCA  gm,0&X3
 1337          SBR  x3
 1341          C    0&X1
 1345          SAR  x1
 1349check     BCE  loop,0,<  less sign means code not clobbered yet
     *
     * Program too big
     *
 1357          CS   332
 1361          CS
 1362          CC   1
 1364          MCW  error2,270
 1371          W
 1372          CC   1
 1374          BCE  halt,cdovly,1
 1382          RWD  1
 1387halt      H    halt
     *
     * Tape number is a constant
     *
 1391const     MN   tapvar,tapcon
 1398          SW   flag
 1402          BCE  const2,tapvar-1,}
 1410          SBR  x1,2&X1
 1417          B    rwtp2
 1421const2    SBR  x1,1&X1
     *
     * Tape is variable, but there is no list
     *
 1428varnol    MCW  botfmt,iolist
 1435          B    rwtp3
     *
     * No format
     *
 1439nofmt     MZ   kb1,3&X3
 1446          MCW  4&X3,seqno
 1453          BWZ  *&5,seqno,2
 1461          B    *&9
 1465          BWZ  nofmtm,seqno-2,2
 1473          MCW  seqno,*&4
 1480          MCW  0,seqno
 1487nofmtm    CS   332
 1491          CS
 1492          SW   glober
 1496          MN   seqno,242
 1503          MN
 1504          MN
 1505          MCW  err22
 1509          W
 1510          BCV  *&5
 1515          B    *&3
 1519          CC   1
 1521          MZ   *-4,codadr-1
 1528          B    rwtp
     *
     * Read, print, punch
     *
 1532rdprpu    MCW  0&X1,format
 1539          SAR  x1
 1543          MCW  botfmt,iolist
 1550          BCE  rdprp2,0&X1,}
 1558          MCW  0&X1,iolist
 1565          SAR  x1
 1569rdprp2    MCW  rdunit,tapcon  assume read
 1576          BCE  rdprp3,codadr-3,L  read
 1584          MCW  puunit,tapcon  assume punch
 1591          BCE  rdprp3,codadr-3,U  punch
 1599          MCW  prunit,tapcon
 1606rdprp3    SW   flag
 1610          B    rwtp3
     *
     * Data
     *
 1616k999x3    DSA  999
 1619k999x1    DSA  999
 1626mn        DCW  @DXXX0?5@
 1627gm        dc   @}@
 1628doio      B    1697  entry for I/O routine
 1635iolstg    DCW  #4
 1638tapvar    DCW  #3  tape variable or constant
 1641iolist    dcw  000
 1644format    dcw  000
 1649codadr    DCW  #5  GM, statement code, address
 1656stmts     dcw  @1356LPU@  codes for statements with formats
 1665arith1    DCW  @ARITH ONE@
 1666kless     DCW  @<@
 1667k1        dcw  1
 1668azone     dcw  @S@
 1669bzone     DCW  @K@
 1670abzone    dcw  @B@
 1673kb3       DCW  #3
 1709error2    DCW  @MESSAGE 2 - OBJECT PROGRAM TOO LARGE@
 1710tapcon    DCW  #1  tape number constant
 1711kb1       DCW  #1
 1714seqno     DCW  #3
 1753err22     DCW  @ERROR 22 - UNDEFINED FORMAT, STATEMENT @
 1754rdunit    DCW  @&@  read unit
 1755puunit    DCW  @-@  punch unit
 1756prunit    DCW  @*@  print unit
 1757flag      DCW  #1
 1758gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
