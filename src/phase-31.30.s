               JOB  Fortran compiler -- Stmt Numbers Five -- phase 31
               CTL  6611
     *
     * Undefined statement numbers are noted.
     *
     * On entry, X1 is the top of statements, and X3 is one below
     * the label table at the top of core.
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
     *
     tblbot    equ  145  One below numbers, formats, I/O lists
     *
     110       dcw  @stnum 5@
     094       dcw  000
     096       dc   00
     *
               ORG  838
     loaddd    equ  *&1          Load address
  838beginn    MCW  x3,sx3
  845          MCW  x1,sx1
  852          C    0&X3  get to
  856          SAR  x3      top entry of hash table
  860          CW   1&X3
  864          MCW  tblbot,x2
  871          C    0&X2
  875          SAR  x2
  879          C    x2,sx3
  886          BE   done
  891          MCW  tblbot,savbot
  898tstfin    BW   done,0&X1
  906          MCW  0&X1,seqcod
  913          C    0&X1  get below prefix
  917          SAR  x1
  921          MCW  kb3,w3
  928          BCE  compgo,seqcod-3,H
  936          MCW  seqcod-3,*&8
  943          BCE  labels,stmts,0
  951          B
  952          B
  953          B
  954          B
  955          B
  956endstm    C    0&X1
  960          SAR  x1
  964          B    tstfin
     *
     * was originally computed GOTO code T, now H
     *
  968compgo    MCW  savbot,x3
  975compg2    C    0&X1,x3
  982          BE   compg3
  987          MN   0&X3
  991          MN
  992          MN
  993          SAR  x3
  997          SBR  x2
 1001compgl    BW   compg4,1&X2
 1009          BWZ  compg2,2&X2,2
 1017          MCW  3&X2,x2
 1024          MZ   nozone,x2-1
 1031          MN   0&X2
 1035          MN
 1036          MN
 1037          SAR  x2
 1041          B    compgl
 1045compg3    MCW  x3,savbot
 1052tundef    BCE  endstm,w3,
 1060          BWZ  *&5,seqcod,2
 1068          B    *&9
 1072          BWZ  undef,seqcod-2,2
 1080          MCW  seqcod,x3
 1087          MCW  0&X3,seqcod
 1094undef     CS   299
 1098          SW   glober
 1102          MCW  err21,210
 1109          MCW  msg21,253
 1116          MN   seqcod,257
 1123          MN
 1124          MN
 1125          MCS  w3,214
 1132          C    w3,k001
 1139          BU   *&8
 1144          MCW  kcom,243
 1151          W
 1152          BCV  *&5
 1157          B    *&3
 1161          CC   1
 1163          B    endstm
 1167compg4    A    k1,w3
 1174          B    compg2
     *
     * Statements containing labels of executable statements.  Not
     * I/O statements containing format statement labels.
     *
 1178labels    BW   tundef,0&X1
 1186          BCE  tundef,0&X1,,
 1194          MCW  0&X1,x3
 1201          SAR  x1
 1205          MN   0&X3
 1209          MN
 1210          SAR  x3
 1214          BW   *&5,0&X3
 1222          B    labels
 1226          A    k1,w3
 1233          B    labels
     *
 1237done      MCW  sx1,x1
 1244          MCW  sx3,x3
 1251          BSS  snapsh,E
 1256          SBR  clearl&3,gmwm
 1263          LCA  io1,phasid
 1270          B    loadnx
 1276sx3       DCW  #3
 1279sx1       DCW  #3
 1282savbot    DCW  #3
 1286seqcod    DCW  #4
 1289kb3       DCW  #3
 1292w3        DCW  #3
 1298stmts     DCW  @TWEDGK@  codes for statements with labels
 1299nozone    DCW  #1
 1309err21     DCW  @ERROR 21 -@
 1347msg21     DCW  @UNDEFINED STATEMENT NUMBERS, STATEMENT@
 1350k001      dcw  001
 1352kcom      DCW  @, @
 1353k1        dcw  1
 1360io1       DCW  @I/O ONE@
 1361gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
