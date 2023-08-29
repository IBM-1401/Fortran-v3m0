               JOB  Fortran compiler -- Sense light Phase -- phase 43
               CTL  6611
     *
     * In-line instructions are generated.
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
     110       dcw  @light@
     094       dcw  000
     096       dc   00
     *
               ORG  838
     loaddd    equ  *&1          Load address
  838beginn    BCE  done,0&X1,
  846          MCW  0&X1,seqcod
  853          BCE  slite,seqcod-3,J
  861done      BSS  snapsh,C
  866          SBR  clearl&3,gmwm
  873          LCA  ifcond,phasid
  880          B    loadnx
  884slite     LCA  0&X1,0&X3
  891          SAR  x1
  895          C    0&X3
  899          SAR  x3
  903          SBR  tstbrk&6,1&X1
  910          MCW  rbrack,1&X1
  917          LCA  1&X3,2&X3
  924          SBR  x3
  928          MCW  seqcod,w3
  935          BWZ  *&5,w3,2
  943          B    *&9
  947          BWZ  *&15,w3-2,2
  955          MCW  w3,x2
  962          MCW  0&X2,w3
  969          BCE  syntax,0&X1,}
  977          MCW  0&X1,w2
  984          BCE  tstcod,w2-1,}  sense light number is one digit?
  992          B    syntax
  996tstcod    MN   0&X1,*&8
 1003          BCE  sensok,k01234,0  valid sense light number?
 1011          chain4
 1015syntax    CS   332
 1019          CS
 1020          SW   glober
 1024          MN   w3,245
 1031          MN
 1032          MN
 1033          MCW  err36
 1037          W
 1038          BCV  *&5
 1043          B    *&3
 1047          CC   1
 1049          SBR  x3,4&X3
 1056          C    0&X1
 1060          SAR  x1
 1064          B    beginn
 1068sensok    MZ   *-4,0&X1
 1075          BCE  sense0,0&X1,0
 1083          MN   0&X1,cw&3
 1090          LCA  cw&3,0&X3  load CW instruction
 1097          SBR  x3
 1101endstm    C    0&X1
 1105          SAR  x1
 1109          LCA  1&X1,0&X3  gmwm
 1116          SBR  x3
 1120tstbrk    BCE  beginn,0,]  not too big if bracket not clobbered
 1128          CS   332
 1132          CS
 1133          CC   1
 1135          MCW  error2,270
 1142          W
 1143          CC   1
 1145          BCE  halt,cdovly,1
 1153          RWD  1
 1158halt      H    halt
 1162sense0    LCA  sw,0&X3  chained sw
 1169          LCA  sw2&6    sw 82,84
 1173          SBR  x3
 1177          B    endstm
 1181cw        CW   80
 1188seqcod    DCW  #4
 1194ifcond    DCW  @IFCOND@
 1195rbrack    DCW  @]@
 1198w3        DCW  #3
 1200w2        DCW  #2
 1205k01234    DCW  @01234@
 1247err36     DCW  @ERROR 36 - ILLEGAL SENSE LIGHT, STATEMENT @
 1283error2    DCW  @MESSAGE 2 - OBJECT PROGRAM TOO LARGE@
 1284sw        SW
 1285sw2       SW   82,84
 1292gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
