               JOB  Fortran compiler -- Statement Numbers Phase -- 22
               CTL  6611
     *
     * All statement numbers that appear in the program are reduced
     * to a unique three-character representation.  Statement numbers
     * within the statement are moved to the beginning of each source-
     * program statement (rightmost end of statement in storage) that
     * contains those elements.
     *
     * On entry, x1 is the top of the prefix of the top statement,
     * x2 is one below the bottom statement, and 81-83 is one below
     * the bottom of the number table.
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
     loadxx    equ  793  Exit from overlay loader
     *
     110       dcw  @stnum one@
     099       dcw  000
     100       dc   0
     *
               ORG  838
     loaddd    equ  *&1          Load address
  838beginn    CS   0&X2   Clear below bottom of statements
  842          MCW  83,x2  Below number table
  849          SW   gm
  853          LCA  gm,0&X2
  860          SBR  x2
  864loop      BCE  done,0&X1,
  872          LCA  0&X1,prefix
  879          SAR  x1
  883          CW   1&X1
  887          SW   prefix-3
  891          LCA  prefix,0&X2  Move up only seq number and code
  898          SBR  x2
  902          CW   1&X2
  906          BWZ  lbldef,prefix-4,2
  914nolabl    LCA  gm,0&X2
  921          SBR  x2
  925          MCW  prefix-3,*&8
  932          BCE  lblref,stmts,0  Does statement have label refs?
  940          chain10
  950          BCE  endstm,prefix-3,/
  958moveup    LCA  0&X1,0&X2  Move (rest of) statement up
  965          SAR  x1
  969          C    0&X2
  973          SAR  x2
  977          B    loop
     *
     * END statement
     *
  981endstm    C    0&X1
  985          SAR  x1
  989          MCM  4&X2
  993          MN
  994          MN
  995          SAR  x2
  999          B    loop
     *
     * Got a statement label definition
     *
 1003lbldef    LCA  prefix-4,label
 1010          SBR  x3
 1014          SW   2&X3
 1018          B    conv50
 1022          B    nolabl
     *
     * Statement is one that contains label references
     *
 1026lblref    BCE  if,prefix-3,E    IF statement
 1034          BCE  do,prefix-3,D    DO statement
 1042          BCE  tape,prefix-3,5  READ INPUT TAPE statement
 1050          BCE  tape,prefix-3,6  WRITE OUTPUT TAPE statement
 1058          BCE  cgo,prefix-3,T   Computed GO TO statement
 1066          BCE  ifss,prefix-3,W  IF ( SENSE SWITCH ... )
 1074          BCE  ifss,prefix-3,K  IF ( SENSE LIGHT ... )
 1082          B    savlab  PUNCH, PRINT, READ, GOTO
 1086          B    moveup
     *
     * Computed GO TO statement
     *
 1090cgo       B    savlab
 1094          BCE  cgofin,0&X1,)
 1102          BCE  syntax,0&X1,}
 1110          SBR  x1
 1114          B    cgo
 1118cgofin    MN   0&X1
 1122          SAR  x1
 1126          B    moveup
     *
     * READ INPUT TAPE or WRITE OUTPUT TAPE statement
     *
 1130tape      MCW  x1,stmfin&3
 1137getcom    BCE  gotcom,0&X1,,  get
 1145          BCE  syntax,0&X1,}    down
 1153          SBR  x1                 to
 1157          B    getcom               comma
 1161gotcom    SW   1&X1
 1165          MN
 1166          SAR  x1
 1170          B    savlab
     *
 1174stmfin    LCA  0,0&X2
 1181          SBR  x2
 1185          CW   1&X2
 1189          B    moveup
     *
     * IF ( SENSE SWITCH ... ) or IF ( SENSE LIGHT ... ) statement
     *
 1193ifss      MCW  x1,stmfin&3
 1200getrp     BCE  gotrp,0&X1,)  get
 1208          BCE  syntax,0&X1,}   down
 1216          SBR  x1                to right
 1220          B    getrp               parenthesis
 1224gotrp     SW   1&X1
 1228          MN
 1229          SAR  x1
 1233          B    savlab
 1237          MN   0&X1
 1241          SAR  x1
 1245          BCE  syntax,0&X1,}
 1253          B    savlab
 1257setcom    LCA  comma,0&X2
 1264          SBR  x2
 1268          CW   1&X2
 1272          B    stmfin
     *
     * DO statement
     *
 1276do        MCW  x1,x3
 1283geteq     BCE  goteq,0&X3,#  Find the
 1291          SBR  x3              equal sign
 1295          B    geteq
 1299goteq     MCW  3&X3,ch2
 1306          MCW  comma,3&X3
 1313          SBR  w3,3&X3
 1320          B    savlab
 1324          C    w3,x1
 1331          BU   syntax
 1336          MCW  ch2,0&X1
 1343          LCA  comma,0&X2
 1350          SBR  x2
 1354          CW   1&X2
 1358          B    moveup
     *
     * IF statement
     *
 1362if        MCW  x1,stmfin&3
 1369ifloop    BCE  ifrp,0&X1,)    get down to right parenthesis
 1377          BCE  syntax,0&X1,}
 1385          SBR  x1
 1389          B    ifloop
 1393ifrp      MN   0&X1
 1397          SAR  x1
 1401          BWZ  *&5,0&X1,2  followed by a digit
 1409          B    ifloop
 1413          BCE  ifloop,0&X1,@
 1421          SW   1&X1
 1425          B    savlab
 1429          MN   0&X1
 1433          SAR  x1
 1437          BCE  syntax,0&X1,}
 1445          B    savlab
 1449          MN   0&X1
 1453          SAR  x1
 1457          BCE  syntax,0&X1,}
 1465          B    savlab
 1469          B    setcom
     *
     * Move the label to the label work area
     *
 1473savlab    SBR  savlbx&3
 1477          MCW  x1,labmov&3
 1484          BWZ  *&5,0&X1,2
 1492          B    syntx2
 1496savll     MN   0&X1
 1500          SAR  x1
 1504          BWZ  savll,0&X1,2
 1512          BCE  endlab,0&X1,,
 1520          BCE  endlab,0&X1,}
 1528          BCE  endlab,0&X1,)
 1536          B    syntx2
 1540endlab    SW   1&X1
 1544labmov    LCA  0,label
 1551          CW   1&X1
 1555          B    conv50
 1559savlbx    B    0
     *
     * Convert labels to base 50
     *
 1563conv50    SBR  conv5x&3
 1567          LCA  kz6,lblwrk
 1574          C    kz6,label
 1581          BU   *&5
 1586          B    zlab  label is zero
 1590          SBR  x3,label&1
 1597ztrim     MN   0&X3       trim
 1601          SAR  x3           leading zeros
 1605          BCE  ztrim,0&X3,0   from label
 1613          MCW  0&X3,lblwrk  nonzero digits of label
 1620          MCW  k1              and 1
 1624zlab      SW   lblwrk-1
 1628          CW
 1629          SW
 1630          CW
 1631          SW
 1632          S    k5050,lblwrk
 1639          S
 1640          BM   *&8,lblwrk
 1648          A    k1,lblwrk-5
 1655          BM   *&8,lblwrk-2
 1663          A    k2,lblwrk-5
 1670          MZ   x1tags,lblwrk
 1677          chain5
 1682          MCW  x1,sx1
 1689          MCW  achars,x1
 1696          MCW  alblwk,x3
 1703conv5l    MCW  0&X3,*&8
 1710          SAR  x3
 1714          MCW  0-0,ch
 1721          LCA  ch,0&X2
 1728          SBR  x2
 1732          CW   1&X2
 1736          BWZ  conv5l,0&X3,2
 1744          MCW  sx1,x1
 1751conv5x    B    0
     *
     * Statement number syntax error
     *
 1755syntax    CS   332
 1759          CS
 1760          SW   glober
 1764          MN   prefix,249
 1771          MN
 1772          MN
 1773          MCW  err13
 1777          W
 1778          BCV  *&5
 1783          B    *&3
 1787          CC   1
 1789          BW   more,flag
 1797          B    getup
 1801syntx2    SW   flag
 1805          B    syntax
 1809more      MCM  1&X2
 1813          MN
 1814          SAR  x2
 1818          BCE  more,0&X2,|
 1826          CW   flag
 1830getup     MCM  4&X2  Move x2 up to gmwm
 1834          MN
 1835          MN
 1836          SAR  x2
 1840          C    0&X1  get x1 down to wm
 1844          SAR  x1
 1848          B    loop
     *
     * Reached bottom of statements
     *
 1852done      BSS  snapsh,C
 1857          SBR  loadxx&3,980
 1864          SBR  clearl&3,1599
 1871          LCA  formt1,phasid
 1878          B    loadnx
     *
     * Done
     *
 1882          DCW  #1
 1883gm        dc   @}@
 1884dot       dc   @.@
 1890lblwrk    DCW  #6
 1891ch        DCW  #1
 1894sx1       DCW  #3
 1895flag      dc   #1
     chars     equ  *&1
 1941          dc   @.")&$*-%#@?ABCDEFGHI!JKLMNOPQR_/STUVWXYZ012345@
 1946          DC   @6789.@
 1952kz6       DCW  @000000@
 1962prefix    DCW  #10
 1973stmts     DCW  @WT65UPLDEGK@  Codes for statements having labels
 1979label     DCW  #6
 1980comma     dcw  @,@
 1981ch2       DCW  #1
 1984w3        DCW  #3
 1985k1        dcw  1
 1989k5050     dcw  5050
 1990k2        dcw  2
 1996x1tags    DCW  @Z Z Z @
 1999achars    DSA  chars
 2002alblwk    DSA  lblwrk
 2048err13     DCW  @ERROR 13 - STATEMENT NUMBER SYNTAX, STATEMENT @
 2058formt1    DCW  @TAMROF ONE@
 2059gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
