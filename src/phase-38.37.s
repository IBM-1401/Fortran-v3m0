               JOB  Fortran compiler -- Arith Phase Six -- phase 38
               CTL  6611
     *
     * Optimization of temporary storage areas takes place.
     * These areas are assigned definite locations in storage.
     *
     * On entry x1 is at the bottom of the bottommost assignment
     * statement in low core, x2 is at the at the bottom of the
     * bottommost assignment statement in high core, and x3 is
     * the bottom of the bottom of the bottommost statement in
     * high core that is neither an assignment nor if statement.
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
     imod      equ  690  Integer modulus -- number of digits
     mantis    equ  692  Floating point mantissa digits
     loadnx    equ  700  Load next overlay
     clearl    equ  707  CS at start of overlay loader
     *
     110       dcw  @arith six@
     *
               ORG  838
     loaddd    equ  *&1          Load address
  838beginn    BCE  done,x2,.
  846          SBR  sx2,0&X2
  853          MN   0&X3
  857          MN
  858          SAR  sx3
  862          SBR  sx1,0&X1
  869          MCW  86,s86
  876          MCW  mantis,numwid
  883          MN   kpzero,numwid-2
  890          A    kp2,numwid  wasn't this done a long time ago?
  897          C    numwid,imod
  904          BL   *&8
  909          MCW  imod,numwid  numwid is max(imod,mantis&4)
  916loop      C    x2,sx3
  923          BE   almost
  928          MCW  work,work-1  fill work with record marks
  935getles    BCE  gotles,2&X2,<
  943          SBR  x2
  947          BCE  endstm,1&X2,}
  955          B    getles
  959gotles    MN   4&X2,w3
  966          MN
  967          MCW  kzero
  971          BWZ  zonex3,4&X2,2
  979          A    kp100,w3
  986          BWZ  zonex3,4&X2,S
  994          A    kp100,w3
 1001          BWZ  zonex3,4&X2,K
 1009          A    kp100,w3
 1016zonex3    MCW  w3,x3  4&x2 & &100*zone to x3
 1023          A    x3
 1027          A    w3,x3  times 3
 1034          BCE  gotasg,5&X2,#
 1042          MCW  wrkbot&X3,x1
 1049          MCW  rm,wrkmid&X1
 1056          B    notasg
 1060gotasg    MCM  wrkmid&1
 1064          SAR  x1
 1068          MA   a13671,x1
 1075          MCW  *-6,wrkmid&X1
 1082          MCW  x1,wrkbot&X3
 1089notasg    ZA   x1,w7-4
 1096          M    numwid,w7
 1103          SW   w7-4
 1107          MN   w7,4&X2  Convert W7 to machine address
 1114          MN
 1115          MN
 1116          SAR  *&4
 1120          MCW  0,x3
 1127          MCW  kzero
 1131          A    x3
 1135          MZ   zones&X3,4&X2
 1142          CW
 1143          SBR  *&7
 1147          MZ   zones-1&X3,0
 1154          CW   w7-4
 1158          MA   86,4&X2
 1165          C    x1,w3b
 1172          BH   notbig
 1177          MCW  x1,w3b
 1184          MCW  4&X2,s86
 1191          BWZ  toobig,s86,2
 1199notbig    SBR  x2,3&X2
 1206          B    getles
     *
     * End of statement.
     *
 1210endstm    SBR  x2,4&X2
 1217          B    loop
     *
     * Almost done
     *
 1221almost    MCW  sx2,x3
 1228          MCW  sx1,x1
 1235          C    0&X1
 1239          C
 1240          SAR  x1
 1244          MCW  s86,86
     *
 1251done      BSS  snapsh,D
 1256          SBR  clearl&3,gmwm
 1263          LCA  io2,phasid
 1270          B    loadnx
     *
     * Program is too big
     *
 1274toobig    BW   notbig,printd
 1282          CS   332
 1286          CS
 1287          MCW  error2,270
 1294          W
 1295          SW   glober,printd
 1302          B    notbig
     *
 1305wrkbot    equ  *
 1355          DCW  @                                                  @
               ORG  2329
 2328wrkmid    equ  *
 2378          DCW  @                                                  @
 2428          DC   @                                                  @
 2478          DC   @                                                  @
 2494work      DC   @               |@
 2495printd    DC   @ @  WM means *too big* message has been printed
 2497kb9       DCW  @ 9@
 2498zones     equ  *&1
 2528          DCW  @9Z9R9I99ZZZRZIZ9RZRRRIR9IZIRIII@
 2531sx2       DCW  #3
 2534sx3       DCW  #3
 2537sx1       DCW  #3
 2540numwid    DCW  #3
 2541kpzero    DCW  @?@
 2542kp2       dcw  &2
 2545w3        DCW  #3
 2546kzero     DCW  0
 2549kp100     DCW  &100
 2550rm        DCW  @|@
 2553a13671    DSA  13671
 2560w7        DCW  #7
 2563w3b       DCW  #3
 2566s86       DCW  #3
 2573io2       DCW  @I/O TWO@
 2609error2    DCW  @MESSAGE 2 - OBJECT PROGRAM TOO LARGE@
 2610gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
