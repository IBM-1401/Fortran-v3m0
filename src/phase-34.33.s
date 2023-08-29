               JOB  Fortran compiler -- Arith Phase Two -- phase 34
               CTL  6611
     *
     * All arithmetic and IF statements are unnested using a
     * forcing table technique.  Error checking continues.
     *
     * On entry X1 is the top of the topmost non-assignment non-IF
     * statement, x2 is the top of the topmost assignment or IF
     * statement in high core, and x3 is one below the bottommost
     * assignment or IF statement in high core.
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
     110       dcw  @arith 2@
     *
               ORG  838
     loaddd    equ  *&1          Load address
  838beginn    BCE  done,x2,.
  846          SW   gm
  850          MCW  x2,sx2
  857          SBR  x3,2&X3
  864          SBR  x1,2&X1
  871          MCW  x1,x2
  878get00     MN   x2,chkx2  get x2
  885          MN               up to
  886          C    chkx2,k00     x2 & x00
  893          BE   got00
  898          CW   0&X2
  902          SBR  x2,1&X2
  909          B    get00
  913got00     MN   0&X2
  917          SAR  x2p99  x2 & x00 - 1
  921          MN   0&X3
  925          SAR  x2
  929clrl      C    x2,x2p99  clear down
  936          BE   clrx        to top
  941          CS   0&X2          of code
  945          SBR  x2              in low
  949          B    clrl              core & x00
  953clrx      MN   0&X1
  957          SAR  x1
  961more      MCM  0&X3     move code
  965          SAR  sx3&6      down from
  969          MCM  0&X3,1&X1    top core
  976          MN                  to bottom
  977          SBR  x1               of bottommost
  981sx3       SBR  x3,0               assignment
  988          BCE  more,0&X1,|          or if
  996          MN   0&X3                   statement
 1000          CW
 1001          SW   0&X1
 1005          C    x3,sx2
 1012          BU   more
 1017          MN   0&X1
 1021          SAR  x1
     *
     * X1 is now the top of the topmost assignment or if statement
     * in low core and x3 is one above the top of the topmost
     * assignment or if statement in high core.
     *
 1025          MN   0&X3
 1029          SBR  ixtop  index of statement in top core
 1033          BCE  loop,0&X3,}
 1041          SBR  x3
 1045          LCA  gm
 1049          SBR  ixtop
 1053          MCW  x3,sx2
 1060loop      MCW  ixtop,ixtsav
 1067          MCW  0&X1,x3
 1074          BWZ  *&5,x3,2  zone in ones or
 1082          B    *&9         thousands means address of
 1086          BWZ  *&8,x3-2,2    sequence number in symbol table
 1094          MCW  0&X3,x3  get sequence number from table
 1101          MCW  x3,seqno
 1108          MCW  kb12,w3b
 1115          MCW  kbrack,40&X1  right bracket
 1122          SBR  locbrk&6,40&X1  remember where we put it
 1129          B    moveup         move prefix up to high core
 1133          BCE  ifstmt,2&X1,E  If statement?
 1141          C    2&X1,kr        Assignment statement?
 1148          BU   almost         No, almost done
 1153ready     MCW  x1,x3
 1160          SBR  link&3,0&X1
 1167          C    0&X3
 1171          SAR  sx3b
 1175          B    hunt
 1179locbrk    BCE  whew,0,]  right bracket
     *
     * Bracket having been clobbered means program is too big
     *
 1187          CS   332
 1191          CS
 1192          CC   1
 1194          MCW  err2,270
 1201          W
 1202          CC   1
 1204          BCE  halt,cdovly,1
 1212          RWD  1
 1217halt      H    halt
     *
     * If statement, get x3 down to a blank below x1, then set
     * a word mark one below there
     *
 1221ifstmt    MCW  x1,x3
 1228getb      BCE  gotb,0&X3,,
 1236          SBR  x3
 1240          B    getb
 1244gotb      MN   0&X3
 1248          SW
 1249          B    moveup
 1253          B    ready
     *
     * Move up prefix or body
     *
 1257moveup    SBR  moveux&3
 1261          MCW  ixtop,x2
 1268          LCA  0&X1,0&X2
 1275          SBR  ixtop
 1279          C    0&X1
 1283          SAR  x1
 1287moveux    B    0
     *
     * Hunt for interesting characters
     *
 1291hunt      SBR  huntx&3
 1295          BCE  skpsub,0&X3,$
 1303huntl     MCW  0&X3,curr
 1310          SAR  x3
 1314          MCW  curr,*&8
 1321          BCE  huntx,chars,0
 1329          chain10
 1339          B    huntl
 1343huntx     B    0
     *
     * Skip subscript -- decrease x3 by either 12 or 18
     *
 1347skpsub    C    0&X3,kb12
 1354          SAR  x3
 1358          BCE  huntx,2&X3,$
 1366          C    0&X3,kb12-6
 1373          SAR  x3
 1377          B    huntx
     *
     * Program isn't too big
     *
 1381whew      MCW  1&X3,curr    current operator or assignment
 1388          MCW  1&X1,prev    previous operator or GM
 1395          MCW  prev,lookch&7
 1402          MCW  kb12,w3
 1409          B    look
 1413          MN   chnum,w3-1   previous chars index is tens
 1420          MCW  curr,lookch&7
 1427          B    look
 1431          MN   chnum,w3     current chars index is ones
 1438          MCW  w3,x2
 1445          MN   table&X2,x2  get one
 1452          MCW  kb12           digit from table
 1456          BWZ  msg24,x2,S
 1464          A    x2
 1468          A    x2           quadruple it
 1472          B    *&1&X2
 1476          B    zero   index from table is zero
 1480          B    one    index from table is one
 1484          B    two    index from table is two
 1488          B    three  index from table is three
 1492          B    four   index from table is four
 1496          B    five   index from table is five
 1500          B    msg25  index from table is six
 1504          B    msg16  index from table is seven
 1508          B    msg32  index from table is eight
 1512          B    msg26  index from table is nine
     *
     * Look for a character in chars, treating minus and plus
     * equally, counting as we look
     *
 1516look      SBR  lookch&3
 1520          BCE  look3,lookch&7,-
 1528look2     S    chnum  Index in chars
 1532          MCW  achars,lookch&6
 1539lookch    BCE  0,0,0
 1547          SBR  lookch&6
 1551          A    k1,chnum
 1558          B    lookch
 1562look3     MCW  kplus,lookch&7
 1569          B    look2
     *
 1573count     SBR  countx&3
 1577          A    k1,w3b
 1584          MZ   w3b-1,ch
 1591          MN   w3b,ch
 1598          MN
 1599countx    B    0
     *
     * Index from table is zero.
     * Prev *      curr %. blank
     * Prev %      curr *%&@. blank ,
     * Prev #      curr *%&@. blank ,
     * Prev GM     curr #
     * Prev &      curr *%@. blank ,
     * Prev @      curr %. blank
     * Prev .      curr % blank
     * Prev blank  curr *%&@. blank ,
     * Prev ,      curr %. blank
     *
 1603zero      MCW  x3,x1  current to previous
 1610          B    hunt   get next operator
 1614          B    whew
     *
     * Index from table is one.
     * Prev %  curr )
     *
 1618one       SW   2&X3
 1622          LCA  0&X1,1&X1
 1629          CW   3&X3
 1633          CW
 1634          LCA  0&X3,2&X3
 1641          SBR  x1,1&X1
 1648          SBR  x3,1&X3
 1655          B    whew
     *
     * Index from table is two
     * Prev *  curr *)G&@
     * Prev &  curr )G&
     * Prev @  curr *)G&@
     * Prev .  curr *)G&@
     *
 1659two       MCW  ixtop,x2
 1666          MZ   4&X3,savtag
 1673          BCE  *&8,2&X3,$
 1681          MZ   3&X3,savtag
 1688          SW   2&X3
 1692          LCA  0&X1,0&X2
 1699          SBR  x2
 1703          CW   1&X2
 1707          SW   2&X1
 1711          SW
 1712          LCA  1&X1,0&X2
 1719          SBR  x2
 1723          SBR  ixtop
 1727          CW   1&X2
 1731          BCE  subtwo,2&X1,$
 1739          LCA  4&X1,0&X2
 1746          SBR  ixtop
 1750          MZ   3&X1,tag1
 1757          SAR  x1
 1761subbak    B    count
 1765          LCA  ch,2&X1
 1772          LCA  1&X3
 1776          CW   0&X1
 1780          MN
 1781          SAR  x3
 1785          SBR  x1,2&X1
 1792          BWZ  twoa,tag1,S
 1800          BM   twoa,tag1
 1808          BWZ  locbrk,savtag,2
 1816          BWZ  locbrk,savtag,B
 1824          BCE  locbrk,prev,.
 1832          B    mixed
 1836twoa      BWZ  locbrk,savtag,S
 1844          BM   locbrk,savtag
     *
     * Mixed mode arithmetic
     *
 1852mixed     CS   332
 1856          CS
 1857          SW   glober
 1861          MN   seqno,241
 1868          MN
 1869          MN
 1870          MCW  err46
 1874          W
 1875          BCV  *&5
 1880          B    *&3
 1884          CC   1
 1886          B    errfin
     *
 1890subtwo    SBR  x2,10&X1
 1897          BCE  *&8,2&X2,$
 1905          SBR  x2,6&X2
 1912          MCW  ixtop,*&7
 1919          LCA  2&X2,0
 1926          SBR  ixtop
 1930          MZ   4&X1,tag1
 1937          MCW  x2,x1
 1944          B    subbak
     *
     * Index from table is four
     * Prev ,  curr *)G&@
     *
 1948four      MCW  kn,1&X1
 1955          MZ   4&X3,tag1
 1962          BCE  fiveb,2&X3,$
 1970          MZ   3&X3,tag1
 1977          B    fiveb
     *
     * Index from table is five
     * Prev blank  curr )
     *
 1981five      MCW  3&X1,w2
 1988          BCE  fivec,3&X1,X
 1996          MZ   *-4,tag1
 2003fivef     SW   2&X1
 2007          MCW  2&X1,*&8
 2014          BCE  usrfnc,usrcod,0
 2022          chain11
 2033          MZ   4&X3,savtag
 2040          BCE  fivea,2&X3,$
 2048          MZ   3&X3,savtag
 2055fivea     BCE  fived,2&X1,F
 2063          BCE  fived,2&X1,I
 2071          C    w2,kax
 2078          BE   fived
 2083          BWZ  msg28,savtag,S
 2091          BM   msg28,savtag
 2099usrfnc    MCW  2&X1,1&X1
 2106          MCW  klpar,2&X1
 2113          CW   2&X1
 2117fiveb     MCW  ixtop,x2
 2124          SW   2&X3
 2128          LCA  1&X1,0&X2
 2135          SBR  ixtop
 2139          B    count
 2143          LCA  ch,1&X1
 2150          LCA  1&X3
 2154          MN   0&X1
 2158          CW
 2159          MN
 2160          SAR  x3
 2164          SBR  x1,1&X1
 2171          B    locbrk
 2175fivec     MZ   fivec,tag1
 2182          LCA  2&X1,3&X1
 2189          SBR  x1,1&X1
 2196          SBR  x3,1&X3
 2203          B    fivef
 2207fived     BWZ  usrfnc,savtag,S
 2215          BM   usrfnc,savtag
     *
     * Wrong argument type for function
     *
 2223msg28     CS   332
 2227          CS
 2228          SW   glober
 2232          MN   seqno,261
 2239          MN
 2240          MN
 2241          MCW  err28
 2245          W
 2246          BCV  *&5
 2251          B    *&3
 2255          CC   1
 2257          B    errfin
     *
     * System error
     *
 2261msg24     CS   332
 2265          CS
 2266          SW   glober
 2270          MN   seqno,238
 2277          MN
 2278          MN
 2279          MCW  err24
 2283          W
 2284          BCV  *&5
 2289          B    *&3
 2293          CC   1
 2295          B    errfin
     *
     * Excess of # signs
     * Index from table is nine
     * Prev *      curr #
     * Prev #      curr #
     * Prev &      curr #
     * Prev @      curr #
     * Prev .      curr #
     * Prev blank  curr #
     * Prev ,      curr #
     *
 2299msg26     CS   332
 2303          CS
 2304          SW   glober
 2308          MN   seqno,243
 2315          MN
 2316          MN
 2317          MCW  err26
 2321          W
 2322          BCV  *&5
 2327          B    *&3
 2331          CC   1
 2333          B    errfin
     *
     * Multiple exponent
     * Index from table is eight
     * Prev .  curr .
     *
 2337msg32     CS   332
 2341          CS
 2342          SW   glober
 2346          MN   seqno,243
 2353          MN
 2354          MN
 2355          MCW  err32
 2359          W
 2360          BCV  *&5
 2365          B    *&3
 2369          CC   1
 2371          B    errfin
     *
     * Parenthesis error
     * Index from table is seven
     * Prev %      curr GM 
     * Prev #      curr )  
     * Prev blank  curr GM
     *
 2375msg16     CS   332
 2379          CS
 2380          SW   glober
 2384          MN   seqno,243
 2391          MN
 2392          MN
 2393          MCW  err16
 2397          W
 2398          BCV  *&5
 2403          B    *&3
 2407          CC   1
 2409          B    errfin
     *
     * Left side is wrong
     * Index from table is six
     * Prev GM  curr *)%&@. blank ,
     *
 2413msg25     CS   332
 2417          CS
 2418          SW   glober
 2422          MN   seqno,243
 2429          MN
 2430          MN
 2431          MCW  err25
 2435          W
 2436          BCV  *&5
 2441          B    *&3
 2445          CC   1
 2447errfin    MCW  ixtsav,ixtop
 2454          B    restrt
     *
     * Index from table is three
     * Prev #  curr G
     *
 2458three     MCW  ixtop,x2
 2465          SW   2&X3
 2469          LCA  0&X1,0&X2
 2476          LCA  keq
 2480          SBR  x2
 2484          CW   2&X2
 2488          CW
 2489          SW   2&X1
 2493link      LCA  0,0&X2
 2500          LCA  gm
 2504          SBR  ixtop
 2508restrt    MCW  sx3b,x1
 2515          B    loop
     *
 2519almost    SBR  x1,5&X1  get back above prefix in low core
 2526          MCW  ixtop,x3
 2533          SBR  x2,5&X3
 2540          MCW  sx2,x3
     *
 2547done      BSS  snapsh,C
 2552          SBR  clearl&3,gmwm
 2559          LCA  arith3,phasid
 2566          B    loadnx
     *
     * Data
     *
 2570          DCW  @<@
 2571tag1      dc   @ @
 2572ch        dc   @ @
 2573gm        dc   @}@
 2623          DCW  @ERROR 28 - INCORRECT MODE OF FUNCTION ARGUMENT, ST@
 2631err28     DC   @ATEMENT @
 2632          DCW  @-@
     *
     * Rows and columns of table are indexed by positions in
     * chars, taken in reverse order.
     *
 2642chars     DCW  @, .@&}#%)*@  interesting characters?
 2643table     equ  *&1
     *         curr  *)%#G&@. ,
 2652          DC   @220922200S@  *  prev
 2662          DC   @SSSSSSSSSS@  )
 2672          DC   @0109700000@  %
 2682          DC   @0709300000@  #
 2692          DC   @6660S66666@  GM
 2702          DC   @020922000S@  &
 2712          DC   @220922200S@  AT  was /
 2722          DC   @220922280S@  .   was **
 2732          DC   @0509700000@  blank
 2742          DC   @440944400S@  ,   was negate
 2745sx2       DCW  #3
 2747chkx2     DCW  #2
 2749k00       DCW  00
 2752x2p99     DCW  #3  x2 & x00 - 1
 2755ixtop     DCW  #3  index of statement in top core
 2758ixtsav    DCW  #3
 2761seqno     DCW  #3
 2762kbrack    DCW  @]@
 2763kr        DCW  @R@
 2766sx3b      DCW  #3
 2802err2      DCW  @MESSAGE 2 - OBJECT PROGRAM TOO LARGE@
 2814kb12      DCW  #12
 2815curr      DCW  #1
 2816prev      DCW  #1
 2819w3        DCW  #3
 2820chnum     DCW  #1
 2823achars    DSA  chars
 2824k1        dcw  1
 2825kplus     DCW  @&@
 2828w3b       DCW  #3
 2829savtag    DCW  #1  type tag zone
 2867err46     DCW  @ERROR 46 - MIXING IN ARITH, STATEMENT @
 2868kn        dcw  @N@
 2870w2        DCW  #2
 2882usrcod    DCW  @RUPWYZKJLMDH@  codes for user functions
 2884kax       DCW  @AX@
 2885klpar     dcw  @%@
 2920err24     DCW  @ERROR 24 - SYSTEM ERROR, STATEMENT @
 2960err26     DCW  @ERROR 26 - EXCESS OF # SIGNS, STATEMENT @
 3000err32     DCW  @ERROR 32 - MULTIPLE EXPONENT, STATEMENT @
 3040err16     DCW  @ERROR 16 - PARENTHESIS ERROR, STATEMENT @
 3080err25     DCW  @ERROR 25 - LEFT SIDE INVALID, STATEMENT @
 3081keq       dcw  @#@
 3090arith3    DCW  @ARITH TRI@
 3091gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
