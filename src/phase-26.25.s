               JOB  Fortran compiler -- List Phase Two -- phase 26
               CTL  6611
     *
     * The object-time list strings are developed and stored
     * immediately to the left of the format strings at the lower
     * (high address) end of storage.
     *
     * On entry, x1 is the top of statements in low core, 81-83
     * is three below the format strings or number table.
     *
     x1        equ  89
     x2        equ  94
     x3        equ  99
     *
     * Stuff in the resident area
     *
     phasid    equ  110  Phase ID, for snapshot dumps
     negar2    equ  142  Looks like negary -- see phase 20
     arysiz    equ  160  Total array size & 2
     negary    equ  163  16000 - arysiz
     glober    equ  184  Global error flag -- WM means error
     snapsh    equ  333  Core dump snapshot
     imod      equ  690  Integer modulus -- number of digits
     mantis    equ  692  Floating point mantissa digits
     loadnx    equ  700  Load next overlay
     clearl    equ  707  CS at start of overlay loader
     tpread    equ  780  Tape read instruction in overlay loader
     seqcod    equ  841  Statement code and sequence number
     sx1       equ  844  Save are for X1 from phase 25 -- same as
     *                 X1 on entry here
     *
     110       dcw  @listr2@
     *
               ORG  845
     loaddd    equ  *&1          Load address
  845beginn    MCW  83,x2
  852loop      BW   done,0&X1
  860          MCW  x2,sx2
  867          MCW  0&X1,seqcod
  874          MCW  x1,savseq&6
  881          C    0&X1       Get x1
  885          SAR  x1           down to body
  889          SBR  x3
  893getgm     C    0&X3       Get x3 down
  897          SAR  x3           to below gmwm at
  901          BCE  gotgm,1&X3,}   bottom of statement
  909          B    getgm
  913gotgm     SBR  sx3&6,0&X3
  920          C    0&X1
  924          C
  925          SAR  sx1b
  929          BCE  gotcom,0&X1,,
  937          chain6
  943          B    finls2
  947gotcom    MCW  sx1b,x1
  954          BCE  nolink,1&X1,}  List not linked to another?
  962          MCW  3&X1,x3
  969          BW   lsterr,1&X3
  977          LCA  1&X3,4&X1
  984          CW
  985          B    sx3
  989nolink    BCE  endls2,2&X3,,
  997          SBR  x3
 1001mark      LCA  kdot,0&X2  below number table and formats
 1008          SBR  x2
 1012          CW   1&X2
 1016          S    w1
 1020nxtlst    SBR  x3,1&X3
 1027          BCE  rpar,0&X3,)
 1035          BCE  subs,0&X3,$
 1043          B    adrtst
 1047          LCA  w3,0&X2
 1054          SBR  x2
 1058          BCE  gotcm2,0&X3,,
 1066          BCE  lpar,0&X3,%
 1074          B    adrtst
 1078          LCA  w3,0&X2
 1085          LCA  comma
 1089          SBR  x2
 1093          CW   5&X2
 1097          CW   1&X2
 1101          MZ   3&X2,kb1
 1108          MCW  x1,sx1d
 1115          ZA   imod,width
 1122          BM   int,3&X2  integer
 1130          MCW  mantis,width
 1137int       S    kp16k,width
 1144          MN   width,mwidth
 1151          MN
 1152          MN
 1153          SAR  *&4   why not just
 1157          MCW  0,x1    MCW WIDTH-3,0&x1?
 1164          MCW  k0
 1168          A    x1
 1172          MZ   zones&1&X1,mwidth
 1179          CW
 1180          SBR  *&7         why not just
 1184          MZ   zones&X1,0    MZ ZONES&x1,MWIDTH-2?
 1191          MCW  mwidth,x1
 1198          MCW  4&X2,*&14
 1205          MZ   *-6,*&6  Set x1 zone
 1212          SBR  4&X2,0
 1219          MZ   kb1,3&X2
 1226          MCW  sx1d,x1
 1233          MZ   *-4,6&X2  clobber type tag
 1240testlp    BCE  lpar,0&X3,%
 1248tstlst    C    0&X3,comma
 1255          BU   lsterr
 1260gotcm2    BW   endlst,0&X3
 1268          B    nxtlst
     *
     * Right parenthesis -- bottom of implied do
     *
 1272rpar      BCE  rpar0,w1,?
 1280rparb     MCW  x1,sx1c
 1287          LCA  kdot,0&X1
 1294          SBR  x1
 1298          A    kp1,w1
 1305          BCE  lsterr,w1,D
 1313          B    movadr  increment or upper bound
 1317          C    0&X3,comma
 1324          BU   lsterr
 1329          B    movadr  upper bound or lower bound
 1333          BCE  movadr,0&X3,,  lower bound
 1341          C    0&X3,kequal
 1348          BU   lsterr
 1353          B    movadr  subscript/loop inductor
 1357          SBR  0&X1,1&X2
 1364          CW   0&X1  decrease x1
 1368          CW
 1369          SW
 1370          SAR  x1
 1374          MCW  x3,sx3b
 1381          MN   0&X3
 1385          SAR  x3
 1389rlpar     BCE  lpar2,2&X3,%
 1397          BCE  rpar2,2&X3,)
 1405          BW   lsterr,2&X3
 1413          SBR  x3
 1417          B    rlpar
 1421lpar2     LCA  krpar,0&X2
 1428          SBR  x2
 1432          CW   1&X2
 1436          B    rpmore
 1440rpar2     LCA  eqblnk,0&X2
 1447          SBR  x2
 1451          SW   2&X2
 1455          CW
 1456rpmore    MCW  sx3b,x3
 1463          B    tstlst
     *
     * Left parenthesis -- top of implied do
     *
 1467lpar      S    kp1,w1
 1474          BM   lsterr,w1  unbalanced parentheses
 1482          MA   negary,3&X1
 1489          LCA  3&X1,0&X2
 1496          LCA  6&X1
 1500          SBR  x2
 1504          BCE  dot,13&X1,.
 1512          LCA  15&X1,0&X2
 1519          SBR  x2
 1523lpar3     LCA  12&X1,0&X2
 1530          LCA
 1531          LCA  klpar
 1535          SBR  x2
 1539          CW   1&X2
 1543switch    NOP  lpar5
 1547          MCW  3&X1,x1
 1554          MN   0&X1
 1558          SAR  x1
 1562          MA   arysiz,x1
 1569          MA   negary,x2
 1576          SBR  0&X1,1&X2
 1583          MA   arysiz,x2
 1590lpar4     SBR  x3,1&X3
 1597          MCW  sx1c,x1
 1604          B    testlp
 1608lpar5     MCW  nop,switch
 1615          B    lpar4
 1619dot       LCA  negar2,0&X2
 1626          SBR  x2
 1630          B    lpar3
     *
     * Right parenthesis and w1 is zero
     *
 1634rpar0     SBR  x1,w48
 1641          MCW  branch,switch
 1648          B    rparb
     *
     * Move address at 1&x3..3&x3 to w3 and -2&x1..0&x1,
     * decrement x3 by 3.
     *
 1652movadr    SBR  movadx&3
 1656          SBR  x3,1&X3
 1663          B    adrtst
 1667          LCA  w3,0&X1
 1674          SBR  x1
 1678          MZ   *-4,2&X1  clobber type tag (why?)
 1685          BW   lsterr,0&X3
 1693movadx    B    0
     *
     * End of I/O list
     *
 1697endlst    C    w1,kp0  parentheses balanced
 1704          BU   lsterr  no
 1709          CW   0&X3
 1713          CW
 1714          SW
 1715          SAR  x3
 1719          SBR  3&X3,1&X2
 1726          MA   negary,3&X3
 1733          B    sx3
     *
     * Dollar sign -- bottom of subscript
     *
 1737subs      SW   0&X3
 1741          SAR  x3
 1745          SBR  sx1e&3,1&X3
 1752getdol    BCE  gotdol,2&X3,$
 1760          SBR  x3
 1764          B    getdol
 1768gotdol    LCA  2&X3,0&X2
 1775          SBR  x2
 1779          CW   1&X2
 1783          SBR  x3,3&X3
 1790sx1e      CW   0
 1794          B    testlp
 1798endls2    BW   finlst,2&X3
 1806          SBR  x3,2&X3
 1813          B    mark
 1817finlst    SW   3&X3
 1821          CW
 1822finls2    BCE  lsterr,seqcod-3,1
 1830          BCE  lsterr,seqcod-3,3
 1838          B    savseq
     *
     * Test whether three characters starting at X3 are an address,
     * i.e., that the numeric part is a digit.  If so, move it to
     * w3 and bump X3 by 3.
     *
 1842adrtst    SBR  adrtsx&3
 1846          MN   2&X3,digtst&11
 1853          B    digtst
 1857          MN   1&X3,digtst&11
 1864          B    digtst
 1868          MN   0&X3,digtst&11
 1875          B    digtst
 1879          MCW  2&X3,w3
 1886          SBR  x3,3&X3
 1893adrtsx    B    0-0
 1897digtst    SBR  *&4
 1901          BCE  0-0,digits,0
 1909          chain9
 1918          B    lsterr
 1922lsterr    CS   332
 1926          CS
 1927          SW   glober
 1931          MN   seqcod,234
 1938          MN
 1939          MN
 1940          MCW  err47
 1944          W
 1945          BCV  *&5
 1950          B    *&3
 1954          CC   1
 1956          MCW  slash,seqcod-3  convert to end statement
 1963savseq    MCW  seqcod,0
 1970          MCW  sx2,x2
 1977sx3       SBR  x1,0
 1984          B    loop
 1988done      MCW  sx1,x1
 1995          BSS  snapsh,C
 2000          SBR  clearl&3,gmwm
 2007          LCA  list3,phasid
 2014          B    loadnx
     *
     * Data
     *
 2019zones     DCW  @ 9@
 2050          DCW  @9Z9R9I99ZZZRZIZ9RZRRRIR9IZIRIII@
 2053sx2       DCW  #3
 2056sx1b      DCW  #3
 2057kdot      dcw  @.@
 2058w1        DCW  #1
 2059comma     dcw  @,@
 2060kb1       DCW  #1
 2063sx1d      DCW  #3
 2068width     DCW  #5
 2073kp16k     DCW  @1600?@
 2074k0        DCW  0
 2077mwidth    DCW  #3  width - 16000 in machine form
 2080sx1c      DCW  #3
 2081kp1       dcw  &1
 2082kequal    dcw  @#@
 2085sx3b      DCW  #3
 2086krpar     dcw  @)@
 2090eqblnk    dcw  @#   @
 2091klpar     dcw  @%@
 2092nop       NOP
 2140w48       DCW  #48
 2141branch    B
 2142kp0       dcw  &0
 2145w3        DCW  #3
 2155digits    DCW  @0123456789@
 2186err47     DCW  @ERROR 47 - BAD LIST, STATEMENT @
 2187slash     dcw  @/@  code for end statement
 2196list3     DCW  @LISTR TRI@
 2197gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
