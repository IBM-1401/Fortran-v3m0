               JOB  Fortran compiler -- Constants Phase Two -- 18
               CTL  6611
     *
     * Same as Variables Phase Two.  The table of simple variables
     * is destroyed
     *
     x1        equ  89
     x2        equ  94
     x3        equ  99
     *
     * On entry, 83 is the top of code and x2 is one below the
     * bottom of code, at the top of memory.
     *
     botadr    equ  2599  Bottom of working core
     *
     * Stuff in the resident area
     *
     phasid    equ  110  Phase ID, for snapshot dumps
     snapsh    equ  333  Core dump snapshot
     topcor    equ  688  Top core address from PARAM card
     imod      equ  690  Integer modulus -- number of digits
     mantis    equ  692  Floating point mantissa digits & 2 for exp
     loadnx    equ  700  Load next overlay
     clearl    equ  707  CS at start of overlay loader
     tpread    equ  780  Tape read instruction in overlay loader
     clrbot    equ  833  Bottom of core to clear in overlay loader
     *
     110       dcw  @const two@
     089       dcw  000
     091       dc   00
     099       dcw  000
     100       dc   0
     *
               ORG  838
     loaddd    equ  *&1          Load address
  840topcod    DCW  #3  top of code & x00 - 1
  845diff      DCW  #5  top of core - topcod as five digits
  848bndry     DCW  #3
     *
     * Clear from the bottom of code down to botadr & 1
     *
  849beginn    MCW  x2,x3
  856          SW   gm
  860clrl      CS   0&X3
  864          SBR  x3
  868          C    x3,botclr
  875          BU   clrl
     *
     * Move code back down to botadr-2
     *
  880          SBR  x1,botadr  Why not
  887          MN   0&X1         just
  891          SAR  x1             SAR  X1,botadr-1?
  895move      MCM  0&X2
  899          SAR  sx2&6
  903          MCM  0&X2,1&X1
  910          MN
  911          SBR  x1
  915sx2       SBR  x2,0-0
  922          BCE  move,0&X1,|  Do not set WM under RM
  930          MN   0&X2
  934          CW
  935          SW   0&X1  under GM
  939          C    x2,topcor
  946          BU   move
  951          CW   0&X2
  955          CW
  956          SBR  topcod,1&X1  topcod is
  963          MN   k99,topcod     now top of
  970          MN                    code & x00 - 1
     *
     * Clear from top of core down to topcod & 1
     *
  971          MCW  83,x3
  978clrl2     CS   0&X3
  982          SBR  x3
  986          C    x3,topcod
  993          BU   clrl2
  998          MCW  kless,0&X3
 1005          MCW  83,toconv
 1012          B    conv
 1016          MCW  conv5,diff
 1023          MCW  topcod,toconv
 1030          B    conv
 1034          S    conv5,diff
 1041          A    diff-1,w6
 1048          A    w6
 1052          A    diff-1,w6
 1059          A    conv5,w6  diff * 1.3
     *
     * Convert diff * 1.3 to machine address
     *
 1066          MCW  w6-3,x3
 1073          A    x3
 1077          MZ   zones&X3,w6-2
 1084          MZ   zones&1&X3,w6
 1091          MCW  w6,x3
     *
 1098          SW   2&X3
 1102          MCW  kless
 1106          SBR  bndry
 1110          MCW  x1,x2
 1117          MN   0&X2
 1121          SAR  x1
 1125          MCW  83,x3
 1132          LCA  gm,1&X3
 1139          CS   299
 1143          MCW  mantis,x3
 1150          MCW  kz1        and a zero
 1154          SW   200
 1158          MCW  83,*&7
 1165          LCA  199&X3,0   space for a FP number
 1172          SBR  83
 1176          SBR  spint&6
 1180          MN   imod,x3
 1187          MN
 1188spint     LCA  199&X3,0   space for an integer
 1195          SBR  x3
 1199          SBR  142
 1203          LCA  k1,0&X3
 1210          SBR  157
 1214          LCA  k15100
 1218          SBR  83
     *
     * Done
     *
 1222          BSS  snapsh,C
 1227          SBR  tpread&6,beginn
 1234          SBR  clrbot
 1238          SBR  clearl&3,gmwm
 1245          LCA  const3,phasid
 1252          B    loadnx
     *
     * Convert toconv from machine address format to five-digit
     * format in conv5
     *
 1256conv      SBR  convx&3
 1260          MN   toconv,conv5
 1267          MN
 1268          MN
 1269          MCW
 1270          MZ   toconv,k99
 1277          MZ   toconv-2,k99-1
 1284          NOP  k99-1
 1288          SAR  x3
 1292convl     C    4&X3,k99
 1299          SAR  x3
 1303          A    kp1,conv5-3
 1310          BU   convl
 1315          MZ   kb1,conv5-3
 1322convx     B    0
     *
     * Data
     *
 1330toconv    DCW  @0J   @
 1332k99       DCW  99
 1333gm        dc   @}@
     zones     equ  *&1
 1365          dc   @99Z9R9I99ZZZRZIZ9RZRRRIR9IZIRIII@
 1368botclr    DSA  botadr  Clear down to here
 1369kless     DCW  @<@
 1374conv5     DCW  #5
 1380w6        DCW  #6
 1381kz1       DCW  0
 1382k1        dcw  @1@
 1385k15100    DSA  15100
 1394const3    DCW  @CONST TRI@
 1395kp1       dcw  &1
 1396kb1       DCW  #1
 1397gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
