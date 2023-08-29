               JOB  Fortran compiler -- Arith Phase One -- phase 33
               CTL  6611
     *
     * This is a housekeeping phase.  The unary minus (negate) and
     * exponentiation operators are changed to unique one-character
     * symbols (negate becomes comma, exponentiate becomes dot).
     * Error checking also takes place.
     *
     * On entry, x1 is the top of the prefix of code in low core,
     * x2 is x1&1, and x3 is two below the GM below the I/O strings,
     * formats and constants in high core.
     *
     x1        equ  89
     x2        equ  94
     x3        equ  99
     *
     * Stuff in the resident area
     *
     phasid    equ  110  Phase ID, for snapshot dumps
     series    equ  117  Need series routine if no WM
     sincos    equ  118  Saw sinf or cosf if no WM
     sawabs    equ  122  Saw absf if no WM
     sawneg    equ  123  Saw negation operator (unary minus) if no WM
     glober    equ  184  Global error flag -- WM means error
     snapsh    equ  333  Core dump snapshot
     loadnx    equ  700  Load next overlay
     clearl    equ  707  CS at start of overlay loader
     *
     110       dcw  @arith 1@
     094       dcw  000
     096       dc   00
     *
               ORG  838
     loaddd    equ  *&1          Load address
  838beginn    SBR  sx3,2&X3
  845          SW   gm
  849          MCW  0&X1,codseq
  856          BCE  expr,codseq-3,R
  864          BCE  expr,codseq-3,E
  872          MCW  dot,x2
  879          B    done
  883loop      MCW  0&X1,codseq
  890          SBR  sx3b,0&X3
  897          BCE  expr,codseq-3,R
  905          BCE  expr,codseq-3,E
  913          MCW  sx3,x2
  920done      BSS  snapsh,C
  925          SBR  clearl&3,gmwm
  932          LCA  arith2,phasid
  939          B    loadnx
     *
     * Either assignment or arithmetic if
     *
  943expr      LCA  0&X1,0&X3  move prefix up
  950          SAR  x1
  954          C    0&X3
  958          SAR  x3
  962          BWZ  *&5,codseq,2
  970          B    *&9
  974          BWZ  expr2,codseq-2,2
  982          MCW  codseq,x2
  989          MN   0&X2,codseq
  996          MN
  997          MN
  998expr2     C    0&X1
 1002          SAR  sx1
 1006          BCE  asg,codseq-3,R
     *
     * Statement is arithmetic IF
     *
 1014          C    0&X1,kb10  move x1 down
 1021          SAR  x1           by ten
 1025          SW   1&X1
 1029          LCA  10&X1,0&X3  move up labels
 1036          SAR  x1
 1040          C    0&X3
 1044          SAR  x3
 1048          CW   1&X1,1&X3
 1055          LCA  gm
 1059          LCA  kifbot
 1063          SBR  x3
 1067          CW   1&X3,5&X3
 1074          SBR  sx1b,0&X1
 1081          B    expr3
     *
     * Statement is assignment
     *
 1085asg       SBR  x2,1&X1
 1092          BCE  msg23,0&X1,#  equal sign is first
 1100          SBR  sx1b,0&X1
 1107geteq     BCE  goteq,0&X1,#
 1115          BCE  msg23,0&X1,}  no equal sign at all
 1123          SBR  x1
 1127          B    geteq
 1131goteq     B    subchk
 1135asgl      MN   0&X1
 1139          SAR  x1
 1143expr3     SBR  x2,1&X1
 1150          SBR  sx1c
 1154opchkl    MN   0&X1,opchk&7
 1161          MZ   0&X1,opchk&7
 1168          SAR  x1
 1172opchk     BCE  gotop,opratr,0  &-@*#%) or GM
 1180          chain7
 1187          B    opchkl
 1191gotop     SBR  x1,1&X1
 1198          BCE  minus,0&X1,-
 1206          BCE  lparen,0&X1,%
 1214          BCE  star,0&X1,*
 1222          BCE  plus,0&X1,&
 1230          BCE  chk27,0&X1,@  was originally slash
 1238          BCE  asgl,0&X1,#
 1246          BCE  rparen,0&X1,)
 1254          MN   1&X1,opchk2&7
 1261          MZ   1&X1,opchk2&7
 1268opchk2    BCE  msg27,oprat2,0  &-*@.#,
 1276          chain6
 1282          BCE  restr2,1&X1,
 1290          BCE  restr2,1&X1,%
 1298          BCE  restr2,1&X1,)
 1306          B    subchk
 1310restr2    MCW  sx1b,x2
 1317          LCA  0&X2,0&X3
 1324          SBR  x3
 1328          MCW  sx1,x1
 1335          B    loop
     *
 1339rparen    MCW  0&X1,rparsv
 1346          MCW  rparsv-1,*&8  char after right parenthesis
 1353          BCE  rpar2,oprat3,0  &*@-})  includes GM
 1361          chain5
 1366          BCE  rpar2,rparsv-1,#
 1374          B    msg27
 1378rpar2     MN   1&X1,opchk4&7
 1385          MZ   1&X1,opchk4&7
 1392opchk4    BCE  msg27,oprat4,0  &-*.@ %,
 1400          chain7
 1407          BCE  asgl,1&X1,#
 1415          BCE  asgl,1&X1,)
 1423          B    subchk
 1427          B    asgl
     *
     * Asterisk
     *
 1431star      MCW  0&X1,star2
 1438          BCE  expon,star2-1,*
     * slash originally, now @
 1446chk27     BCE  msg27,1&X1,#
 1454          BCE  msg27,1&X1,%
 1462          BCE  msg27,1&X1,
 1470chk31     MN   1&X1,opchk5&7
 1477          MZ   1&X1,opchk5&7
 1484opchk5    BCE  msg31,oprat5,0  &-@*.,
 1492          chain5
 1497          BCE  asgl,1&X1,)
 1505          B    subchk
 1509          B    asgl
     *
     * Two asterisks in a row
     *
 1513expon     MN   0&X1
 1517          MN
 1518          SAR  x1
 1522          MCW  dot,2&X1  replace ** by dot
 1529          LCA  0&X1
 1533          SBR  x1,2&X1
 1540          B    chk27
     *
     * Plus sign
     *
 1544plus      BCE  ignore,1&X1,#  Is plus
 1552          BCE  ignore,1&X1,%    sign
 1560          BCE  ignore,1&X1,       unary?
 1568          B    chk31
 1572ignore    MN   0&X1
 1576          SAR  x1
 1580          LCA  0&X1,1&X1  move up, clobbering plus sign
 1587          SBR  x1,1&X1
 1594          B    expr3
     *
     * Minus sign
     *
 1598minus     BCE  negate,1&X1,#
 1606          BCE  negate,1&X1,%
 1614          BCE  negate,1&X1,
 1622          B    chk31
     *
 1626negate    MCW  comma,0&X1
 1633          CW   sawneg
 1637          B    asgl
     *
     * Left parenthesis
     *
 1641lparen    BCE  func,1&X1,F  Maybe a function
 1649          MN   1&X1,lparc&7
 1656          MZ   1&X1,lparc&7
 1663lparc     BCE  asgl,oprat6,0  &-*@ #%,.
 1671          chain8
 1679          B    msg27
     *
     * Left parenthesis follows F, maybe a function
     *
 1683func      MCW  x2,sx2
 1690          MCW  sx1c,x2
 1697          MN   0&X2
 1701          SAR  x2
 1705          SW   0&X1
 1709          SBR  sx1c,2&X1
 1716          C    sx1c,x2
 1723          BE   msg27
 1728          SBR  sx1c,3&X1
 1735          C    sx1c,x2
 1742          BE   msg27
 1747          MCW  x3,sx3c
 1754          MCW  x1,sx1d
 1761          SBR  x1,sincos
 1768          SBR  x3,fnclst
 1775funcl     BCE  notfnc,0&X3,*  search function name table
 1783          SBR  x3
 1787          C    0&X3,0&X2
 1794          BE   gotfnc
 1799          C    0&X3
 1803          SAR  x3
 1807          SBR  x1,1&X1
 1814          B    funcl
     *
     * Name ending in F and followed by left parenthesis
     * is not in the function table
     *
 1818notfnc    CS   332
 1822          CS
 1823          SW   glober
 1827          MN   codseq,249
 1834          MN
 1835          MN
 1836          MCW  err29
 1840          W
 1841          BCV  *&5
 1846          B    *&3
 1850          CC   1
 1852          B    restrt
     *
     * Need series for undefined function, sin, cos, log, exp, atan
     *
 1856getser    CW   series
 1860          B    fnc2
     *
     * Sin and cos are the same
     *
 1864cosf      CW   sincos
 1868          B    getser
     *
     * Need negate for abs
     *
 1872absf      CW   sawabs,sawneg  absf needs negation
 1879          B    fnc2
     *
 1883gotfnc    SW   1&X3
 1887          BCE  cosf,1&X3,C  cosf
 1895          BCE  absf,1&X3,A  absf
 1903          CW   0&X1
 1907          MCW  1&X3,*&8
 1914          BCE  getser,sgect,0  sin log exp cos atan
 1922          chain4
 1926fnc2      BCE  intfnc,0&X2,X  integer function result?
 1934fnc3      MCW  1&X3,0&X2  move function code
 1941          MCW  kb1          and a blank
 1945          SBR  x2
 1949          MCW  sx3c,x3
 1956          MCW  sx1d,x1
 1963          CW   0&X1
 1967          SAR  x1
 1971          LCA  0&X1,0&X2
 1978          SBR  x1,0&X2
 1985          B    expr3
 1989intfnc    MN   0&X2
 1993          SAR  x2
 1997          B    fnc3
     *
     * Emit Coding is unintelligible message
     *
 2001msg23     CS   332
 2005          CS
 2006          SW   glober
 2010          MN   codseq,247
 2017          MN
 2018          MN
 2019          MCW  err23  unintelligible
 2023          W
 2024          BCV  *&5
 2029          B    *&3
 2033          CC   1
 2035restrt    MCW  sx3b,x3
 2042          MCW  sx1,x1
 2049          B    loop
     *
     * Check for subscript?
     *
 2053subchk    SBR  subchx&3
 2057          BCE  subch2,1&X1,$
 2065          SBR  sx1e,4&X1
 2072subch3    C    sx1e,x2
 2079subchx    BE   0
     *
     * Left side is invalid
     *
 2084msg25     CS   332
 2088          CS
 2089          SW   glober
 2093          MN   codseq,243
 2100          MN
 2101          MN
 2102          MCW  err25
 2106          W
 2107          BCV  *&5
 2112          B    *&3
 2116          CC   1
 2118          B    restrt
     *
     * Arithmetic syntax error
     *
 2122msg27     CS   332
 2126          CS
 2127          SW   glober
 2131          MN   codseq,249
 2138          MN
 2139          MN
 2140          MCW  err27
 2144          W
 2145          BCV  *&5
 2150          B    *&3
 2154          CC   1
 2156          B    restrt
     *
 2160gm        dc   @}@
     *
     * Double operators
     *
 2161msg31     CS   332
 2165          CS
 2166          SW   glober
 2170          MN   codseq,242
 2177          MN
 2178          MN
 2179          MCW  err31
 2183          W
 2184          BCV  *&5
 2189          B    *&3
 2193          CC   1
 2195          B    restrt
     *
 2199subch2    SBR  sx1e,12&X1
 2206          BCE  subch3,11&X1,$
 2214          SBR  sx1e,18&X1
 2221          B    subch3
     *
     * Data
     *
 2225          DCW  @*@                    WM cleared if needed
 2234          DCW  @   %FSOCC@  cosf      118 and 117
 2243          DCW  @  %FSBAXA@  xabsf     122 and 123
 2252          DCW  @ %FKNILXI@  xlinkf    139
 2261          DCW  @        H@            138
 2270          DCW  @        D@            137
 2279          DCW  @        M@            136
 2288          DCW  @        L@            135
 2297          DCW  @        K@            134
 2306          DCW  @        J@            133
 2315          DCW  @        Z@            132
 2324          DCW  @        Y@            131
 2333          DCW  @        W@            130
 2342          DCW  @        P@            129
 2351          DCW  @        U@            128
 2360          DCW  @        R@            127
 2369          DCW  @  %FTRQSQ@  sqrtf     126
 2378          DCW  @ %FTAOLFF@  floatf    125
 2387          DCW  @  %FXIFXX@  xfixf     124
 2396          DCW  #9           negation  123
 2405          DCW  @   %FSBAA@  absf      122
 2414          DCW  @  %FNATAT@  atanf     121 and 117
 2423          DCW  @   %FPXEE@  expf      129 and 117
 2432          DCW  @   %FGOLG@  logf      119 and 117
 2441fnclst    DCW  @   %FNISS@  sinf      118 and 117
 2442          DCW  #1
 2443dot       dcw  @.@
 2447codseq    DCW  #4  statement code and sequence number
 2450sx3b      DCW  #3
 2453sx3       DCW  #3
 2462arith2    DCW  @ARITH TWO@
 2465sx1       DCW  #3
 2475kb10      DCW  #10
 2479kifbot    dcw  @#<99@
 2482sx1b      DCW  #3
 2485sx1c      DCW  #3
 2493opratr    DCW  @&-@*#%)}@
 2500oprat2    DCW  @&-*@.#,@
 2502rparsv    DCW  #2  right parenthesis and next character
 2508oprat3    DCW  @&*@-})@
 2516oprat4    DCW  @&-*.@ %,@
 2518star2     DCW  #2  asterisk and next character
 2524oprat5    DCW  @&-@*.,@
 2525comma     dcw  @,@
 2534oprat6    DCW  @&-*@ #%,.@
 2537sx2       DCW  #3
 2540sx3c      DCW  #3
 2543sx1d      DCW  #3
 2589err29     DCW  @ERROR 29 - UNDEFINED FUNCTION NAME, STATEMENT @
 2594sgect     DCW  @SGECT@
 2595kb1       DCW  #1
 2639err23     DCW  @ERROR 23 - CODING UNINTELLIGIBLE, STATEMENT @
 2642sx1e      DCW  #3
 2682err25     DCW  @ERROR 25 - LEFT SIDE INVALID, STATEMENT @
 2728err27     DCW  @ERROR 27 - ARITHMETIC SYNTAX ERROR, STATEMENT @
 2767err31     DCW  @ERROR 31 - DOUBLE OPERATORS, STATEMENT @
 2768gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
