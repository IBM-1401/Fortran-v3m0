               JOB  Fortran compiler -- Constants Phase One -- 18
               CTL  6611
     *
     * Constants in the source program are noted and normalized
     * and/or truncated.  The only word marks in the statement are
     * under the group marks that separate prefix from body and
     * one statement from another.
     *
     x1        equ  89
     x2        equ  94
     x3        equ  99
     *
     * On entry, X1 is the top of code.
     *
     * On exit, code is moved up to the top, 83 is the top of
     * code, and x2 is one below the bottom of code.
     *
     * Stuff in the resident area
     *
     phasid    equ  110  Phase ID, for snapshot dumps
     glober    equ  184  Global error flag -- WM means error
     snapsh    equ  333  Core dump snapshot
     topcor    equ  688  Top core address from PARAM card
     imod      equ  690  Integer modulus -- number of digits
     mantis    equ  692  Floating point mantissa digits
     loadnx    equ  700  Load next overlay
     clearl    equ  707  CS at start of overlay loader
     cdovly    equ  769  1 if running from cards, N if from tape
     loadxx    equ  793  Exit from overlay loader
     *
     110       dcw  @const one@
     094       dcw  000
     096       dc   00
     099       dcw  000
     100       dc   0
     *
               ORG  838
     loaddd    equ  *&1          Load address
  838beginn    CS   299
  842          SW   gm
  846          SW   200
  850          MCW  topcor,x2
  857          MN   0&X2
  861          MN
  862          SAR  x2          topcor-2
  866          SBR  83          topcor-2
  870          LCA  gm,1&X2     GMWM to topcor-1
  877loop      BCE  done,0&X1,  Bottom of statements if blank
  885          MCW  0&X1,seqcod
  892          LCA  0&X1,prefix
  899          SAR  x1
  903          SBR  sx1
  907          SBR  sx2,0&X2
  914          LCA  prefix,0&X2  Move prefix up
  921          SBR  x2
  925          MCW  seqcod-3,*&8
  932          BCE  io,codes,0  Interesting statement?
  940          chain9
  949          LCA  0&X1,0&X2   Move statement body up
  956          SAR  x1
  960          C    0&X2
  964          SAR  x2
  968          B    loop
     *
     * I/O, IF, DO, Arithemtic statement
     *
  972io        SBR  x3,codtab-4
  979          MCW  seqcod-3,*&8
  986search    BCE  found,4&X3,0
  994          SBR  x3
  998          B    search
     *
     * Found the statement code in codtab.  Copy the interesting
     * punctuation and the count to puncnt.  The punctuation
     * mark is what is sought in the statement.  The count
     * part is 2 minus the number of times the punctuation
     * mark must be found.  It starts at 0, 1 or 2, and is
     * incremented until it is 2.
     *
 1002found     MCW  6&X3,puncnt
 1009          MCW  puncnt-1,schpun&7
 1016schcnt    BCE  found2,puncnt,2  Found it enough times?
 1024          A    k1,puncnt
 1031schpun    BCE  gotpun,0&X1,0  Found the desired punctuation?
 1039          BCE  found2,0&X1,}  Found GM?
 1047          SBR  x1
 1051          B    schpun  go search for more punctuation
 1055gotpun    MN   0&X1
 1059          SAR  x1
 1063          B    schcnt  go test have we seen it enough times?
 1067found2    BWZ  nozone,0&X1,3  Digit or GMWM?
 1075          SBR  x1
 1079          BCE  switch,1&X1,$  Subscript?
 1087          B    found2
 1091nozone    BCE  endstm,0&X1,}  GM means end of statement
 1099          SBR  x1
 1103          BCE  found2,1&X1,#  assignment operator is not a number
 1111          BCE  found2,1&X1,@  atsign is not a number
 1119          MCW  2&X1,before
 1126          MCW       at
 1127          MCW       after
 1128          SAR  x1
 1132          MCW  before,*&8
 1139          BCE  found3,oppun,0  char before is operator or punct?
 1147          chain10
 1157          BCE  endstm,1&X1,}
 1165backsp    SBR  x1,1&X1
 1172          B    found2
     *
     * Subscript begin
     *
 1176switch    NOP  unsw
 1180          MCW  branch,switch
 1187          MCW  kb1,swich3&4  Set to unconditional branch
 1194          B    found2
     *
     * Subscript end
     *
 1198unsw      MCW  nop,switch
 1205          MCW  uneq,swich3&4  Set to branch unequal
 1212          B    found2
     *
     * Found a digit preceded by an operator or punctuation in oppun
     *
 1216found3    BCE  decmal,3&X1,.  3&x1 = before
 1224          MCW  after,*&8
 1231          BCE  backsp,athrur,0  ?A-I!J-R ?
 1239          chain19
 1258          BCE  testif,3&X1,)
 1266mark      SW   3&X1  WM above field
 1270          MCW  sx1,x3
 1277          LCA  0&X3,0&X2  Move up stuff above field
 1284          SBR  x2
 1288          MCW  kless,3&X1
 1295          SBR  tless&6,3&X1
 1302          CW   1&X2
 1306          LCA  kunder,0&X2  Mark top of constant
 1313          SBR  x2
 1317          CW   1&X2
 1321          CW   flag
 1325          S    exp
 1329          S    sigwid
 1333          S    nlz
 1337          MCW  sw,swnop
 1344          MCW  nop,asn2
 1351          MCW  branch,swich2
 1358          SBR  man&3,add
 1365          SBR  msn&3,sub
 1372          SBR  x1,2&X1
 1379zscan     MCW  0&X1,at
 1386          SAR  x1
 1390asn2      NOP  kp1,exp  add, sub or nop
 1397          A    kp1,nlz
 1404swich2    BCE  zscan,at,0
 1412          BCE  msn,at,.
 1420          BCE  man,swich2,B
 1428          A    kp1,sigwid
 1435tstasg    BCE  kleft,at,#  constant on left side of equal sign
 1443          BCE  *&9,at,@    originally slash in input?
 1451          BWZ  zscan,at,2
 1459          C    man&3,anop
 1466          BU   gotik
 1471          BWZ  *&8,exp,B
 1479          A    kp1,exp
 1486          SW   2&X1
 1490          BCE  dec2,2&X1,.
 1498decbak    BCE  gotexp,at,E
 1506expbak    C    nlz,kp01
 1513          NOP  syntax
 1517          NOP
 1518          C    sigwid,kpz3
 1525          BU   gotfpk
 1530synbak    LCA  k15k,0&X2
 1537          SBR  x2
 1541          CW   1&X2
 1545          B    tlessx
     *
     * Found a floating-point constant
     *
 1549gotfpk    MCW  x1,sx1a
 1556          BW   *&8,flag
 1564          LCA  0&X3,1&X3
 1571          MCW  sx1b,x1
 1578          MCW  mantis,width
 1585          A    kp2,width
 1592          SBR  x3,198
 1599          SW   200
 1603floop     MCW  0&X1,at  Use the
 1610          SAR  x1         print area
 1614          MCW  at,2&X3      to reverse
 1621          SBR  x3             the constant
 1625          BW   finfk,1&X1       to correct
 1633          S    kp1,width          order
 1640          C    width,kp00
 1647          BU   floop
 1652finfk     SBR  x3,1&X3  Finished with floating point constant
 1659skip0     BCE  *&5,0&X3,0
 1667          B    not0
 1671          MN   0&X3
 1675          SAR  x3
 1679          B    skip0
 1683not0      MN   0&X3
 1687          SAR  x3
 1691          MCW  exp,3&X3   Move exponent
 1698          MZ   add2,1&X3  Zone for mantissa
 1705          LCA  3&X3,0&X2
 1712          SBR  x2
 1716          B    kfin
     *
     * Constant on left side of equal sign
     *
 1720kleft     CS   332
 1724          CS
 1725          SW   glober
 1729          MN   seqcod,256
 1736          MN
 1737          MN
 1738          MCW  klm1
 1742          MCW  klm2
 1746          W
 1747          BCV  *&5
 1752          B    *&3
 1756          CC   1
 1758          MCW  sx2,x2
 1765          MCW  kb1,0&X2
 1772          C    0&X1
 1776          SAR  x1
 1780          B    loop
     *
     * Syntax error for constant
     *
 1784syntax    CS   332
 1788          CS
 1789          SW   glober
 1793          MN   seqcod,241
 1800          MN
 1801          MN
 1802          MCW  err44
 1806          W
 1807          BCV  *&5
 1812          B    *&3
 1816          CC   1
 1818          B    synbak
     *
 1822dec2      MCW  k0,2&X1
 1829          SW   flag
 1833          B    decbak
     *
     * Floating-point exponent
     *
 1837gotexp    ZA   pze,theexp
 1844          BWZ  expns,0&X1,2
 1852          MZ   0&X1,theexp  Exponent is signed
 1859          SAR  x1
 1863expns     MN   0&X1
 1867          SAR  x1
 1871          C    0&X1,z
 1878          BL   exp2
 1883          MN   1&X1,theexp
 1890          B    exp3
 1894exp2      MN   1&X1,theexp-1
 1901          MN   0&X1,theexp
 1908          SAR  x1
 1912exp3      A    theexp,exp
 1919          MN   0&X1
 1923          SAR  x1
 1927          B    expbak
     *
     * Found integer constant
     *
 1931gotik     C    sigwid,kpz3
 1938          BU   i2
 1943          LCA  kb0,0&X2  zero constant
 1950          SBR  x2
 1954          CW   1&X2
 1958          B    tlessx
 1962i2        MCW  x1,sx1a
 1969          MCW  sx1b,x3
 1976          SW   0&X3
 1980          SBR  x3,299
 1987          MCW  imod,width
 1994iloop     MCW  2&X1,at  Move up
 2001          SAR  x1         constant,
 2005          MCW  at,0&X3      reversing digits
 2012          SBR  x3             to correct
 2016          BW   finik,1&X1       order
 2024          S    kp1,width
 2031          C    width,kp00
 2038swich3    BU   iloop
 2043finik     SW   1&X3  Finished with integer constant
 2047          LCA  299,0&X2
 2054          SBR  x2
 2058          CW   1&X3
 2062          C    sigwid,kp001
 2069          BU   kfin
 2074          CW   1&X2
 2078          LCA  kb1a,0&X2
 2085          SBR  x2
 2089kfin      CW   1&X2  Finished with integer or FP constant
 2093          MCW  sx1a,x1
 2100tlessx    SBR  x1,1&X1
 2107          SBR  sx1
 2111tless     BCE  found2,0-0,<
     *
     * Program is too big
     *
 2119          CS   332
 2123          CS
 2124          CC   1
 2126          MCW  error2,270
 2133          W
 2134          CC   1
 2136          BCE  halt,cdovly,1
 2144          RWD  1
 2149halt      H    halt
     *
     * Done
     *
 2153done      BSS  snapsh,C
 2158          SBR  loadxx&3,849
 2165          SBR  clearl&3,gmwm
 2172          LCA  const2,phasid
 2179          B    loadnx
     *
     * Check for IF statement
     *
 2183testif    BCE  endstm,seqcod-3,E  IF statement?
 2191          B    mark
     *
     * End of statement.  Move it up
     *
 2195endstm    MCW  sx1,x3
 2202          LCA  0&X3,0&X2
 2209          SAR  x3
 2213          C    0&X2
 2217          SAR  x2
 2221          MCW  x3,x1
 2228          B    loop
     *
     * FP constant beginning with a decimal point
     *
 2232decmal    SBR  x1,1&X1
 2239          B    mark
     *
     * Decimal point
     *
 2243msn       MCW  sub2,asn2  move sub or nop
 2250          MCW  anop,man&3
 2257          MCW  x1,x3
 2264swnop     SW   flag  either sw or nop 
 2268          B    zscan
     *
 2272man       MCW  add2,asn2  move add or nop
 2279          MCW  anop,msn&3
 2286          MCW  nop,swich2
 2293          SBR  sx1b,1&X1
 2300          MCW  nop,swnop
 2307          B    tstasg
     *
     * Data
     *
     codtab    equ  *&1
 2340          DCW  @R 2E 2D#1L,15,0U,1P,16,01,13,1@
 2341add       A
 2342sub       S
 2345anop      DSA  nop
 2346after     DCW  #1    char after digit
 2347at        DCW  #1    digit
 2348before    dcw  #1    char before digit  
 2349gm        DC   @}@   gm
 2353seqcod    DCW  #4    statement code, sequence number
 2363prefix    DCW  #10   Entire statement prefix
 2366sx1       DCW  #3
 2369sx2       DCW  #3
 2379codes     DCW  @UPL3165DER@  I/O, DO, IF, Arith codes
 2381puncnt    DCW  #2
 2382k1        dcw  1
 2393oppun     DCW  @)}@.#%$,*-&@  Operators and punctuation
 2394branch    B
 2395nop       NOP
 2396uneq      dcw  @/@  D-modifier for unequal branch
 2416athrur    DCW  @?ABCDEFGHI!JKLMNOPQR@
 2417kless     DCW  @<@
 2418kunder    DCW  @_@
 2420exp       DCW  #2
 2423sigwid    DCW  #3  Significant width of constant
 2424sw        SW
 2425kp1       dcw  &1
 2428nlz       DCW  #3  Number of leading zeros
 2430kp01      DCW  &01
 2433kpz3      DCW  &000
 2436k15k      DSA  15000
 2439sx1a      DCW  #3
 2442sx1b      DCW  #3
 2444width     DCW  #2  mantis or imod
 2445kp2       dcw  &2
 2447kp00      DCW  &00
 2448add2      A
 2470klm1      DCW  @EQUAL SIGN, STATEMENT @
 2503klm2      DCW  @ERROR 41 - CONSTANT LEFT SIDE OF @
 2504kb1       DCW  #1
 2542err44     DCW  @ERROR 44 - CONSTANT SYNTAX, STATEMENT @
 2543k0        DCW  0
 2544flag      DCW  #1
 2545pze       dcw  &0
 2547theexp    DCW  #2
 2548z         dcw  @Z@
 2550kb0       DCW  @ 0@
 2553kp001     dcw  &001
 2554kb1a      DCW  #1
 2590error2    DCW  @MESSAGE 2 - OBJECT PROGRAM TOO LARGE@
 2599const2    DCW  @CONST TWO@
 2600sub2      S
 2601gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
