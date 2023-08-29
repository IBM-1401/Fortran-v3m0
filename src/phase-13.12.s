               JOB  Fortran compiler -- Variable Phase One -- 13
               CTL  6611
     *
     * The source program is scanned for variables.  Simple
     * variables are merely tagged for later processing by
     * Variables Phase Four.  Subscripted variables whose
     * subscripts are constants are replaced by the object-
     * time address of the array element.  Subscripted variables
     * whose subscripts are variable are replaced by the
     * computation required at object time to determine the
     * array element selected.  Non-subscripted array variables
     * appearing in lists are replaced by two machine-language
     * addresses representing the limits of the array.  Non-
     * subscripted array variables appearing elsewhere are
     * replaced by the address of the first element of the
     * array.
     *
     * On entry, 83 is one below the GM below the bottom of
     * the array table and x1 is at the top of the first (in sorted
     * order) statement that's neither dimension nor equivalence.
     *
     * On exit the code is moved up against the array table.
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
     110       dcw  @varbl 1@
     094       dcw  000
     096       dc   00
     099       dcw  000
     100       dc   0
     *
               ORG  838
     loaddd    equ  *&1          Load address
  838beginn    MCW  83,x2
  845          MCW  x2,tblbot  Save bottom of array table
  852          SW   gm
  856nxtstm    BCE  done,0&X1,  No more statements?
  864          LCA  0&X1,prefix
  871          SAR  x1          Top of statement
  875          SBR  x3
  879          LCA  prefix,0&X2  Push up below array table
  886          SBR  x2          and save the next available
  890          BCE  format,prefix-3,F  Format statement?
  898          SW   prefix-3
  902          MCW  prefix-3,*&8
  909          BCE  datxfr,datxfc,0  Data transfer statement?
  917          chain6
     *
     * Not a data transfer statement
     *
  923          MCW  nop,swich1  Turn off data transfer
  930          MCW  nop,swich2    statement switches
     *
     * Back here for either data transfer statement or not
     *
  937stmt      MCW  0&X1,ch    Skip numeric
  944          SAR  x1           and non-zoned punctuation
  948          BWZ  stmt,ch,2      characters
  956swich1    NOP  datxf1     Branch if data transfer statement
  960skipp     MCW  ch,*&8       Skip @*-&.%),
  967          BCE  stmt,punct,0   punctuation
  975          chain7
  982          BCE  fltcon,ch,E  Floating-point constant?
  990          BCE  gotvar,ch,}  GM (bottom of stmt)?
  998          MCW  2&X1,ch2
 1005          MCW  ch2,*&8
 1012          BCE  gotvar,punct2,0  #,}*@&-%)
 1020          chain8
 1028          BCE  gotvar,prefix-3,D  Do statement?
 1036syntax    CS   332
 1040          CS
 1041          SW   glober      Global error flag
 1045          MN   prefix,240  Sequence number to print line
 1052          MN
 1053          MN
 1054          MCW  error9  Variable syntax error
 1058          W
 1059          BCV  ovfl1
 1064          B    novfl1
 1068ovfl1     CC   1
 1070novfl1    BW   cw1s6,flag1  go clear flag 1 and set flag 6
 1078          SBR  x1,1&X1
 1085          SW   flag3
 1089          B    skp2p2  Skip to punct2 punctuation
     *
 1093suber2    LCA  k0q0,0&X2  0?0
 1100          SBR  x2
 1104          SBR  x3,1&X1
 1111          SBR  x1
 1115          B    varfin
     *
     * X1 is at the GM at the bottom of the statement, or one below
     * the top (first) character of a variable.
     * Move stuff above and first character up.
     *
 1119gotvar    SW   1&X1
 1123          LCA  0&X3,0&X2  Move up stuff above (before) var
 1130          SBR  x2
 1134          CW   1&X1
 1138          SBR  x3,1&X1    X3 now at top (beginning) of variable
 1145          SBR  check&6,2&X1
 1152          MCW  semic      Replace char above variable or GM
 1156          BCE  endstm,ch,}  End if GM
 1164          ZA   kp1,w2
     *
