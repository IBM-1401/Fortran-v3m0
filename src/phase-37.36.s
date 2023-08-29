               JOB  Fortran compiler -- Arith Phase Five -- phase 37
               CTL  6611
     *
     * IF statement exits and strings for exponentiation are created.
     *
     x1        equ  89
     x2        equ  94
     x3        equ  99
     *
     * Stuff in the resident area
     *
     phasid    equ  110  Phase ID, for snapshot dumps
     series    equ  117  Need series routine if no WM
     logf      equ  119  Saw logf if no WM
     expf      equ  120  Saw expf if no WM
     xfixf     equ  124  Saw xfixf if no WM
     floatf    equ  125  Saw floatf if no WM
     negar3    equ  157  Looks like negary -- see phase 20
     arysiz    equ  160  Total array size & 2
     glober    equ  184  Global error flag -- WM means error
     snapsh    equ  333  Core dump snapshot
     loadnx    equ  700  Load next overlay
     clearl    equ  707  CS at start of overlay loader
     *
     * Runtime addresses
     *
     aritf     equ  700
     *
     110       dcw  @arith 5@
     *
               ORG  838
     loaddd    equ  *&1          Load address
  838beginn    BCE  done,x2,.  Done?
  846          C    0&X2
  850          SAR  x2
  854          SBR  sx2
  858          C    0&X1
  862          SAR  x1
  866loop      MCW  0&X1,seqno
  873          MCW
  874          BCE  arif,code,E  if statement
  882          BCE  arif,code,R  arithmetic assignment statement
  890          B    almost
  894arif      LCA  0&X1,0&X2  move up prefix
  901          SAR  x1
  905          C    0&X2
  909          SAR  x2
  913          LCA  1&X2,2&X2  move up gmwm?
  920          SBR  x2
  924          CW   parity
  928          BCE  ifstmt,2&X1,E  if statement
     *
     * Assignment statement
     *
  936asgstm    LCA  0&X1,0&X2
  943          SAR  x1
  947          C    0&X2
  951          SAR  x2
  955          SBR  x3,0&X1
  962          SBR  sx1
  966          BCE  endstm,0&X1,}
  974getop     MN   0&X3,lookop&7
  981          MZ   0&X3,lookop&7
  988          SAR  x3
  992lookop    BCE  gotop,ops,0  &-@*.#
 1000          chain5
 1005          B    getop
 1009gotop     BCE  expon,1&X3,.  exponentialtion
 1017          MZ   4&X3,savzon  type of LHS if subscript
 1024          BCE  subs,2&X3,$
 1032          MZ   3&X3,savzon  type of LHS if no subscript
 1039outer     SBR  x3,4&X3
 1046inner     C    x3,sx1
 1053          BE   getasg
 1058          SBR  x3,1&X3
 1065          BCE  *&13,0&X3,F
 1073          BCE  *&5,0&X3,X
 1081          B    inner
 1085          BW   even,parity
 1093          SW   parity
 1097          B    inner
 1101even      CW   parity
 1105          B    inner
     *
     * Exponentiation
     *
 1109expon     SBR  sx3&6,0&X3
 1116          BCE  expon2,0&X3,$
 1124          SBR  x3
 1128exponl    MZ   0&X3,savzon
 1135sx3       SBR  x3,0
 1142          BCE  subs,2&X3,$
 1150          B    outer
 1154expon2    C    0&X3,w8
 1161          SAR  x3
 1165          BCE  exponl,0&X3,$
 1173          B
 1174          B
 1175          C    0&X3,w6
 1182          SAR  x3
 1186          B    exponl
     *
     * Subscript -- skip it
     *
 1190subs      SBR  x3,12&X3
 1197          BCE  inner,0&X3,$
 1205          SBR  x3,6&X3
 1212          B    inner
     *
     * Get down to assignment operator
     *
 1216getasg    BCE  gotasg,0&X3,#
 1224          SBR  x3
 1228          B    getasg
 1232gotasg    MCW  0&X3,w18a
 1239          BCE  sublft,2717,$  subscript before equal
 1247          MZ   w18a-2,lstype  type tag for LHS
 1254sblbak    BWZ  lfix,lstype,S  back here after subscript
 1262          BWZ  lfix,lstype,K
 1270          BWZ  lfrf,savzon,2
 1278          BWZ  lfrf,savzon,B
 1286          BW   endexp,parity  left float right fixed
 1294lfrx      MCW  fcode,0&X2
 1301          SBR  x2
 1305          CW   1&X2,floatf    need floatf
 1312          B    endexp
 1316lfrf      BW   lfrx,parity    left float right float
 1324          B    endexp
 1328lxrx      BW   lxrf,parity    left fix right fix
 1336          B    endexp
 1340lfix      BWZ  lxrx,savzon,S  left side is fixed point
 1348          BM   lxrx,savzon
 1356          BW   endexp,parity
 1364lxrf      MCW  xcode,0&X2     left fix right float
 1371          SBR  x2
 1375          CW   1&X2,xfixf     need xfixf
 1382endexp    SBR  x3,0&X1
 1389endex2    BCE  expon3,0&X1,.  Exponentiation
 1397          BCE  divop,0&X1,@
 1405          BCE  endstm,0&X1,}
 1413          SBR  x1
 1417          B    endex2
     *
     * End of IF or assignment statement
     *
 1421endstm    LCA  0&X3,0&X2
 1428          SAR  x3
 1432          C    0&X2
 1436          SAR  x2
 1440          BCE  finstm,1&X3,}
 1448          B    endstm
 1452finstm    SBR  x1,0&X3
 1459          B    loop
     *
     * Divide operator -- turn it back to slash
     *
 1463divop     MCW  slash,0&X1
 1470          SBR  x1
 1474          B    1389
     *
     * Almost done
     *
 1478almost    SBR  x1,5&X1
 1485          MCW  sx2,x3
 1492          SBR  x3,2&X3
     *
 1499done      BSS  snapsh,C
 1504          SBR  clearl&3,gmwm
 1511          LCA  arith6,phasid
 1518          B    loadnx
     *
     * IF statement
     *
 1522ifstmt    C    0&X1
 1526          SAR  x1
 1530          MCW  9&X1,labneg  negative branch
 1537          MCW  6&X1,labzro  zero branch
 1544          MCW  3&X1,labpos  positive branch
 1551          MZ   x2zone,labneg-1
 1558          MZ   x2zone,labzro-1
 1565          MZ   x2zone,labpos-1
 1572          MCW  labpos,uncond
 1579          LCA  kb20,w20
 1586          SBR  x3,recmrk
 1593          C    labpos,labzro
 1600          BE   poszro  positive and zero the same label
 1605          C    labzro,labneg
 1612          BE   zeqneg  negative and zero the same label
 1617          SBR  x3,8&X3
 1624          MCW  brzero
 1628          MCW
 1629          LCA
 1630          C    labpos,labneg
 1637          BE   posneg  positive and negative the same label
 1642zeqneg    SBR  x3,8&X3
 1649          MCW  brpos
 1653          MCW
 1654          LCA
 1655          MCW  labneg,uncond
 1662posneg    MCW  x3,sx1
 1669          BWZ  *&5,seqno,2
 1677          B    *&9
 1681          BWZ  *&15,seqno-2,2
 1689          MCW  seqno,x3  address of sequence number if zones
 1696          MCW  0&X3,seqno
 1703          A    kp1,seqno
 1710          MCW  uncond,x3
 1717          C    0&X3,seqno
 1724          MCW  sx1,x3
 1731          BE   moveup
 1736posn2     SBR  x3,4&X3
 1743          MCW  uncond
 1747          LCA
 1748moveup    LCA  0&X3,0&X2  move up generated code
 1755          SAR  x3
 1759          C    0&X2
 1763          SAR  x2
 1767          BCE  asgstm,0&X3,|
 1775          B    moveup
 1779poszro    C    labpos,labneg
 1786          BE   posn2  all the same label
 1791          SBR  x3,8&X3
 1798          MCW  brneg
 1802          MCW
 1803          LCA
 1804          B    posneg
     *
     * Exponentiation operator
     *
 1808expon3    SW   1&X1
 1812          BCE  esubr,1&X1,$
 1820          LCA  3&X1,w17a
 1827          MZ   2&X1,exprt
 1834          SBR  sx1p3,3&X1
 1841          C    sx1p3,x3
 1848          BE   expon5
 1853          SW   4&X1
 1857expon4    LCA  0&X3,0&X2
 1864          SAR  x3
 1868          C    0&X2
 1872          SAR  x2
 1876          CW   1&X2
 1880expon5    C    0&X1,kb4
 1887          SAR  x1
 1891          BCE  esubl,3&X1,$
 1899          MZ   2&X1,explt
 1906          SW   1&X1
 1910expon6    LCA  3&X1,w17b
 1917          SAR  x1
 1921          BWZ  erx,exprt,S
 1929          BWZ  erx,exprt,K
 1937          CW   logf,expf  need logf and expf
 1944          CW   series       and series
 1948          BWZ  erflf,explt,2
 1956          BWZ  erflf,explt,B
 1964          BWZ  *&5,seqno,2
 1972          B    *&9
 1976          BWZ  msg30,seqno-2,2  sequence number if no zones
 1984          MCW  seqno,x3  address of sequence number
 1991          MCW  0&X3,seqno
 1998msg30     CS   332
 2002          CS
 2003          SW   glober
 2007          MN   seqno,244
 2014          MN
 2015          MN
 2016          MCW  err30
 2020          W
 2021          BCV  *&5
 2026          B    *&3
 2030          CC   1
 2032erflf     LCA  ecode,0&X2  both operands float
 2039          LCA  w17a
 2043          LCA  kgstar  G*
 2047          SBR  x2
 2051          CW   3&X2,1&X1
 2058          LCA  w17b,0&X2
 2065          SBR  x2
 2069          CW   1&X2
 2073          B    endexp
     *
     * Right operand of exponentiation is fixed point
     *
 2077erx       BWZ  getfun,exprt,K
 2085          BCE  getfun,w17a-2,<
 2093          MCW  w17a,x3
 2100          MA   arysiz,x3
 2107          C    k3,0&X3
 2114          BH   getfun
 2119          LCA  w17b,0&X2
 2126          LCA  kstar
 2130          SBR  x2
 2134          SBR  sx2b
 2138          CW   1&X2,2&X2
 2145          LCA  w17b,0&X2
 2152          SBR  x2
 2156          CW   1&X2
 2160          BCE  erx2,0&X3,0
 2168          BCE  erx3,0&X3,1
 2176          BCE  endexp,0&X3,2
 2184          LCA  kstar,0&X2
 2191          SBR  x2
 2195          CW   1&X2
 2199          LCA  w17b,0&X2
 2206          SBR  x2
 2210          CW   1&X2
 2214          B    endexp
     *
 2218erx2      MCW  sx2b,x3
 2225          MCW  slash,1&X3
 2232          B    endexp
     *
 2236erx3      MCW  sx2b,x2
 2243          SBR  x2,1&X2
 2250          B    endexp
     *
 2254getfun    CW   logf,expf  need logf and expf
 2261          CW   series,floatf
 2268          BWZ  getff1,explt,2  left is float
 2276          BWZ  getff1,explt,B  left is float
 2284          LCA  xcode,0&X2  xfixf code
 2291          SBR  x2
 2295          CW   0&X2,xfixf
 2302          LCA  negar3,0&X2
 2309          LCA  kplus
 2313          SBR  x2
 2317          CW   2&X2
 2321getff1    LCA  ecode,0&X2
 2328          LCA  kfless  F*<4?
 2332          LCA  w17a
 2336          SBR  x2
 2340          CW   1&X2
 2344          C    0&X1,kb4
 2351          SAR  x3
 2355          BCE  subfun,3&X3,$
 2363subfub    SW   1&X3
 2367          LCA  0&X1,0&X2
 2374          SAR  x1
 2378          C    0&X2
 2382          SAR  x2
 2386          CW   1&X2
 2390          LCA  kgrm  G|
 2394          SBR  x2
 2398          BWZ  getff2,explt,2  left is float
 2406          BWZ  getff2,explt,B  left is float
 2414          LCA  fcode,0&X2
 2421          SBR  x2
 2425getff2    LCA  w17b,0&X2
 2432          LCA  kl4  <4?#
 2436          SBR  x2
 2440          CW   5&X2
 2444          C    0&X1,baritf&3
 2451          BE   endexp
 2456          CW   1&X2
 2460          B    endexp
     *
 2464recmrk    DCW  @|@
 2484w20       DCW  #20
 2485          B
 2488uncond    DCW  #3
 2489          BWZ
 2492labpos    DCW  #3  positive branch from arithmetic if
 2495          dsa  277&x3
 2496brpos     dc   @B@
 2497          B
 2500labzro    DCW  #3  zero branch from arithmetic if
 2503          dsa  280
 2504brzero    dc   0
 2505          BWZ
 2508labneg    DCW  #3  negative branch from arithmetic if
 2511          dsa  277&x3
 2512brneg     dc   @K@
     *
     * Right operand of exponentiation operator is subscripted
     *
 2513esubr     MZ   3&X1,exprt
 2520          SBR  x1,11&X1
 2527          BCE  *&8,0&X1,$
 2535          SBR  x1,6&X1
 2542          C    x1,x3
 2549          BE   *&5
 2554          SW   1&X1
 2558          LCA  0&X1,w17a
 2565          SAR  x1
 2569          BE   expon5
 2574          B    expon4
     *
     * Left operand of exponentiation operator is subscripted
     *
 2578esubl     C    0&X1,w8
 2585          SAR  x3
 2589          BCE  *&12,1&X3,$
 2597          C    0&X3,w6
 2604          SAR  x3
 2608          MZ   3&X3,explt
 2615          SW   1&X3
 2619          B    expon6
     *
     * Subscript after ???
     *
 2623subfun    C    0&X3,w8
 2630          SAR  x3
 2634          BCE  subfub,1&X3,$
 2642          C    0&X3,w6
 2649          SAR  x3
 2653          B    subfub
     *
     * Subscript on left of equal sign
     *
 2657sublft    MZ   w18a-9,lstype  type tag for LHS
 2664          BCE  sblbak,w18a-11,$
 2672          MZ   w18a-15,lstype  type tag for LHS
 2679          B    sblbak
     *
     * Data
     *
 2683code      DCW  #1  statement code
 2686seqno     DCW  #3  sequence number or
 2689sx2       DCW  #3
 2690parity    DCW  #1  of loop in assignment statement processing
 2693sx1       DCW  #3
 2699ops       DCW  @&-@*.#@
 2700savzon    DCW  #1
 2718w18a      DCW  #18
 2719lstype    DCW  #1  type zone for LHS
 2720fcode     DCW  @F@  fix-to-float (floatf) code
 2721xcode     DCW  @X@  float-to-fix (xfixf) code
 2722slash     dcw  @/@
 2728arith6    DCW  @ARITH6@
 2729x2zone    DCW  @K@
 2749kb20      DCW  #20
 2750kp1       dcw  &1
 2767w17a      DCW  #17
 2768exprt     DCW  #1  type tag of right operand of exponentiation
 2771sx1p3     DCW  #3
 2775kb4       DCW  #4  used in compare to decrement index
 2776explt     DCW  #1  type tag of left operand of exponentiation
 2793w17b      DCW  #17
 2834err30     DCW  @ERROR 30 - FIX TO FLOAT POWER, STATEMENT @
 2835ecode     DCW  @E@   code for exponential
 2837kgstar    DCW  @G*@  code for logarithm
 2838k3        DCW  3
 2839kstar     DCW  @*@
 2842sx2b      DCW  #3
 2843kplus     DCW  @&@
 2848kfless    DCW  @F*<4?@
 2850kgrm      DCW  @G|@
 2854kl4       DCW  @<4?#@
 2855baritf    B    aritf
 2866w8        DCW  #8  used in compare to decrement index
 2872w6        DCW  #6  used in compare to decrement index
 2873gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
