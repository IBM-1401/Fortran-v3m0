               JOB  Fortran compiler -- STOP/PAUSE Phase -- phase 42
               CTL  6611
     *
     * The proper instructions to
     * 1. HALT
     * 2. halt, continue, and display the number indicated
     * are generated in-line
     *
     x1        equ  89
     x2        equ  94
     x3        equ  99
     *
     * Stuff in the resident area
     *
     phasid    equ  110  Phase ID, for snapshot dumps
     snapsh    equ  333  Core dump snapshot
     loadnx    equ  700  Load next overlay
     clearl    equ  707  CS at start of overlay loader
     cdovly    equ  769  1 if running from cards, N if from tape
     *
     110       dcw  @stop/pause@
     *
               ORG  838
     loaddd    equ  *&1          Load address
  838beginn    CS   299
  842loop      BCE  done,0&X1,
  850          MCW  0&X1,codseq
  857          BCE  stoppz,codseq-3,A  Pause statment?
  865          BCE  stoppz,codseq-3,S  Stop statement?
  873done      BSS  snapsh,C
  878          SBR  clearl&3,gmwm
  885          LCA  light,phasid
  892          B    loadnx
     *
     * Stop or pause statement
     *
  896stoppz    MCW  kless,2&X1
  903          SBR  tstles&6,2&X1
  910          LCA  0&X1,0&X3  seqno, code, gmwm
  917          SAR  x1
  921          C    0&X3
  925          SAR  x3
  929          LCA  1&X3,2&X3  clobber statement code with gmwm
  936          SBR  x3
  940          BCE  nocode,0&X1,}
  948          CS   work
  952          MN   wrkbot
  956          MN
  957          SAR  x2
  961          SBR  x1,0&X1
     *
     * Move the stop code into the work area
     *
  968movcod    MCW  0&X1,w1
  975          SAR  x1
  979          BW   gotwm,1&X1
  987          MCW  w1,2&X2
  994          SBR  x2
  998          B    movcod
     *
 1002gotwm     SW   wrkbot
 1006          BCE  twotst,wrkbot&3,  one, two or three digits?
 1014          MCW  err35,222
 1021          MCW  msg,247
 1028          MCW  wrkbot&4,228
 1035          MCW  wrkbot&2,251
 1042twotst    BCE  twodig,wrkbot&2,  one or two digits?
 1050          B    gotcod
 1054twodig    MCW  wrkbot&1,wrkbot&2
 1061          MCW  k0
 1065          B    twotst
 1069nocode    LCA  k000,wrkbot&2  use 000 for halt code
 1076          C    0&X1
 1080          SAR  x1
 1084gotcod    MCW  wrkbot&2,w3
 1091          A    k0,wrkbot&3
 1098          C    wrkbot&2,w3  code is numeric?
 1105          BE   nozone       yes
 1110          BCE  notyet,201,  Showed a message yet?
 1118clrcod    MZ   k3b,251  clear the code in the message
 1125          MZ
 1126          MZ
 1127          B    nozone
 1131notyet    MCW  err35,222
 1138          MCW  msg,247
 1145          MCW  wrkbot&2,226
 1152          MCW  wrkbot&2,251
 1159          MCW  k3b-2,223
 1166          B    clrcod
 1170nozone    BCE  nomsg,201,
 1178          W
 1179          BCV  *&5
 1184          B    *&3
 1188          CC   1
 1190          CS   299
 1194nomsg     CW   wrkbot
 1198          BCE  pause,codseq-3,A
 1206          LCA  branch&3,0&X3  branch back to nop
 1213          LCA  haltop         halt
 1217          LCA  wrkbot&2       nop with stop code
 1221          LCA  1&X1           gmwm
 1225          SBR  x3
 1229          B    tstles
 1233pause     LCA  haltop,0&X3    halt
 1240          LCA  wrkbot&2       nop with stop code
 1244          LCA  1&X1           gmwm
 1248          SBR  x3
 1252tstles    BCE  loop,0,<  not too big if less-than not clobbered
 1260          CS   332
 1264          CS
 1265          CC   1
 1267          MCW  error2,270
 1274          W
 1275          CC   1
 1277          BCE  halt,cdovly,1
 1285          RWD  1
 1290halt      H    halt
 1315err35     DCW  @ERROR 35 - HALT NUMBER@
 1333msg       DCW  @TO BE DISPLAYED AS@
 1364          dc   @                               @
               ORG  1499
 1499          DCW  @N@
 1500wrkbot    equ  *&1
 1548          dc   @                                                 @
               ORG  1599
 1598work      equ  *
 1602codseq    DCW  #4  statement code and sequence number
 1607light     DCW  @LIGHT@
 1608kless     DCW  @<@
 1609w1        DCW  #1
 1610k0        DCW  0
 1613k000      DCW  000
 1616w3        DCW  #3
 1619k3b       DCW  #3
 1620branch    B    15992&X3
 1624haltop    H
 1660error2    DCW  @MESSAGE 2 - OBJECT PROGRAM TOO LARGE@
 1661gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
