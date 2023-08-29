               JOB  Fortran compiler -- I/O Phase Two -- phase 39
               CTL  6611
     *
     * In-line instructions are generated for executing END FILE,
     * REWIND and BACKSPACE statements.
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
     110       dcw  @i/o two@
     094       dcw  000
     096       dc   00
     *
               ORG  838
     loaddd    equ  *&1          Load address
  838loop      BCE  done,0&X1,
  846          MCW  0&X1,codseq
  853          MCW  codseq-3,*&8
  860          BCE  iostmt,codes,0  Interesting statement?
  868          B
  869          B
  870done      BSS  snapsh,C
  875          SBR  clearl&3,gmwm
  882          LCA  cgoto,phasid
  889          B    loadnx
     *
     * Statement is Backspace, Endfile or Rewind
     *
  893iostmt    MCW  kb,ioinst      Assume backspace
  900          MCW  kless,2&X1
  907          SBR  tstles&6,2&X1
  914          BCE  moveup,codseq-3,B  Backspace?
  922          MCW  kr,ioinst      Assume rewind
  929          BCE  moveup,codseq-3,Z  Rewind?
  937          MCW  km,ioinst      Must be endfile
  944moveup    LCA  0&X1,0&X3
  951          SAR  x1
  955          C    0&X3
  959          SAR  x3
  963          LCA  1&X1,2&X3
  970          SBR  x3
  974          BWZ  *&5,codseq,2
  982          B    *&9
  986          BWZ  *&15,codseq-2,2
  994          MCW  codseq,x2      Zone in codseq high or low
 1001          MCW  0&X2,codseq      means it's an address
 1008          BCE  syntax,0&X1,}
 1016          MN   0&X1
 1020          SAR  x2
 1024          BCE  unitk,0&X2,}   unit number is a constant
 1032uvar      MCW  k0,ioinst-1
 1039          MCW  0&X1,mvunit&3
 1046          MCW  mn,mvunit
 1053          MZ   *-4,mvunit&2   clobber type tag
 1060          CW   flag
 1064gotu      C    0&X1
 1068          SAR  x1
 1072          LCA  ioinst,0&X3    load CU instruction
 1079          SBR  x3
 1083          BW   const,flag     unit number is a constant
 1091          SW   flag
 1095          LCA  mvunit&6,0&X3  load move unit number instr
 1102          SBR  x3
 1106const     LCA  1&X1,0&X3
 1113          SBR  x3
 1117tstles    BCE  loop,0,<  not too big if less-than not clobbered
 1125          CS   332
 1129          CS
 1130          CC   1
 1132          MCW  error2,270
 1139          W
 1140          CC   1
 1142          BCE  halt,cdovly,1
 1150          RWD  1
 1155halt      H    halt
 1159syntax    CS   332
 1163          CS
 1164          SW   glober
 1168          MN   codseq,245
 1175          MN
 1176          MN
 1177          MCW  err33
 1181          W
 1182          BCV  *&5
 1187          B    *&3
 1191          CC   1
 1193          MCW  k0,ioinst-1
 1200          B    uvar
     *
     * Unit number is a constant
     *
 1204unitk     MN   0&X1,ioinst-1
 1211          B    gotu
     *
     * Data
     *
 1215mvunit    MCW  5777&X1,4&X3
 1226ioinst    DCW  @U%U0X@
 1230codseq    DCW  #4  Statement code and sequence number
 1233codes     DCW  @BZN@  Backspace, Rewind, Endfile statement codes
 1238cgoto     DCW  @CGOTO@
 1239kb        dcw  @B@
 1240kless     DCW  @<@  core is not full yet sentinel
 1241kr        DCW  @R@
 1242km        DCW  @M@
 1243k0        DCW  @0@
 1244mn        MN
 1245flag      DCW  #1  no WM means unit is variable, WM means const
 1281error2    DCW  @MESSAGE 2 - OBJECT PROGRAM TOO LARGE@
 1323err33     DCW  @ERROR 33 - NO TAPE UNIT NUMBER, STATEMENT @
 1324gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   loop
               END
