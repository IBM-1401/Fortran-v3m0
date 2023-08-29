               JOB  Fortran compiler -- TAMROF Phase Two -- 24
               CTL  6611
     *
     * The object-time format strings are developed and stored
     * immediately preceding the constants at the lower (rightmost)
     * end of storage.
     *
     * On entry, x1 is the top of statements, x2 is the top of
     * formatted I/O statements, and 81-83 is one below the number
     * table.
     *
     x1        equ  89
     x2        equ  94
     x3        equ  99
     *
     * Stuff in the resident area
     *
     phasid    equ  110  Phase ID, for snapshot dumps
     arysiz    equ  160  Total array size & 2
     negary    equ  163  16000 - arysiz
     snapsh    equ  333  Core dump snapshot
     loadnx    equ  700  Load next overlay
     clearl    equ  707  CS at start of overlay loader
     tpread    equ  780  Tape read instruction in overlay loader
     loadxx    equ  793  Exit from overlay loader
     clrbot    equ  833  Bottom of core to clear in overlay loader
     toobig    equ  838  Too big routine
     semic     equ  872  A semicolon
     sx3       equ  875  Save area for X3 -- used exactly once?
     seqcod    equ  879  Statement code, sequence number
     msg       equ  880  Error message routine
     *
     110       dcw  @tamrof 2@
     *
               ORG  980
     loaddd    equ  *&1          Load address
  980beginn    BCE  done,96,.  No format statements
  988          MCW  x2,sx2&6
  995next      SBR  x2,2&X1
 1002          LCA  kb1
 1006          MCW  0&X1,seqcod
 1013          BCE  format,seqcod-3,F
     *
     * Format statements are sorted together, so if we do not
     * see one here, there are no more.
     *
 1021done      BSS  snapsh,C
 1026          SBR  tpread&6,838
 1033          SBR  clrbot
 1037          SBR  loadxx&3,845
 1044          SBR  clearl&3,gmwm
 1051          LCA  listr1,phasid
 1058          B    loadnx
     *
     * Format statement
     *
 1062format    C    0&X1  get down to body
 1066          SAR  x1
 1070          SBR  sx1&6
 1074          MCW  4&X1,fmtlab
 1081          SW   flag1
 1085          CW   flag2
 1089          ZA   kp1,w3
 1096          BCE  syntax,0&X1,)
 1104          MCW  x2,sx2b
 1111          B    cont
 1115sx1       SBR  x1,0
 1122loop      ZA   kp1,w3
 1129codeok    BCE  rpar,0&X1,)
 1137          SBR  sx1&6
 1141          BCE  lpar,0&X1,%
 1149          BCE  ifea,0&X1,I
 1157          BCE  ifea,0&X1,F
 1165          BCE  ifea,0&X1,E
 1173          BCE  ifea,0&X1,A
 1181          BCE  sign,0&X1,&
 1189          BCE  sign,0&X1,-
 1197          BCE  slash,0&X1,@
 1205          C    0&X1,kz
 1212          BL   number
 1217          BL   chkcod
 1222          BW   syntax,flag1  not preceded by a number?
 1230          BCE  holrit,0&X1,H  Number, the Hollerith
 1238          SBR  x1
 1242          BCE  xfld,1&X1,X
 1250          BCE  pfld,1&X1,P
 1258syntax    B    msg
 1262          MCW  err15,223
 1269wmsg      W
 1270          MZ   abzone,seqcod
 1277          B    endfmt
     *
     * X format control.  Emit SBR x3,number&x3
     *
 1281xfld      SW   8&X2
 1285          SBR  x2
 1289          LCA  bumpx3
 1293          MN   w3,0&X2
 1300          MN
 1301          MN
 1302          B    endfld
     *
     * Hollerith
     *
 1306holrit    SW   5&X2
 1310          CW
 1311          SBR  x2
 1315          LCA  doh&3,1&X2  emit call to do hollerith routine
 1322          S    kp1,w3
 1329          BM   syntax,w3
 1337          MN   0&X1
 1341          SAR  x1
 1345moveh     MN   0&X1,2&X2  move
 1352          SBR  x2           characters
 1356          MZ   0&X1,1&X2      of hollerith
 1363          SAR  x1               field while
 1367          SBR  sx1&6              reversing
 1371          CW   2&X2                 to correct
 1375          S    kp1,w3                 order
 1382          BCE  shorth,0&X1,}
 1390          BWZ  moveh,w3,B
 1398holfin    SBR  x2,1&X2
 1405          B    endfld
     *
     * Statement ends before hollerith ends
     *
 1409shorth    B    msg
 1413          MCW  err45,231
 1420          W    holfin
     *
     * Plus or minus sign before number before P code
     *
 1424sign      MZ   0&X1,w3  Move sign to where the number will be
 1431          SAR  x1
 1435          B    number
 1439          C    x3,k20
 1446          BL   syntax   scale factor too big?
 1451          MN   x3,w3
 1458          MN
 1459          C    0&X1,kp
 1466          SAR  sx1&6
 1470          SBR  x1
 1474          BU   syntax   error if not P field
 1479pfld      SBR  x2,7&X2
 1486          LCA  w3       emit scale factor
 1490          LCA  dop&3    emit call to P routine
 1494          B    endfld
     *
     * Left parenthesis
     *
 1498lpar      BW   deep,flag2
 1506          SW   flag2
 1510cont      SW   8&X2
 1514          SBR  x2
 1518          CW   flag3
 1522          LCA  w3,0&X2
 1529          LCA  dolp&3
 1533          SW   flag1
 1537          B    sx1
     *
     * Right parenthesis
     *
 1541rpar      MN   0&X1
 1545          SAR  sx1&6
 1549          SBR  *&7
 1553          BCE  sawgm,0,}
 1561          BW   rpok,flag2  seen a right parenthesis?
 1569deep      B    msg
 1573          MCW  err16,228
 1580          B    wmsg
     *
 1584rpok      CW   flag2
 1588          SW   5&X2
 1592          SBR  x2
 1596          LCA  dorp&3
 1600          MN   0&X1
 1604          SAR  x1
 1608          B    endfld
     *
     * Saw gm after right parenthesis
     *
 1612sawgm     CW   5&X2
 1616          SBR  x2
 1620          LCA  dogm&3
 1624          BW   deep,flag2
 1632          B    endfmt
     *
     * Slash field.  Slash was converted to @ in phase 2
     *   
 1636slash     BW   *&5,flag1  no number?
 1644          B    syntax     error if number
 1648          SW   5&X2
 1652          SBR  x2
 1656          LCA  doslsh&3  emit call to slash routine
 1660          B    sx1
     *
     * I, F, E or A field
     *
 1664ifea      SW   5&X2
 1668          LCA  doifea&3
 1672          LCA  w3,8&X2
 1679          MCW  0&X1
 1683          SAR  x1
 1687          B    number
 1691          ZA   x3,w3b
 1698          SW   ifeat&4
 1702          BCE  ffld,5&X2,F
 1710          BCE  iafld,5&X2,I
 1718          BCE  iafld,5&X2,A
 1726          S    kp4,w3b  Ew.d field, subtract four from W for exp
 1733ffld      CW   ifeat&4  Fw.d field
 1737          C    0&X1,kdot
 1744          SAR  x1
 1748          BU   syntax  number not followed by dot
 1753          B    number
 1757          S    x3,w3b  subtract D from W
 1764          BM   wbig,w3b
 1772iafld     BCE  ffld2,5&X2,F  I or A field
 1780          A    kp4,x3
 1787ffld2     SBR  x2,11&X2
 1794          MZ   *-4,w3b
 1801          LCA  w3b,0&X2
 1808ifeat     BCE  tstwid,ifeat,C
 1816          SBR  x2,3&X2
 1823          LCA  x3
 1827tstwid    BM   syntax,w3b
     *
     * end of field
     *
 1835endfld    SW   flag1  set no number flag
 1839skpcom    C    0&X1,comma
 1846          SAR  sx1&6
 1850          SBR  x1
 1854          BE   skpcom  skip commas
 1859          SBR  x1,1&X1
 1866          B    loop
     *
     * W gt D for F field, or W+4 gt D for E field
     *
 1870wbig      A    x3,w3b
 1877          A    k4,w3b
 1884          MN   w3b,x3
 1891          MN
 1892          MN
 1893          MCW  kz3,w3b
 1900          B    ffld2
     *
     * Probably a digit.  Make sure.  Then put into x3.
     *
 1904number    SBR  numbrx&3
 1908          S    x3&1    clear x3
 1912          C    0&X1,k0
 1919          BH   syntax  0 gt char, z lt char
 1924numbrl    MN   0&X1,x3
 1931          SAR  x1
 1935          C    0&X1,k0
 1942          BH   nodig   not a digit, must be done
 1947          C    x3,k133  is the number too big?
 1954          BL   syntax
 1959          MN   x3-1,x3-2  shift left to reverse
 1966          MN   x3,x3-1      digits to correct order
 1973          B    numbrl   look for another digit
 1977nodig     C    k134,x3  Is the number too big?
 1984          BH   syntax
 1989          BE   syntax
 1994numbrx    B    0
     *
     * Check the format code following a number
     *
 1998chkcod    ZA   x3,w3  save number
 2005          SW   test&7
 2009          MCW  0&X1,test&7
 2016          CW   test&7,flag1
 2023test      BCE  codeok,fmtcod,X
 2031          chain7
 2038          B    syntax
     *
 2042endfmt    MCW  83,x3
 2049          BWZ  enderr,seqcod,B
 2057          C    0&X3,semic  semicolon below number table gone?
 2064          BU   toobig
 2069endfm2    LCA  0&X2,0&X3
 2076          SAR  x2
 2080          C    0&X3
 2084          SAR  x3
 2088          CW   1&X2
 2092          C    x2,sx2b
 2099          BU   endfm2
 2104          SBR  sx3,0&X3
 2111          CW   0&X2
 2115          CW
 2116          MCW
 2117          SAR  x2
 2121          CW   1&X2
 2125          BW   ender2,flag3
 2133          BCE  ender2,*&6,  was X2 originally blank?
 2141sx2       SBR  x2,0
 2148          CW   flag4
 2152          SBR  sx3b&6,1&X3
 2159ender4    MN   0&X2
 2163          MN
 2164          MN
 2165          SAR  x3
 2169          MN   0&X3,*&15
 2176          MZ   0&X3,*&8
 2183          BCE  iostmt,iocode,X
 2191          chain4
 2195          BW   ender5,flag4
 2203          B    msg
 2207          MCW  err17,232
 2214          W
 2215          B    ender6
 2219ender5    MCW  sx3,x3
 2226          BWZ  ender6,seqcod,B
 2234ender3    MCW  x3,83
 2241          MCW  semic,0&X3
 2248ender2    C    0&X1
 2252          SAR  x1
 2256          B    next
     *
 2260enderr    MCW  x2,x3
 2267          SW   flag3
 2271          B    endfm2
 2275ender6    MCW  83,x3
 2282          LCA  kdot,0&X3
 2289          SBR  x3
 2293          B    ender3
     *
 2297iostmt    C    0&X3
 2301          SAR  x2
 2305          BWZ  *&5,2&X3,B
 2313          B    iostme
 2317          C    0&X2,fmtlab
 2324          BU   iostme
 2329          SW   flag4
 2333          MA   negary,sx3b&6
 2340sx3b      SBR  0&X2,0
 2347          MZ   kb1,2&X3
 2354          MA   arysiz,sx3b&6
 2361iostme    C    0&X2
 2365          SAR  x2
 2369          B    ender4
     *
     * Vectors to format conversion routines
     *
 2373doh       B    2328       do hollerith
 2383bumpx3    DCW  @H0990&0@  bumps x3, for X format
 2384dolp      B    2152       do left parenthesis
 2388dorp      B    2185       do right parenthesis
 2392doslsh    B    2208       do / -- newline
 2396doifea    B    2385       I, F, E or A field
 2400dogm      B    2223       do gm -- end of format
 2404dop       B    2310       do P -- scale factor
     *
     * Data
     *
 2408kb1       DCW  #1
 2414listr1    DCW  @LISTR1@
 2417fmtlab    DCW  #3
 2418flag1     DCW  #1  cleared when a number is processed
 2419flag2     DCW  #1  set when left parenthesis is processed
 2420kp1       dcw  &1
 2423sx2b      DCW  #3
 2426w3        DCW  #3
 2427kz        dcw  @Z@
 2445err15     DCW  @15 - FORMAT SYNTAX@
 2446abzone    dcw  @A@
 2466err45     DCW  @45 - HOLLERITH COUNT@
 2469k20       dcw  020
 2470kp        dcw  @P@
 2492err16     DCW  @16 - PARENTHESIS ERROR@
 2495w3b       DCW  #3
 2496kp4       dcw  &4
 2497kdot      dcw  @.@
 2498comma     dcw  @,@
 2499k4        dcw  4
 2502kz3       dcw  000
 2503k0        DCW  0
 2506k133      dcw  133
 2509k134      dcw  134
 2517fmtcod    DCW  @PAXHIFE%@
 2518flag4     DCW  #1
 2523iocode    DCW  @56ULP@  stmt code for formatted I/O stmt
 2549err17     DCW  @17 - DOUBLY DEFINED FORMAT@
 2550flag3     dcw  #1  set if error
 2598          DC   #48
 2599gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
