               JOB  Fortran compiler -- Equivalence phase two -- 11
               CTL  6611
     *
     * The dimension table is altered to show the relationship
     * between arrays.  The procedure, essentially, is to make
     * every array whose first element is equivalent to a secondary
     * element of another array know the distance to the first
     * element of the latter array.
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
     tpread    equ  780  Tape read instruction in overlay loader
     loadxx    equ  793  Exit from overlay loader
     clrbot    equ  833  Bottom of core to clear in overlay loader
     *
     * Stuff in the previous overlay
     *
     gm        equ  839   Group mark, in previous phase
     prefix    equ  849
     next      equ  852   One below next slot in array table
     off1      equ  857   Offset work area
     class1    equ  860   Equivalence class link
     off2      equ  865   Offset work area
     class2    equ  868   Equivalence class link
     off3      equ  873   Offset work area
     next3     equ  876   Equivalence class link
     syntax    equ  883   Syntax error routine
     nxstmt    equ  1115  Process the next statement
     gotlp     equ  1158  Get to next variable in statement
     nxtvar    equ  1165  Process next variable
     *
     110       dcw  @equiv two@
     *
     * This phase actually starts at NXSTMT in the previous overlay.
     * Here x1 points one below the bottom character of a variable in
     * a statement and x2 points at the topmost character of the name
     * of the corresponding variable in the array table.
     *
     * Each element of the array table has one or two variable-width
     * dimension fields (first dimension higher in core), with the
     * digits of the dimensions not reversed, a five digit offset
     * from the base of the equivalence class, a three-character link
     * to the base member of the equivalence class, a three-character
     * link to the next element, a three-character link to the
     * previous element, the name (variable width), and a group mark
     * with a word mark.  The GMWM of the topmost element is at
     * topcor-3, and topcor-2 .. topcor are blank.
     *
     * The next and prev pointers are redirected so that elements of
     * an equivalence class are consecutive, and ascending order by
     * offset.
     *
     * Below the array table, build a table of classes, each element
     * having a five-digit offset and a link to the first element of
     * the class in the array table.
     *
     * At exit, X3 is one below the GM at the bottom of the array
     * table, and X1 is the top (prefix) of the first statement
     * after (below) the last equivalence.
     *
     * Come here from FIND routine in previous phase when it finds
     * the variable in the array table.
     *
               ORG  1181
     loaddd    equ  *&1          Load address
 1181          LCA  kz5,off2
 1188          NOP  0&X2
 1192          MCW             Skip name
 1193          MCW             Skip "next" pointer
 1194          MCW             Skip "prev" pointer
 1195          MCW             Skip "class" pointer
 1196          SAR  x2         X2 now points at 5-digit offset
 1200          BAV  *&1        Turn off arithmetic overflow flag
 1205          S    w3
 1209more      BCE  new,1&X2,  Offset empty?
 1217          A    0&X2,off2   
 1224          MCW  3&X2,x2    Next element in equivalence class
 1231          A    kp1,w3     Count elements in class
 1238          BAV  fixit      Error if overflow -- circular list?
 1243          B    more
 1247new       MCW  x2,class2
 1254          BCE  subs,0&X1,%  Variable in equivalence subscripted?
 1262          A    k1,off2    Bump offset
 1269totop     MCW  next3,x3   Top of class table
 1276          LCA  off1,off3
 1283          S    off2,off3
 1290          BM   neg,off3   off2 .lt. off1?
 1298          LCA  class2,0&X3
 1305          SBR  next3
 1309getnxt    BCE  nxtvar,0&X1,,
 1317          BCE  eqvfin,0&X1,)  Equivalence group done
 1325          B    syntax
 1329eqvfin    MN   0&X1       Skip right paren
 1333          MN              Skip comma if statement not ended
 1334          SAR  savx1      Left paren if statement not ended
 1338          MCW  next3,x3
 1345          LCA  dollar,0&X3  Mark bottom of class table
     *
     * Search the class table for the link to the class in CLASS1
     *
 1352          MCW  next,x3      Top of class table
 1359tstbot    BCE  atbot,0&X3,$  At bottom of class table?
 1367          MCW  0&X3,wnext
 1374          C    class1,wnext
 1381          BE   testri    It's either redundant or illegal
 1386backri    MCW  0&X3,x2
 1393          SAR  next3
 1397          BCE  empty,0&X2,
 1405          B    full       Entry has an offset
 1409empty     MCW  9&X2,x1    Prev to x1
 1416emptyl    MCW  6&X2,x3    Next from x3 is x3
 1423          BCE  endtab,x3,  At end of array table?
 1431          BCE  endtab,1&X3,
 1439          SBR  x2         Next to x2
 1443          B    emptyl
 1447endtab    BCE  endtb2,x3,  At end of array table?
 1455          MCW  x1,9&X3    
 1462endtb2    BCE  noprev,x1,   No prev link?
 1470          MCW  x3,6&X1
 1477endtb3    MCW  class1,x1
 1484          MCW  6&X1,6&X2
 1491          MCW  6&X1,x3
 1498          MCW  x2,9&X3
 1505          MCW  next3,x3
 1512          MCW  3&X3,x2
 1519          MCW  x2,6&X1
 1526          MCW  x1,9&X2
 1533          MCW  class1,3&X2
 1540          MCW
 1541          S    0&X3,0&X2
 1548          SAR  x3
 1552          BW   tstbot,flag
 1560          SW   flag
 1564          C    0&X2,woff
 1571          BE   red1
 1576          B    illegl
 1580          B    tstbot
     *
     * Redundant equivalence
     *
 1584red1      B    redund
 1588          B    tstbot
     *
     * Variable in equivalence has subscript
     *
 1592subs      MN   877
 1596          MN
 1597          SAR  x3         Why not SBR x3,next3-1?
 1601          SBR  x1,0&X1
     *
     * Move subscript, in forward order, to class table
     *
 1608subsl     MCW  0&X1,chtest
 1615          SAR  x1
 1619          BCE  subsx,chtest,)
 1627          MCW  chtest,2&X3
 1634          SBR  x3
 1638          B    subsl
     *
 1642subsx     A    1&X3,off2
 1649          B    totop
     *
 1653neg       BCE  first,off1,  still empty?
 1661          LCA  class1,0&X3
 1668          SBR  next3
 1672first     MCW  class2,class1  Current one has least offset
 1679          B    getnxt
     *
     * At bottom of class table
     *
 1683atbot     MCW  savx1,x1
 1690          LCA  eoff,off1  Empty offset to off1
 1697          MCW  next,next3
 1704          BCE  gotlp,1&X1,,
 1712          BCE  nxstmt,1&X1,}
 1720          B    syntax
     *
 1724noprev    MCW  x3,86
 1731          B    endtb3
     *
     * Code in previous overlay comes here when equivalence statements
     * have all been processed
     *
 1735done2     MCW  next,x3
 1742          MCW  gm,1&X3    Mark bottom of array table
 1749          MCM  5&X1
 1753          MN
 1754          MN
 1755          SAR  x1         Top of statement after last equivalence
 1759          BSS  snapsh,C
 1764          SBR  tpread&6,838
 1771          SBR  clrbot
 1775          SBR  loadxx&3,838
 1782          SBR  clearl&3,gmwm
 1789          LCA  dim2,phasid
 1796          B    loadnx
     *
     * Code in previous overlay comes here for variables in the
     * EQUIVALENCE statement that are not in the table
     *
 1800notin2    BCE  gotrp,0&X1,)
 1808          SBR  x1
 1812          B    notin2
 1816gotrp     MN   0&X1
 1820          SAR  x1
 1824          B    nxtvar
     *
     * Test for redundant or illegal equivalence
     *
 1828testri    MCW  0&X3,x2
 1835          SAR  x2
 1839          C    0&X2,off1
 1846          BE   red2
 1851          B    illegl
 1855          B    backri
 1859red2      B    redund
 1863          B    backri
     *
     * Illegal equivalence
     *
 1867illegl    SBR  novfl1&3
 1871          CS   332
 1875          CS
 1876          SW   glober
 1880          MN   prefix,244
 1887          MN
 1888          MN
 1889          MCW  error7
 1893          W
 1894          BCV  ovfl1
 1899          B    novfl1
 1903ovfl1     CC   1
 1905novfl1    B    0
     *
     * Redundant equivalence
     *
 1909redund    SBR  novfl2&3
 1913          CS   332
 1917          CS
 1918          SW   glober
 1922          MN   prefix,246
 1929          MN
 1930          MN
 1931          MCW  error8
 1935          W
 1936          BCV  ovfl2
 1941          B    novfl2
 1945ovfl2     CC   1
 1947novfl2    B    0
     *
     * Print "Correct errors and rerun" message and stop
     *
 1951fixit     CC   L
 1953          CS   332
 1957          CS
 1958          MCW  fixmsg,270
 1965          W
 1966          CC   1
 1968halt      H    halt
     *
     * Offset has a value
     *
 1972full      MCW  0&X2,woff
 1979          CW   flag
 1983          B    empty
     *
     * Data
     *
 1991kz5       DCW  @00000@
 1994w3        DCW  #3
 1995kp1       dcw  &1
 1996k1        dcw  1
 1999savx1     DCW  #3
 2000dollar    DCW  @$@
 2003wnext     DCW  #3
 2004chtest    DCW  #1
 2009eoff      DCW  #5
 2018dim2      DCW  @DIMEN TWO@
 2059error7    DCW  @ERROR 7 - ILLEGAL EQUIVALENCE, STATEMENT @
 2102error8    DCW  @ERROR 8 - REDUNDANT EQUIVALENCE, STATEMENT @
 2138fixmsg    DCW  @CORRECT ERRORS INDICATED AND RESTART@
 2143woff      DCW  #5  Offset work area
 2144flag      DCW  #1
 2145gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   nxstmt
               END