`    * Count characters in name
     *
 1171skp2p2    MCW  0&X1,ch
 1178          SAR  x1
 1182          MCW  ch,*&8
 1189          BCE  gotp2,punct2,0  #,}*@&-%)
 1197          chain8
 1205          A    kp1,w2
 1212          B    skp2p2
     *
 1216gotp2     BW   subfn1,flag6
 1224          BW   suber2,flag3
 1232          SW   2&X1       At bottom (last) char of token
 1236          SAR  sx1        Save 1&x1 at punct below name
     *
     * Look for variable in array table.  X3 is at top (first)
     * character of the variable.  CH is character below (after)
     * the variable.
     *
 1240lookup    MCW  tblbot,x1  Get bottom of array table
 1247          BCE  asg,ch,#   Go turn off swich2 if assignment stmt
 1255look2     BCE  notarr,2&X1,  At end of array table?
 1263more      MCM  2&X1
 1267          MN
 1268          MN
 1269          SAR  x1
 1273          BCE  more,1&X1,|
 1281          C    0&X3,0&X1
 1288          BU   look2
 1293          C    0&X1,0&X3
 1300          BU   look2
 1305          C    0&X1    Get x1 down to
 1309          chain3         offset field
 1312          SAR  x1
 1316          BW   subvr2,flag2  Working on variable subscript?
 1324          BCE  sub,ch,%  Subscripted
     *
     * In array table, not subscripted
     *
 1332swich2    NOP  datxf2  Branch if data transfer statement
 1336          LCA  9&X1,1&X2  Addr of low digit of first array elt
 1343          SBR  x2
 1347lookfn    MCW  sx1,x1
 1354          B    varfin
     *
     * Whole array
     *
 1358datxf2    LCA  9&X1,1&X2  Addr of low digit of first array elt
 1365          LCA  3&X1       Addr of low digit of last array elt
 1369          SBR  x2
 1373          CW   4&X2       between addresses
 1377          B    lookfn
     *
     * Not in array table.  X2 is two below the punctuation before
     * the variable or prefix moved to be below the array table.
     *
 1381notarr    MCW  sx1,x1
 1388          BW   subvr3,flag2  Working on variable subscript?
 1396          BCE  subnot,ch,%
 1404          LCA  kbundr,1&X2  Blank, underscore
 1411          SBR  x2
 1415notar2    LCA  0&X3,1&X2    Move variable up
 1422          SBR  x2
 1426          CW   1&X2
 1430          S    kp2,w2
 1437          BM   short,w2     Variable name is short
 1445varfin    CW   1&X1
 1449          SAR  x3
 1453varfn2    CW   1&X2
 1457          CW   flag4,flag3
 1464          CW   flag5
 1468check     BCE  stmt,0,;     Semicolon?
 1476          MCW  dollar,x1
 1483          B    done
     *
     * Not in array table, but appears to be subscripted
     *
 1487subnot    BCE  notar2,1&X1,F  Last char of var says function?
 1495          CS   332
 1499          CS
 1500          SW   glober
 1504          MN   prefix,240
 1511          MN
 1512          MN
 1513          MCW  error6
 1517          W
 1518          BCV  ovfl2
 1523          B    novfl2
 1527ovfl2     CC   1
 1529novfl2    LCA  kpct3z,1&X2    %000
 1536          SBR  x2
 1540          MZ   savzon,3&X2
 1547getend    BCE  endsub,0&X1,)  End of subscript?
 1555          BCE  endst2,0&X1,}  End of statement?
 1563          SBR  x1
 1567          B    getend
 1571endsub    MN   0&X1  X1 now below subscript
 1575          SAR  x1
 1579          B    varfn2
     *
     * In array table and subscripted
     *
 1583sub       ZA   0&X1,w6  High digit of first array element
 1590          SAR  x3       x3 now at first dimension
 1594          SW   flag7    In array table and subscripted
 1598          ZA   0&X3,w5  First dimension to w5
 1605          ZA   5&X1,prod-7  Element size
 1612          S    kp1,w6
 1619          MZ   8&X1,savzon  Type tag of array
 1626          MCW  sx1,x1   X1 back to statement
 1633          LCA  kbdolr,1&X2  Blank, $ indicates subscript
 1640          SBR  x2
 1644          MN   0&X1
 1648          SAR  x1
 1652          SBR  x3
 1656tstcon    BWZ  submor,0&X1,2  Constant subscript?
 1664          SBR  x1,2&X1
 1671          LCA  kstar1,0&X1  Star, 1 (1 is prev dim width)
 1678          B    submor
     *
     * Continue variable subscript processing
     *
 1682subvar    LCA  kbundr,1&X2  Blank, underscore indicates variable
 1689          SBR  x2
     *
     * Get down to the bottom of the variable
     *
 1693skp2p3    MCW  0&X1,ch
 1700          SAR  x1
 1704          MCW  ch,*&8
 1711          BCE  gotp3,punct3,0   -&),
 1719          chain3
 1722          B    skp2p3
 1726gotp3     SW   2&X1
 1730          SW
 1731          SAR  sx1
 1735          SW   flag2  Working on variable subscript
 1739          B    lookup
     *
 1743subvr2    LCA  9&X1,2&X2
 1750          SBR  x2
 1754          CW   1&X2
 1758          MN
 1759          SAR  x2
 1763          B    subvr4
     *
     * Move subscript up
     *
 1767subvr3    LCA  0&X3,1&X2
 1774          LCA
 1775          SBR  x2
 1779          CW   2&X2
 1783subvr4    MCW  sx1,x1
 1790          CW   2&X1
 1794          BCE  short2,3&X2,_
 1802          LCA  kbcomm,1&X2  Blank, comma
 1809          SBR  x2
 1813          CW   flag2  Done working on variable subscript
 1817          BCE  morsub,ch,,
 1825          BCE  subfin,ch,)
 1833          MZ   ch,prod-7
 1840subvr5    MCW  x1,x3
 1847          B    tstcon
     *
     * Continue subscript processing
     *
 1851submor    SBR  x3,bigwrk-2
 1858subm2     MCW  0&X1,ch   Move subscript
 1865          SAR  x1          to bigwrk putting
 1869          MCW  ch,2&X3       its characters
 1876          SBR  x3              into forward order
 1880          BWZ  subm2,0&X1,2  Constant subscript?
 1888          SBR  x1
 1892          M    prod-7,7&X3
 1899          BCE  subv1,1&X1,*   First variable subscript?
 1907          A    7&X3,w6        Add to offset from array base
 1914          BCE  subfin,1&X1,)  Done with subscripts?
 1922          BCE  morsub,1&X1,,  Second subscript?
 1930          SW   flag1
 1934          B    syntax
     *
 1938cw1s6     CW   flag1
 1942          SW   flag6
 1946          B    skp2p2
     *
 1950subfn1    CW   flag6
 1954subfin    NOP  w6-7
 1958          SAR  x3
 1962          SW   flag4        Moving variable subscript  
 1966          B    normlz
 1970subfn2    LCA  dollar,0&X2  Mark end of subscript
 1977          SBR  x2
 1981          MZ   savzon,3&X2
 1988          B    varfin
     *
     * First variable subscript
     *
 1992subv1     CW   1&X1,flag7
 1999          B    normlz
 2003          LCA  kbstar,0&X2
 2010          SBR  x2
 2014          CW   1&X2
 2018          MCW  x1,x3
 2025          B    subvar
     *
     * Normalize offset between 0 and 15999, store it
     * into code at top of core.
     *
 2029normlz    SBR  normlx&3
 2033normlp    S    kp16k,7&X3     Subtract 16000
 2040          BWZ  normlp,7&X3,B    until negative
 2048normln    A    kp16k,7&X3     Add 16000
 2055          BM   normln,7&X3      until positive
 2063          BW   cvtadr,flag4   Moving variable subscript?
 2071nortrm    SBR  x3,1&X3        Trim leading
 2078          BCE  nortrm,2&X3,0    zeroes
 2086          SBR  x2,1&X2
 2093          LCA  kb6 
 2097norrev    MCW  2&X3,ch   Move normalized
 2104          SAR  x3          offset up
 2108          MCW  ch,0&X2       while reversing
 2115          SBR  x2              the digits
 2119          BWZ  norrev,1&X3,2
 2127          MZ   kb1,1&X2  Clobber last digit zone
 2134normlx    B    0-0
     *
     * Done
     *
 2138done      BSS  snapsh,C
 2143          SBR  loadxx&3,849
 2150          SBR  clearl&3,gmwm
 2157          LCA  varbl2,phasid
 2164          B    loadnx
     *
     * data transfer input/output statement
     *
 2168datxfr    MCW  branch,swich1  Turn on data transfer
 2175          MCW  branch,swich2    statement switches
 2182          MCW  prefix-3,*&8
 2189          BCE  rwt,rwtc,0  Read/write (input/output) tape?
 2197          chain3
 2200          B    stmt  read, print or punch
 2204rwt       SW   flag5
 2208          B    stmt
 2212datxf1    BCE  datxrp,ch,)
 2220          B    skipp  Go skip punctuation
 2224datxrp    MCW  branch,swich2
 2231          B    skipp  Go skip punctuation
     *
     * Bottom (end) of statement
     *
 2235endst2    MN   0&X2
 2239          SAR  x2
 2243endstm    LCA  gm,1&X2
 2250          B    nxtstm
     *
     * Saw assignment operator (#)
     *
 2254asg       MCW  nop,swich2
 2261          B    look2
     *
     * Make sure at least 3 characters
     *
 2265short2    LCA  kb2,1&X2
 2272          SBR  x2
 2276          B    subvr4
     *
     * Variable name is short -- we need at least three spaces
     *
 2280short     LCA  kb1,0&X2
 2287          SBR  x2
 2291          CW   1&X2
 2295          B    varfin
     *
     * Looks like a floating-point constant
     *
 2299fltcon    BCE  gotvar,2&X1,#
 2307          BCE  gotvar,2&X1,@
 2315          BWZ  stmt,2&X1,2
 2323          BCE  stmt,2&X1,.
 2331          B    gotvar
     *
     * Convert bigwrk to machine address
     *
 2335cvtadr    MCW  7&X3,w5b
 2342          MN   w5b,subadr
 2349          MN
 2350          MN
 2351          SAR  *&4
 2355          MCW  0-0,x3  thousands
 2362          MCW  k0        and a zero to x3
 2366          A    x3      double x3
 2370          MZ   zones&1&X3,subadr
 2377          CW
 2378          SBR  *&7
 2382          MZ   zones&X3,0-0
 2389          BCE  cvtad2,2&X2,,
 2397          SBR  x2,1&X2
 2404cvtad2    LCA  subadr,1&X2
 2411          SBR  x2
 2415          CW   1&X2
 2419          MZ   savzon,2&X2
 2426          BW   varfin,flag7  In array table and subscripted?
 2434          B    subfn2
     *
     * Saw a comma, here comes another subscript
     *
 2438morsub    MZ   *-4,prod-7
 2445          M    w5,prod-1
 2452          MCM  prod-5,prod-11
 2459          S    prod-7,w6
 2466          B    subvr5
     *
     * Format statement -- just copy it
     *
 2470format    LCA  0&X1,0&X2  Copy stmt below array table
 2477          SBR  x2         save next 'to' address
 2481          C    0&X1       get to bottom of statement
 2485          SAR  x1         save top of next statement
 2489          B    nxtstm
     *
     * Data
     *
 2501punct2    DCW  @#,}*@&-%)@
 2502flag1     dc   #1  Syntax error after first subscript
 2503flag2     dc   #1
 2504flag3     dc   #1
 2505bigwrk    dcw  #1
 2554          DC   #49
 2555gm        DC   @}@
 2561          DCW  @ERROR @
 2582          DCW  @ VARIABLE, STATEMENT @
 2594prod      DCW  @           |@
 2597subadr    DCW  #3  Subscript variable address
 2598flag4     dc   #1  Moving variable subscript
 2599flag5     dc   #1
 2600flag6     dc   #1
 2602zones     DCW  @ 9@
 2633          DCW  @9Z9R9I99ZZZRZIZ9RZRRRIR9IZIRIII@
 2636tblbot    DCW  #3  Bottom of the array table
 2646prefix    DCW  #10
 2653datxfc    dcw  @3L5UP61@  codes for data transfer statements
 2654nop       NOP
 2655ch        DCW  #1
 2663punct     DCW  @@*-&.%),@  Punctuation characters
 2664ch2       DCW  #1
 2701error9    DCW  @ERROR 9 - VARIABLE SYNTAX, STATEMENT @
 2704k0q0      DSA  0&X3
 2705semic     DCW  @;@  semicolon
 2706kp1       dcw  &1
 2708w2        DCW  #2
 2711sx1       DCW  #3
 2713kbundr    DCW  @ _@  blank, underscore
 2714kp2       dcw  &2
 2715dollar    DCW  @$@
 2752error6    DCW  @ERROR 6 - UNDEFINED ARRAY, STATEMENT @
 2756kpct3z    dcw  @%000@
 2762w6        DCW  #6
 2767w5        DCW  #5
 2768savzon    DCW  #1
 2770kbdolr    DCW  @ $@
 2772kstar1    DCW  @*1@
 2776punct3    DCW  @-&),@
 2778kbcomm    DCW  @ ,@
 2779flag7     DCW  #1  WM means in array table and subscripted
 2781kbstar    DCW  @ *@
 2786kp16k     DCW  @1600?@
 2787kb1       dcw  #1
 2788kb2       dc   #1
 2792kb6       DC   #4
 2801varbl2    DCW  @VARBL TWO@
 2802branch    B
 2806rwtc      dcw  @1356@  Read/Write (input/output) tape codes
 2811w5b       DCW  #5
 2812k0        DCW  0
 2813gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
