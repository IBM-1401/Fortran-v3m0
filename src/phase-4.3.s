               JOB  Fortran compiler -- Sort one phase -- phase 04
               CTL  6611
     *
     * SORT ONE phase: Determine whether there is sufficient room
     * to expand every statement by three characters.
     * 81-83 is one below the group mark below the last (bottom
     * address) in core.
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
     tpread    equ  780  Tape read instruction in overlay loader
     loadxx    equ  793  Exit from overlay loader
     clrbot    equ  833  Bottom of core to clear in overlay loader
     *
     110       dcw  @sorter one@
     089       dcw  000
     091       dc   00
     094       dcw  000
     096       dc   00
     099       dcw  000
     100       dc   0
     *
     * Table of addresses of the first statement of each type,
     * indexed by 30*(zone of statement type) + 3*(numeric part of
     * statement code).  Filled in next phase, q.v.
     *
               ORG  838
     loaddd    equ  *&1          Load address
  840          DCW  #3  Blank
  843          DCW  #3  1 READ TAPE
  846          DCW  #3  2
  849          DCW  #3  3 WRITE TAPE
  852          DCW  #3  4
  855          DCW  #3  5 READ INPUT TAPE
  858          DCW  #3  6 WRITE OUTPUT TAPE
  861          DCW  #3  7
  864          DCW  #3  8
  867          DCW  #3  9
  870          DCW  #3  0
  873          DCW  #3  / END
  876          DCW  #3  S STOP
  879          DCW  #3  T Computed GOTO
  882          DCW  #3  U PUNCH
  885          DCW  #3  V
  888          DCW  #3  W IF ( SENSE SWITCH ... )
  891          DCW  #3  X
  894          DCW  #3  Y
  897          DCW  #3  Z REWIND
  900          DCW  #3  !
  903          DCW  #3  J SENSE LIGHT
  906          DCW  #3  K IF ( SENSE LIGHT ... )
  909          DCW  #3  L READ
  912          DCW  #3  M
  915          DCW  #3  N ENDFILE
  918          DCW  #3  O
  921          DCW  #3  P PRINT
  924          DCW  #3  Q
  927          DCW  #3  R Arithmetic
  930          DCW  #3  ?
  933          DCW  #3  A PAUSE
  936          DCW  #3  B BACKSPACE
  939          DCW  #3  C CONTINUE
  942          DCW  #3  D DO
  945          DCW  #3  E IF
  948          DCW  #3  F FORMAT
  951          DCW  #3  G GOTO
  954          DCW  #3  H
  957          DCW  #3  I DIMENSION
               ORG  1006
 1009zones     dcw  @2SKB@
     *
     * Start here instead of 838
     *
 1010beginn    CS   2599
 1014          chain8
 1022          MCW  83,x3  Address of end of last statement
 1029          MCM  2&X3
 1033          MCW
 1034          SBR  x3     Address of beginning of last statement
     *
     * Multiply statement number of last statement by 3
     *
 1038          MCW  0&X3,seq
 1045          ZA   seq,seq5
 1052          A    seq5
 1056          A    seq,seq5
 1063          S    kp2,seq5   3 * # stmts - 2
 1070          MCW  seq5,work5
 1077          MCW  k16k,seq5
 1084          S    work5,seq5  16000 - (3 * # stmts - 2)
     *
     * Convert to address
     *
 1091          BAV  loop      clear overflow
 1096loop      A    kp96,seq5-3
 1103          BAV  loop
 1108          MN   seq5-3,*&4
 1115          MZ   zones-0,seq5-2
     *
 1122          MCW  83,x1
 1129          MCW  x1,nop&3
 1136          MCW  seq5,x2
 1143          MZ   km1,nop&2  set tag for x2
 1150nop       NOP  0          x1 + x2
 1154          SAR  x2
 1158          S    w2a
 1162          S    w2b
 1166          MZ   x2,w2a-1
 1173          MZ   x2-2,w2b-1
 1180loop2     BWZ  loop2x,w2b-1,2
 1188          A    k10v,w2b
 1195          B    loop2
 1199loop2x    BWZ  loop3x,w2a-1,2
 1207          A    k04v,w2a
 1214          B    loop2x
 1218loop3x    A    w2b-1,w2a
 1225          MCW  x2,seq5
 1232          MCW  w2a
 1236          ZA   seq5
 1240          MZ   *-4,seq5   Clear zone in tens digit
 1247          C    seq5,k2900
 1254          BL   ok
     *
     * Insufficient room to expand every statement by three characters
     *
 1259          CS   332
 1263          CS
 1264          CC   1
 1266          MCW  msg2,270
 1273          W
 1274          CC   1
 1276          BCE  halt,cdovly,1
 1284          RWD  1
 1289halt      H    halt
     *
     * Source code will fit after expanding every statement by
     * three characters
     *
 1293ok        MCW  x2,83  Replace address of bottom of code
 1300          MCM  0&X1
 1304          SAR  x1     Address below last statement
 1308          BSS  snapsh,C
 1313          SBR  tpread&6,1022  Change load address for next phase
 1320          SBR  clrbot
 1324          SBR  loadxx&3,1022  Change entry address for next phase
 1331          SBR  clearl&3,sort2&1
 1338          LCA  sort2,phasid
 1345          B    loadnx  Load next overlay
     *
     * Constants and work areas
     *
 1349          DCW  0
 1352seq       DCW  #3  Sequence number of last statement
 1357seq5      DCW  #5  Stmt number times 3
 1358kp2       DCW  &2
 1363work5     DCW  #5
 1368k16k      dcw  16000
 1370kp96      dcw  &96
 1371km1       DCW  -1
 1373w2a       DCW  #2
 1375w2b       DCW  #2
 1377k10v      dcw  @A0@  Ten, overflowed
 1379k04v      dcw  @?4@  04, overflowed
 1384k2900     DCW  02900
 1420msg2      DCW  @MESSAGE 2 - OBJECT PROGRAM TOO LARGE@
 1426sort2     DCW  @SORT 2@
 1427gmwm      dcw  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
