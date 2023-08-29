               JOB  Fortran compiler -- Condensed deck phase 3 -- 60
               CTL  6611
     *
     x1        equ  89
     x2        equ  94
     x3        equ  99
     *
     * Stuff in the resident area
     *
     phasid    equ  110  Phase ID, for snapshot dumps
     nstmts    equ  183  Number of statements, including generated stop
     *                 Beginning of generated code by now.
     glober    equ  184  Global error flag -- WM means error
     arytop    equ  194  Top of arrays in object code
     snapsh    equ  333  Core dump snapshot
     condns    equ  693  P for condensed deck
     fmtsw     equ  696  X for no format, L for limited format
     *                 blank for ordinary, A for A conversion
     loadnx    equ  700  Load next overlay
     clearl    equ  707  CS at start of overlay loader
     *
     * Runtime addresses
     *
     fmtbas    equ  1697  base address of limited and normal 
     lgm       equ  2015  GMWM at end of limited routine
     ngm       equ  4269  GMWM at end of normal routine
     fmtbaa    equ  4280  base address for A-conversion
     agm       equ  4616  GMWM at end of A-conversion
     *
               ORG  838
  838beginn    MCW  nstmts,x1  Beginning of generated code
  845          BCE  *&5,condns,P
  853          B    done
  857          BW   done,glober
  865loop      SBR  puexit&3,setup
  872          MCW  setwms-11,w7  ,040040
  879          MCW  a146,x3
  886          MCW  lca,140
  893setup     CS   139
  897          BCV  *&5
  902          B    *&3
  906          CC   1
  908          MCW  setwms,171
  915          SW   140
  919          CS   332
  923          CS
  924          SW   101
  928          MCW  a001,x2
  935          MCW  k1,w1
  942          MCW  w7,153
  949          BW   cwload,flag
  957more      MN   0&X1,100&X2  Move a character
  964          MZ   0&X1,100&X2    to the punch area
  971chktop    C    arytop,x1
  978          BE   top
  983          SBR  x1,1&X1
  990          SBR  x2,1&X2
  997          BCE  endcod,0&X1,]  right bracket means end of code
 1005          BW   wm,0&X1
 1013          C    a040,x2
 1020          BL   more
 1025          C    a160,x3
 1032          BL   setcw
 1037          MCW  a040,167
 1044          BH   *&8
 1049          MCW  a040,164
 1056          CW   140
 1060sw        SW   0
 1064          SBR  x2
 1068          A    km990,x2&1
 1075          MCW  239,139  clear part of card above loaded chars
 1082sx1       SBR  x1,0
 1089punch0    MCW  setwms-11,w7  ,040040
 1096          MCW  a146,x3
 1103punch     A    k1,175  Bump sequence number
 1110          MN   0&X2
 1114          SBR  143
 1118          C    143,a000
 1125          BE   xfmt
 1130          MN   0&X1
 1134          SBR  146
 1138          LCA  180,280
 1145          LCA
 1146          LCA
 1147          BSS  *&5,B
 1152puexit    P    setup
 1156          SW   prexit&1
 1160          MCW  puexit&3,prexit&3
 1167          CW   prexit&1
 1171prexit    WP   setup
     *
     * Put a CW instruction in W7
     *
 1175setcw     MCW  cw,w7-6
 1182          MCW  x1,w7
 1189          MCW  x1
 1193          MCW  a153,x3
 1200          B    punch
     *
     * Got to top of arrays
     *
 1204top       SBR  puexit&3,aftary
 1211          B    punch
     *
     * Found WM
     *
 1215wm        MCW  x1,sx1&6
 1222          SBR  sw&3,100&X2
 1229          C    a040,x2
 1236          BE   punch0
 1241          C    a167,x3
 1248          BE   punch0
 1253          SBR  x3,3&X3
 1260          ZS   w1
 1264          BM   bumpx3,w1
 1272wm2       MCW  x1,0&X3
 1279          B    more
     *
     * Saw a right bracket -- end of code
     *
 1283endcod    SW   flag
 1287          B    punch0
     *
     * Set a CW instruction in the load area
     *
 1291cwload    CW   flag
 1295          MCM  0&X1
 1299          SBR  x1
 1303          BW   more,0&X1
 1311          MCW  x1,153
 1318          MCW  x1
 1322          MCW  cw
 1326          MCW  a153,x3
 1333          B    more
     *
 1337bumpx3    SBR  x3,1&X3
 1344          B    wm2
     *
     * After the arrays
     *
 1348aftary    SBR  x1,fmtbas
 1355          BCE  xfmt,fmtsw,X  no format routine
 1363          BCE  lfmt,fmtsw,L  limited format routine
 1371          BCE  afmt,fmtsw,A  A-conversion format
 1379setchk    SBR  chktop&3,usrbas    normal format
 1386          SBR  puexit&3,setup
 1393          SBR  top&6,xfmt
 1400          B    loop
 1404lfmt      SBR  usrbas,lgm&1  After limited format
 1411          B    setchk
 1415afmt      SBR  usrbas,agm&1  After A conversion
 1422          B    setchk
 1426xfmt      CS   171
 1430          MCW  a080,146
 1437          MCW  nstmts
 1441          LCA  cs
 1445          A    k1,175
 1452          LCA  180,280
 1459          LCA
 1460          CS
 1461          BSS  print,B
 1466          P
 1467lastcd    CS   180
 1471          P
 1472          SS   8
 1474done      BSS  snapsh,C
 1479          SBR  clearl&3,gmwm
 1486          LCA  gaux1,phasid
 1493          B    loadnx
 1497print     WP   lastcd
     *
     * Data
     *
 1503usrbas    DSA  fmtbaa         Base address of user code
 1521setwms    DCW  @,040040,0400401040@
 1522flag      dc   #1
 1525a146      DSA  146
 1526lca       LCA
 1529a001      DSA  1
 1530k1        dcw  1
 1531w1        DCW  #1
 1538w7        DCW  #7
 1541a040      DSA  40
 1544a160      DSA  160
 1547km990     dcw  -990
 1550a000      DSA  0
 1551cw        CW
 1554a153      DSA  153
 1557a167      DSA  167
 1560a080      DSA  80
 1561cs        CS
 1569gaux1     DCW  @GAUX ONE@
 1572          DSA  3999
 1573gmwm      DCW  @}@
               ex   beginn
               END
