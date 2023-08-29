               JOB  Fortran compiler -- Variables Phase 4 -- 16
               CTL  6611
     *
     * The compiler first scans input-output lists and the left
     * side of equal signs for simple variables.  Each unique
     * variable is placed in a table with its object-time address.
     * In the second scan of this phase, all variables are matched
     * against the table.  When an entry is found, the object-time
     * address is substituted in the statement for the variable
     * name.  Variable names not present in the table are undefined.
     *
     * On entry, 83 is topcor-2, x1 is the prefix of the first
     * (topmost) statement, x2 is x1&1, topcd9 (840) is top of
     * code & x00 - 1, diff (845) is topcor-1 - topcd9, and
     * bndry (848) is topcd9 + 0.3 * diff
     *
     * On exit, topcor is the top of the scalar symbols table,
     * 83 is the bottom, 86 is the code size, and x1 is the top of
     * the transformed code
     *
     * Each element of the scalar symbols table consists of the
     * three-character run-time address, with a word mark under
     * the first character, a group mark, with a word mark under
     * it if the variable is not referenced, and the variable, with
     * characters reversed.
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
     imod      equ  690  Integer modulus -- number of digits
     mantis    equ  692  Floating point mantissa digits
     clearl    equ  707  CS at start of overlay loader
     cdovly    equ  769  1 if running from cards, N if from tape
     topcd9    equ  840  Top of code & x00 - 1 is hash table base
     diff      equ  845  diff = topcor-1 - topcd9 is 10*(size of hash)
     bndry     equ  848  Top of hash table
     codsiz    equ  853  Code size, 84-86, in decimal
     topcod    equ  856  Top of code & 1 on entry
     *
     110       dcw  @varbl quad@
     *
               ORG  857
     loaddd    equ  *&1          Load address
  857beginn    MCW  topcd9,gettop&3
  864          MZ   x1tag,gettop&2  x1 zone tag
  871          SW   gm
  875          CW   flag
  879loop1     BCE  bottom,0&X1,  bottom (end) of the code?
  887          MCW  0&X1,seqcod
  894          LCA  0&X1,prefix
  901          SAR  x1  X1 and X3 are now one below the
  905          SBR  x3    GM that separates prefix from body
  909          LCA  prefix,0&X2  Move up prefix
  916          SBR  x2
  920          BCE  skipit,seqcod-3,/  End statement?
  928          BCE  skipit,seqcod-3,F  Format statement?
  936          MCW  k01,w2
  943swread    B    testrd
  947fndvar    BCE  gotvar,0&X1,_  Variable name follows?
  955          chain5
  960          BCE  skipit,0&X1,}  Bottom of statement (GM)?
  968          chain5
  973          SBR  x1
  977          B    fndvar
     *
     * X1 got to within six of a variable name.  Get down to
     * it exactly.
     *
  981gotvar    BCE  gotvr2,0&X1,_
  989          SBR  x1
  993          B    gotvar
  997gotvr2    SW   1&X1         one above the underscore
 1001          CW
 1002          CW
 1003          CW
 1004          SAR  x1
 1008          BCE  topasg,4&X1,}  At top (lhs) of asg stmt if GM
 1016          LCA  0&X3,0&X2    Move up
 1023          SBR  x2
 1027          CW   1&X2
 1031topasg    SBR  x3,2&X1      Top of variable
     *
     * Get down to punctuation
     *
 1038punlp     MCW  0&X1,ch
 1045          SAR  x1
 1049          MCW  ch,*&8
 1056          BCE  gotpun,punct,0
 1064          chain7
 1071          B    punlp
 1075gotpun    BCE  asgrhs,ch,#    
 1083          BCE  brack,2&X1,]
 1091          B    nobrak
 1095brack     SW   flag
 1099nobrak    NOP  notrd       Branch if not definition
 1103afbrak    SW   2&X1
 1107          ZA   0&X3,w4     Hashing?
 1114          A    4&X1,w4
 1121          MZ   kbnz3,w4
 1128          MZ
 1129          MZ
 1130          MCW
 1131pos       S    diff-1,w4   Subtract diff/10
 1138          BWZ  pos,w4,B      until it's negative
 1146          A    diff-1,w4   Now add back diff/10
 1153          MZ   knz,w4
 1160          MCW  x2,sx1x2
 1167          MCW
 1168          MCW  w4,x1       Triple
 1175          A    x1            w4
 1179          A    w4,x1           to x1
 1186gettop    NOP  0-0         topcd9 with x1 zone tag stored here
 1190          SAR  x1          topcd9 & 3 * w4 ro x1
 1194          MCW  nop,swbig   Turn off ,been around hash' flag
     *
     * Not in hash table yet if blank, else check symbol
     *
 1201swun      BCE  enter,0&X1,   switches to bce undef....
 1209          BCE  swbig,0&X1,<
 1217          MCW  0&X1,x2    get symbol table entry address
 1224          SAR  x1
 1228          C    0&X3,0&X2  compare symbol to table
 1235          BU   swun
 1240          C    0&X2,0&X3
 1247          SAR  cwsw&3
 1251          BU   swun
     *
     * Found symbol in symbol table
     *
 1256cwsw      MN   0          CW in pass 2 to say *referenced*
 1260          SAR  getadr&3
 1264rex1x2    MCW  sx1x2,x2   Memorize x1 and x2
 1271          MCW
 1272getadr    LCA  0,0&X2     Addr from sym tab replaces sym in code
 1279          SBR  x2
 1283          CW   1&X2
 1287          SBR  x3,1&X1
 1294          SBR  x1
 1298getsw     B    getpun
     *
     * Enter variable in hash table and symbol table
     *
 1302enter     MCW  83,x2     Bottom of symbol table to X2
 1309          MCW  83,0&X1     and hash table
 1316          MCW  0&X3,0&X2   Symbol to symbol table
 1323          SBR  x2
 1327          BCE  toobig,0&X2,<
 1335          chain4
     *
     * Check type of variable
     *
 1339          SW   0&X3      At first character of variable
 1343          MCW  0&X3,*&8
 1350          BCE  intvar,ijklmn,0
 1358          chain5
     *
     * Floating-point variable
     *
 1363          MZ   abzone,typtag  Floating point type tag
 1370          BW   setbrk,flag
 1378          A    mantis,codsiz
 1385var       C    codsiz,kp16k   Compare codsiz to 16k
 1392          BH   oksize
 1397          BW   oksize,sizflg  Printed message already?
 1405          CS   332
 1409          CS
 1410          MCW  err2a,270
 1417          W
 1418          SW   glober,sizflg     Dont print message twice
     *
     * Convert codsiz to machine address
     *
 1425oksize    MCW  codsiz,w5
 1432          MCW  x3,sx2x3
 1439          MCW
 1440          MN   w5,86
 1447          MN
 1448          MN
 1449          SAR  *&4            Why not just w5-3 in next A field?
 1453          MCW  0,x2           Thousands to x2
 1460          MCW  kz1              and a zero
 1464          A    x2             double it
 1468          MZ   zones&1&X2,86
 1475          CW
 1476          SBR  *&7            Why not just 84 in next B field?
 1480          MZ   zones&X2,0
 1487          MCW  86,w3
 1494brkset    CW   0&X3
 1498          CS   299
 1502          MN   201
 1506          MN
 1507          SAR  x2             Why not just SBR x2,199?
 1511          SBR  x3,0&X3        Why?
 1518mvlp      MCW  0&X3,ch2       Move
 1525          SAR  x3               variable to
 1529          MCW  ch2,2&X2           201... while
 1536          SBR  x2                   reversing to
 1540          BW   *&5,1&x3               correct order
 1548          B    mvlp
 1552          MCW  sx2x3,x3
 1559          MCW
 1560          MCW  86,227
 1567          MCS  codsiz,219
 1574          BW   novfl1,flag
 1582          W
 1583          BCV  *&5
 1588          B    *&3
 1592          CC   1
 1594novfl1    SW   1&X2           WM below variable in symbol table
 1598          LCA  gm               and GMWM below that
 1602          SBR  getadr&3       Store symbol table address
 1606          LCA  w3             Store variable address in sym tab
 1610          SBR  83             Store bottom of symbol table
 1614          SBR  x2               and in x2
 1618          BCE  *&5,seqcod-3,D  Do statement?
 1626          B    *&5
 1630          CW   4&X2           Mark it referenced
 1634          MZ   typtag,2&X2    Move type tag to symbol table
 1641          CW   flag
 1645          B    rex1x2
     *
 1649setbrk    MCW  w2,w3
 1656          MCW  kbrack
 1660          A    kp1,w2
 1667          B    brkset
     *
     * Test for a read statement (which defines variables)
     *
 1671testrd    BCE  rdstmt,seqcod-3,1  read tape statement?
 1679          BCE  rdstmt,seqcod-3,5  read input tape statement?
 1687          BCE  rdstmt,seqcod-3,L  read statement?
 1695          MCW  branch,nobrak
 1702          MCW  nop,swpar
 1709          MCW  nop,asgrhs
 1716          MCW  nop,swdolr
     *
     * Get X1 down to underscore (variable) ), $ (subscript) or GM
     *
 1723getpun    BCE  gotvr2,0&X1,_  Variable?
 1731swpar     NOP  unbrak,0&X1,)  NOP if not definition
 1739swdolr    NOP  sub,0&X1,$     Subscript  NOP if not definition
 1747gmtest    BCE  skipit,0&X1,}
 1755          SBR  x1
 1759          B    getpun
     *
     * Read (input) (tape) statement
     *
 1763rdstmt    MCW  nop,nobrak
 1770          MCW  branch,swpar
 1777          MCW  move,asgrhs
 1784          MCW  branch,swdolr
 1791          B    getpun
     *
 1795unbrak    MCW  nop,nobrak
 1802          B    gmtest
 1806asgrhs    NOP  branch,swpar  NOP if not definition
 1813          MCW  branch,nobrak
 1820          B    afbrak
     *
     * Undefined variable
     *
 1824undef     CS   299
 1828          SW   glober
 1832          MCW  err10,230
 1839          MN   231
 1843          MN
 1844          SAR  x1
 1848          SBR  x3,0&X3
     *
     * Move the variable to the print line, reversing the text
     * back to the correct order
     *
 1855varlp     MCW  0&X3,chvar
 1862          SAR  x3
 1866          MCW  chvar,2&X1
 1873          SBR  x1
 1877          BW   varlpx,1&X3
 1885          B    varlp
 1889varlpx    MN   seqcod,255
 1896          MN
 1897          MN
 1898          MCW  stmt  @statement @
 1902          W
 1903          BCV  ovfl2
 1908          B    novfl2
 1912ovfl2     CC   1
 1914novfl2    SBR  getadr&3,kz3
 1921          BM   topqr,231
 1929isopqr    MZ   abzone,kz3-1  set x3 tag
 1936          B    rex1x2
     *
 1940topqr     SW   231
 1944          MCW  231,*&8
 1951          BCE  isopqr,opqr,
 1959          B
 1960          B
 1961          B
 1962          MZ   x2tag,kz3-1  set x2 tag
 1969          B    rex1x2
     *
     * Got to bottom of hash table
     *
 1973swbig     NOP  toobig        Branch if already been around
 1977          MCW  branch,swbig  Note we've been around
 1984          MCW  bndry,x1      Back to top of hash table
 1991          B    swun          Go look some more
     *
     * Subscript
     *
 1995sub       SBR  swdolr&3,sub2
 2002          MCW  branch,nobrak
 2009          B    gmtest
 2013sub2      SBR  swdolr&3,sub
 2020          MCW  nop,nobrak
 2027          B    gmtest
     *
     * Integer variable
     *
 2031intvar    MZ   bzone,typtag  Set integer variable address tag
 2038          BW   setbrk,flag
 2046          A    imod,codsiz   Increase codsiz by int var size
 2053          B    var
     *
     * Hit the bottom of the code.  Either set up for pass 2
     * or quit.
     *
 2057bottom    MCW  topcod,x1
 2064          CS   0&X2
 2068          CS
 2069          SBR  clearl&3,gmwm
 2076swdone    NOP  done
 2080          SW   gm
 2084          MCW  branch,swdone  Exit next time around
 2091          MCW  cw,cwsw
 2098          MCW  nop,swread
 2105          MCW  nop,nobrak
 2112          SBR  swun&3,undef
 2119          SBR  getsw&3,fndvar
 2126          CS   0&X2
 2130          SBR  x2,1&X1
 2137          SBR  topcod
 2141          CC   J
 2143          B    loop1  Go do pass 2
     *
     * Done
     *
 2147done      BSS  snapsh,C
 2152          MCW  varbl5,phasid
 2159          B    cdovly  Load next phase without clearing core
     *
     * Statement has no (more) variables -- skip it
     *
 2163skipit    LCA  0&X3,0&X2
 2170          SAR  x3
 2174          C    0&X2  Down to
 2178          SAR  x2      next WM in target
 2182          MCW  x3,x1
 2189          B    loop1
     *
 2193notrd     SBR  x1,1&X1
 2200          SBR  x3,1&X3
 2207          B    getpun
     *
     * Program is too big
     *
 2211toobig    CS   332
 2215          CS
 2216          CC   1
 2218          MCW  error2,270
 2225          W
 2226          CC   1
 2228          BCE  halt,cdovly,1
 2236          RWD  1
 2241halt      H    halt
     *
     * Data
     *
 2247kz3       DCW  000
 2248sizflg    dc   #1  Set when size message printed
 2250zones     DCW  @ 9@
 2281          DCW  @9Z9R9I99ZZZRZIZ9RZRRRIR9IZIRIII@
 2282x1tag     dcw  @S@
 2286seqcod    DCW  #4        Sequence number and statement code
 2296prefix    DCW  #10       Statement prefix
 2298k01       DCW  01
 2300w2        DCW  #2
 2301ch        DCW  #1
 2309punct     DCW  @@}#*-&),@
 2310flag      DCW  #1
 2314w4        DCW  #4
 2318kbnz3     DCW  #4        Used to get a blank and three "no zone"
 2319knz       DCW  #1        Used to get "no zone"
 2327sx1x2     DCW  #8        Save x1 and x2
 2328nop       NOP
 2334ijklmn    DCW  @IJKLMN@
 2335abzone    dcw  @A@       x3 tag, floating point type tag
 2336typtag    DCW  #1        Variable type tag
 2341kp16k     DCW  &16000
 2377err2a     DCW  @MESSAGE 2 - OBJECT PROGRAM TOO LARGE@
 2382w5        DCW  #5
 2390sx2x3     DCW  #8
 2391kz1       DCW  0
 2394w3        DCW  #3
 2395ch2       DCW  #1
 2396kbrack    DCW  @]@
 2397kp1       dcw  &1
 2398branch    B
 2399move      MCW
 2429err10     DCW  @ERROR 10 - UNDEFINED VARIABLE @
 2430chvar     DCW  #1  Used for reversing variable text
 2440stmt      DCW  @STATEMENT @
 2444opqr      DCW  @OPQR@
 2445x2tag     DCW  @K@
 2446bzone     DCW  @J@       Integer variable address tag
 2447cw        CW
 2456varbl5    DCW  @VARBLQUIN@
 2492error2    DCW  @MESSAGE 2 - OBJECT PROGRAM TOO LARGE@
 2493gm        dc   @}@
 2498          dc   #5
 2499gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
