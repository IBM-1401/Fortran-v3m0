               JOB  Fortran compiler -- Snapshot phase -- Phase 56
               CTL  6611
     *
     * A snapshot of the generated program is printed if requested
     * (if there were no source program errors which would make
     * program execution unrewarding).
     *
     x1        equ  89
     x3        equ  99
     *
     * Stuff in the resident area
     *
     phasid    equ  110  Phase ID, for snapshot dumps
     glober    equ  184  Global error flag -- WM means error
     snapsh    equ  333  Core dump snapshot routine
     topcor    equ  688  Top core address from PARAM card
     snapsw    equ  694  S for snapshot
     fmtsw     equ  696  X for no format, L for limited format
     *                blank for ordinary, A for A conversion
     loadnx    equ  700  Load next overlay
     clearl    equ  707  Clear instruction in LOADNX
     loadex    equ  793  Branch that exits LOADNX
     *
               ORG  838
  838beginn    BCE  *&5,snapsw,S
  846          B    done
  850          BW   error,glober
     *
     * Set the bottom of the dump, depending on the format switch
     *
  858          SBR  x1,4200  Assume normal format
  865          SBR  x3,201
  872          BCE  fmtx,fmtsw,X
  880          BCE  fmtl,fmtsw,L
  888          BCE  fmta,fmtsw,A
  896          B    gotbot
  900fmtx      SBR  x1,1600
  907          MCW  k1600,bot    bottom of dump
  914          MCW  k1696,top    top of fixed code
  921          B    gotbot
  925fmtl      SBR  x1,2000
  932          MCW  k2000,bot    bottom of dump
  939          MCW  k2015,top    top of fixed code
  946          B    gotbot
  950fmta      SBR  x1,4600
  957          MCW  k4600,bot    bottom of dump
  964          MCW  k4616,top    top of fixed code
  971gotbot    CC   1
  973          CS   332
  977          CS
  978          MCW  snap,260
  985          W
  986          CC   J
  988          CS   332
  992          CS
  993          MCW  ioarea,239
 1000          W
 1001          CC   J
 1003          CS   332
 1007          CS
 1008          MCW  top,248
 1015          W
 1016          CC   K
 1018          ZA   kp3,lines
 1025outer     CS   332
 1029          CS
 1030          CC   J
 1032          MCW  bot,311
 1039          MCW
 1040          MCW
 1041          SBR  indic&6
 1045          MCW  k9,w2-1
 1052indic     MCW  w2-1,0
 1059          MCW  dots
 1063          SBR  indic&6
 1067          A    km90,w2
 1074          BWZ  indic,w2-1,2
 1082          A    kp1,bot-2
 1089          W
 1090inner     SW   0&X3
 1094          MCW  0&X1,0&X3
 1101          BW   *&5,0&X1
 1109          CW   0&X3
 1113          C    x1,topcor
 1120          BU   more
 1125          W
 1126          WM
 1128done      BSS  snapsh,C
 1133          SBR  loadex&3,884
 1140          SBR  clearl&3,gmwm
 1147          LCA  condek,phasid
 1154          B    loadnx
 1158error     CC   J
 1160          CS   332
 1164          CS
 1165          MCW  defer,237
 1172          W
 1173          BCV  *&5
 1178          B    *&3
 1182          CC   1
 1184          B    done
 1188more      SBR  x1,1&X1      more hundreds to print
 1195          BCE  morech,x3-2,2
 1203          SBR  x3,201
 1210          W
 1211          WM
 1213          A    kp1,lines
 1220          C    lines,kp15
 1227          BU   outer
 1232          S    lines
 1236          CC   1
 1238          B    outer
 1242morech    A    kp1,x3       more characters to put in line
 1249          B    inner
 1300top       DCW  @FIXED OBJECT TIME ROUTINES LOCATED FROM 333-4279@
 1309dots      DCW  @9........@
 1310          dcw  9
 1316          DCW  @-AREA-@
 1321bot       DCW  04200
 1326k1600     DCW  01600
 1330k1696     DCW  1696
 1335k2000     DCW  02000
 1339k2015     dcw  2015
 1344k4600     DCW  04600
 1348k4616     dcw  4616
 1374snap      DCW  @SNAPSHOT OF OBJECT PROGRAM@
 1413ioarea    DCW  @INPUT/OUTPUT AREAS LOCATED FROM 001-332@
 1414kp3       dcw  &3
 1415k9        dcw  9
 1417km90      DCW  @I0@
 1419w2        DCW  #2
 1420kp1       dcw  &1
 1428condek    DCW  @CONDECK1@
 1465defer     DCW  @SNAPSHOT DEFERRED DUE TO INPUT ERRORS@
 1467lines     DCW  #2
 1469kp15      DCW  &15
 1470gmwm      DCW  @}@
               ex   beginn
               END
