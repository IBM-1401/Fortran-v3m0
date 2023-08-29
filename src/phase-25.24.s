               JOB  Fortran compiler -- List Phase One -- phase 25
               CTL  6611
     *
     * Duplicate lists are checked and eliminated to optimize
     * storage at object time.
     *
     * On entry, x1 is the top of statements in low core, x3 is
     * one below the format strings or number table, and 81-83
     * is one below the format strings or number table.
     *
     x1        equ  89
     x2        equ  94
     x3        equ  99
     *
     * Stuff in the resident area
     *
     phasid    equ  110  Phase ID, for snapshot dumps
     botfmt    equ  154  Bottom of format strings or number table - 1
     negary    equ  163  16000 - arysiz
     glober    equ  184  Global error flag -- WM means error
     snapsh    equ  333  Core dump snapshot
     fmtsw     equ  696  X for no format, L for limited format
     *                 blank for ordinary, A for A conversion
     loadnx    equ  700  Load next overlay
     clearl    equ  707  CS at start of overlay loader
     tpread    equ  780  Tape read instruction in overlay loader
     clrbot    equ  833  Bottom of core to clear in overlay loader
     *
     110       dcw  @listr1@
     094       dcw  000
     096       dc   00
     099       dcw  000
     100       dc   0
     *
               ORG  838
     loaddd    equ  *&1          Load address
  841seqcod    DCW  #4
  844sx1       DCW  #3
  845beginn    MCW  x1,sx1
  852          MCW  83,x2
  859          LCA  dot,0&X2
  866          CW   0&X2
  870          SBR  83
  874          SBR  botfmt,0&X2
  881          MA   negary,botfmt
  888loop      BCE  done,0&X1,  Below bottom statement
  896          MCW  0&X1,seqcod
  903          MCW  x1,sx1b&6
  910          MCW  seqcod-3,*&8
  917          BCE  iostmt,stmts,0  I/O statement?
  925          chain6
  931          B    done  I/O statements are sorted together
     *
     * Found an I/O statement
     *
  935iostmt    C    0&X1  get down
  939          SAR  x1      to body
  943          B    getcom  Get x1 down to a comma
  947          CW   114
  951          BCE  *&5,fmtsw,L  Limited format routine?
  959          CW   115
  963          SW   0&X1    under the comma
  967          SAR  x1
  971          MCW  sx1,x3  top of statements
  978twowm     C    0&X3  Skip two
  982          C            word marks
  983          SAR  x3
  987          BCE  twowm,1&X3,}
  995          C    x1,x3
 1002          BU   chklst
 1007stmbot    C    0&X1
 1011          SAR  x1
 1015          B    loop
 1019chklst    C    0&X1,0&X3
 1026          BU   getgm  lists are different
 1031          C    0&X3,0&X1
 1038          BU   getgm  lists are different
 1043          BW   syntax,0&X1
 1051          BWZ
 1052          BWZ
 1053          LCA  x3,0&X1  link identical lists together
 1060          SBR  x1
 1064          B    stmbot
     *
     * Lists are unequal.  Get x3 down to a GMWM
     *
 1068getgm     C    0&X3  Skip one
 1072          SAR  x3      word mark
 1076          BCE  twowm,1&X3,}
 1084          B    getgm
     *
     * Get comma
     *
 1088getcom    SBR  getcmx&3
 1092schcom    BW   stmbot,0&X1
 1100getcmx    BCE  0-0,0&X1,,
 1108          SBR  x1
 1112          B    schcom
     *
     * List syntax error
     *
 1116syntax    CS   332
 1120          CS
 1121          SW   glober
 1125          MN   seqcod,237
 1132          MN
 1133          MN
 1134          MCW  err18
 1138          W
 1139          BCV  *&5
 1144          B    *&3
 1148          CC   1
 1150          MCW  slash,seqcod-3
 1157sx1b      MCW  seqcod,0
 1164          B    stmbot
     *
 1168done      SW   0&X1
 1172          MCW  sx1,x1
 1179          BSS  snapsh,C
 1184          SBR  tpread&6,beginn
 1191          SBR  clrbot
 1195          SBR  clearl&3,gmwm
 1202          LCA  listr2,phasid
 1209          B    loadnx
     *
     * Data
     *
 1213dot       DCW  @.@
 1220stmts     DCW  @5613LUP@  Read/Write (input) (tape), print, punch
 1254err18     DCW  @ERROR 18 - LIST SYNTAX, STATEMENT @
 1255slash     DCW  @/@
 1264listr2    DCW  @LISTR TWO@
 1265gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
