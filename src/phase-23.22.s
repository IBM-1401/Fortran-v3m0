               JOB  Fortran compiler -- TAMROF Phase One -- 23
               CTL  6611
     *
     * FORMAT statements are checked to insure that they are
     * referenced by input-output statements
     *
     * On entry, 81-83 is one below the number table, which is the
     * GMWM above the top statement in high core, x1 is the
     * GMWM below the bottom statement in low core, x2 is one below
     * the GMWM below the bottom statement in high core
     *
     * On exit, X1 is the top of statements, x2 is the top of
     * formatted I/O statements, and 81-83 is one below the number
     * table
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
     tpread    equ  780  Tape read instruction in overlay loader
     clrbot    equ  833  Bottom of core to clear in overlay loader
     *
     110       dcw  @tamrof one@
     089       dcw  000
     091       dc   00
     099       dcw  000
     100       dc   0
     *
               ORG  838
     loaddd    equ  *&1          Load address
     *
     * The toobig and msg routines are not referenced here.  Why are
     * not simply in phase 24?
     *
  838toobig    CS   332
  842          CS
  843          CC   1
  845          MCW  error2,270
  852          W
  853          CC   1
  855          BCE  halt,cdovly,1
  863          RWD  1
  868halt      H    halt
     *
  872semic     DCW  @;@
  875sx3       DCW  #3  used to save X3 exactly once
  879seqcod    DCW  #4
     *
     * Fill in error message boilerplate
     *
  880msg       SBR  msgx&3
  884          BCV  *&5
  889          B    *&3
  893          CC   1
  895          CS   332
  899          CS
  900          SW   glober
  904          MN   seqcod,250
  911          MN
  912          MN
  913          MCW  stmt
  917          MCW  err,205
  924msgx      B    0
  963error2    DCW  @MESSAGE 2 - OBJECT PROGRAM TOO LARGE@
  974stmt      DCW  @STATEMENT  @
  979err       DCW  @ERROR@
     *
  980beginn    CS   1&X2
  984          SBR  x1
  988          SW   gmwm
  992clrl      CS   0&X1
  996          SBR  x1
 1000          C    x1,kbot
 1007          BU   clrl
 1012          LCA  gmwm,2601
 1019          SBR  x1,2602
 1026          SBR  x2,2&X2
 1033          MCW  dot,96  No format statement seen
 1040          SW   flag
 1044loop      MCW  83,x3  top of statements in top core
 1051          SBR  x3,1&X3
 1058          C    x3,x2  moved top statement up?
 1065          BE   done   yes
 1070          CW   flag2  moving body
 1074          MN   0&X2
 1078          SAR  x3
 1082          MCW  semic
 1086movedn    MN   0&X1
 1090          SAR  x1
 1094more      MCM  0&X2
 1098          SAR  sx2&6
 1102          MCM  0&X2,1&X1
 1109          MN
 1110          SBR  x1
 1114sx2       SBR  x2,0
 1121          BCE  more,0&X1,|
 1129          MN   0&X2
 1133          CW
 1134          SW   0&X1
 1138          SBR  x1,1&X1
 1145          BW   prefix,flag2  processing prefix?
 1153          SW   flag2  moving prefix
 1157          B    movedn
 1161prefix    MN   0&X1
 1165          MN
 1166          SAR  x3
 1170          SBR  setzon&6
 1174          MCW  0&X3,seqcod
 1181          SAR  x3
 1185          BCE  format,seqcod-3,F  Format statement?
 1193          MCW  seqcod-3,*&8
 1200          BCE  fmtio,stmts,X  Formatted I/O statement?
 1208          chain4
 1212          B    loop
     *
     * Got to bottom of statements
     *
 1216done      MN   0&X1
 1220          MN
 1221          SAR  x1          top of statements
 1225          MCW  sx1,x2      top of top formatted I/O statement
 1232          MCW  83,x3       one below number table
 1239          MCW  kb1,0&X3    clear statements
 1246          MCW  0&X3          recently moved down
 1250          MCW  semic,0&X3  below number table
 1257          BSS  snapsh,C
 1262          SBR  tpread&6,980
 1269          SBR  clrbot
 1273          SBR  clearl&3,2600
 1280          LCA  fmt2,phasid
 1287          B    loadnx
     *
     * Found formatted I/O statement
     *
 1291fmtio     MZ   abzone,3&X3  bottom of sequence number
 1298          CW   flag
 1302          MN   0&X1
 1306          MN
 1307          SAR  sx1  top of sequence number
 1311          B    loop
     *
     * Found a format statement
     *
 1315format    MCW  kb1,96  Saw a format statement
 1322          BW   unref,flag    no formatted I/O seen
 1330          BCE  unref,0&X3,}  can't be referenced with no label
 1338          MCW  0&X3,fmtlab
 1345          MCW  sx1,x3  seq no of top formatted I/O statement
 1352chkref    BWZ  chklab,0&X3,B
 1360          BWZ
 1361unref     CS   332
 1365          CS
 1366          MN   seqcod,245
 1373          MN
 1374          MN
 1375          MCW  err14  unreferenced
 1379          W
 1380          BCV  *&5
 1385          B    *&3
 1389          CC   1
 1391setzon    MZ   abzone,0-0  low-order digit of sequence number
 1398          B    loop
     *
     * Check whether format label appears in formatted I/O
     * statement.  The formatted I/O statements are all below
     * (processed before in this phase) the format statements.
     *
 1402chklab    C    0&X3  skip
 1406          SAR  x3      prefix
 1410          C    0&X3,fmtlab  label in stmt same as the format?
 1417          BE   loop         yes, go do next statement
 1422          C    0&X3  skip
 1426          SAR  x3      body
 1430          B    chkref
     *
 1436kbot      DSA  bot  bottom of core clearing
 1437dot       dcw  @.@
 1438flag      DCW  #1  initially set, cleared when formatted I/O seen
 1439flag2     DCW  #1  set for prefix, cleared for body
 1444stmts     DCW  @56ULP@  Formatted I/O statements codes
 1445kb1       DCW  #1
 1453fmt2      DCW  @TAMROF 2@
 1454abzone    dcw  @A@
 1457sx1       DCW  #3  top of sequence number of top formatted I/O
 1460fmtlab    DCW  #3  label from format statement
 1502err14     DCW  @ERROR 14 - UNREFERENCED FORMAT, STATEMENT @
 1503gmwm      DCW  @}@
               org  *&x00
     bot       equ  *
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
