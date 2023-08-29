               JOB  Fortran compiler -- Computed GOTO Phase -- phase 40
               CTL  6611
     *
     * Statements with two to ten exits generate in-line instructions.
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
     110       dcw  @cgoto@
     094       dcw  000
     096       dc   00
     *
               ORG  838
     loaddd    equ  *&1          Load address
  838beginn    SW   gm,gm2
  845loop      BW   done,0&X1
  853          MCW  0&X1,seqno
  860          MCW  seqno,seqno2
  867          MCW  rbrack,1&X1
  874          SBR  tstbrk&6,1&X1
  881          C    0&X1
  885          SAR  x1
  889          C    2&X1,kt  Computed GOTO statement?
  896          BU   almost   No
  901          S    w2
  905count     MN   0&X1
  909          MN
  910          MN
  911          SAR  x1
  915          A    kp1,w2
  922          C    w2,kp11  Eleven ways yet?
  929          BE   syntax   yes, syntax error
  934          C    0&X1,kcomma
  941          BU   count    Count branches
  946          MN   0&X1
  950          SAR  x1
  954          B    getadr
  958          LCA  seqno2,0&X3
  965          LCA  branch&3
  969          LCA
  970          LCA
  971          SBR  x3
  975          SBR  x1,1&X1
     *
     * Generate BCE instructions to test selector
     *
  982genbce    BW   endstm,4&X1
  990          SW   bce-6
  994          MN   w2,bce
 1001          MCW  w3
 1005          MCW  6&X1
 1009          SAR  x1
 1013          CW   bce-6
 1017          MZ   x2zone,bce-5
 1024          MZ   *-4,bce-2
 1031          LCA  bce,0&X3
 1038          SBR  x3
 1042          S    kp1,w2
 1049          B    genbce
     *
 1053endstm    LCA  gm,0&X3
 1060          SBR  x3
 1064bottom    C    0&X1  bottom of loop -- get down to
 1068          SAR  x1      bottom of statement
 1072tstbrk    BCE  loop,0,]  not too big if bracket not clobbered
 1080          CS   332
 1084          CS
 1085          CC   1
 1087          MCW  error2,270
 1094          W
 1095          CC   1
 1097          BCE  halt,cdovly,1
 1105          RWD  1
 1110halt      H    halt
     *
     * Verify that the field after the branches is an address,
     * that is, the digit part of all three characters is in
     * the range 0-9.  Move it to w3.
     *
 1114getadr    SBR  getadx&3
 1118          S    w1
 1122getch     MN   0&X1,tstdgt&7
 1129          SAR  x1
 1133          BCE  okadr,w1,B  tested all three characters?
 1141          A    kp1,w1
 1148tstdgt    BCE  getch,digits,0  Numeric part is a digit?
 1156          B
 1157          B
 1158          B
 1159          B
 1160          B
 1161          B
 1162          B
 1163          B
 1164          B
 1165getgm     BCE  syntax,0&X1,}
 1173          SBR  x1
 1177          B    getgm
 1181okadr     BM   *&5,2&X1
 1189          B    getgm
 1193          MZ   kb1,2&X1
 1200          MCW  3&X1,w3
 1207          C    0&X1,gm
 1214          BU   getgm
 1219getadx    B    0
     *
 1223syntax    BWZ  *&5,seqno,2
 1231          B    *&9
 1235          BWZ  *&15,seqno-2,2
 1243          MCW  seqno,x2
 1250          MCW  0&X2,seqno
 1257          CS   332
 1261          CS
 1262          SW   glober
 1266          MN   seqno,247
 1273          MN
 1274          MN
 1275          MCW  err34
 1279          W
 1280          BCV  *&5
 1285          B    *&3
 1289          CC   1
 1291          B    bottom
     *
 1295gm        dc   @}@
 1299          DCW  @T840@
 1302w3        DCW  #3
 1305          DCW  #3
 1308          DCW  #3
 1309gm2       dc   @}@
 1312seqno2    dc   #3
     *
 1313almost    SBR  x1,5&X1
 1320done      BSS  snapsh,C
 1325          SBR  clearl&3,gmwm
 1332          LCA  gomsk,phasid
 1339          B    loadnx
     *
 1350bce       dcw  @BXXXXXXA@  BCE  XXX,XXX,A
 1351          NOP  1001
 1355          H
 1356branch    B    15992&X3
 1362seqno     DCW  #3
 1363rbrack    DCW  @]@
 1364kt        DCW  @T@  computed GOTO statement code
 1366w2        DCW  #2
 1367kp1       dcw  &1
 1369kp11      DCW  &11
 1370kcomma    dcw  @,@
 1371x2zone    DCW  @K@
 1407error2    DCW  @MESSAGE 2 - OBJECT PROGRAM TOO LARGE@
 1408w1        DCW  #1
 1418digits    DCW  @0123456789@
 1419kb1       DCW  #1
 1463err34     DCW  @ERROR 34 - COMPUTED GO TO SYNTAX, STATEMENT @
 1468gomsk     DCW  @GOMSK@
 1469gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
