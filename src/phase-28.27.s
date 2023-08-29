               JOB  Fortran compiler -- Stmt Numbers Two -- phase 28
               CTL  6611
     *
     * Same as Variables Phase Two (14).
     *
     * The entire source program is shifted to the top (leftmost
     * part) of available storage, leaving room for subsequent
     * compiler phases.  The remaining storage is cleared for
     * tables.
     *
     * On entry, 83 is the top of code in high core and x2 is one
     * below the bottom of code in high core.
     *
     * On exit, 83 is one below the tables in high core, and x1 and
     * x2 are the top of code in low core.
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
     tpread    equ  780  Tape read instruction in overlay loader
     loadxx    equ  793  Exit from overlay loader
     clrbot    equ  833  Bottom of core to clear in overlay loader
     *
     botcod    equ  3199  One below bottom of code
     *
     110       dcw  @stnum two@
     099       dcw  000
     100       dc   0
     *
               ORG  838
     loaddd    equ  *&1          Load address
  840topcd9    DCW  #3  top of code & 5 & x00 - 1
  846diff16    DCW  #6  16 * (bottab - 1 - topcd9)
  849bndry     DCW  #3  topcd9 + 0.48 * (bottab - 1 - topcd9)
  852bottab    DCW  #3  bottom of tables
     *
     * Move down
     *
  853movedn    SBR  movedx&3
  857          MN   0&X1
  861          SAR  x1
  865more      MCM  0&X2
  869          SAR  newx2&6
  873          MCM  0&X2,1&X1
  880          MN
  881          SBR  x1
  885newx2     SBR  x2,0
  892          BCE  more,0&X1,|
  900          MN   0&X2
  904          CW
  905          SW   0&X1  under the GM
  909          C    x2,bottab
  916          BU   more
  921          MN   0&X1
  925          SAR  x1
  929          SBR  x2  seqno of top of code in low core
  933movedx    B    0-0
     *
  937beginn    MCW  83,x3  top of code
  944          SBR  bottab,1&X3  bottom of tables
  951          MCW  x2,x3
  958clear     CS   0&X3
  962          SBR  x3
  966          C    x3,abot  done?
  973          BU   clear     no
  978          SBR  x1,botcod
  985          B    movedn
  989          SBR  topcd9,5&X1
  996          MN   k99,topcd9
 1003          MN
 1004          MCW  83,x3
 1011clear2    CS   0&X3
 1015          SBR  x3
 1019          C    x3,topcd9
 1026          BU   clear2
 1031          MCW  kless,0&X3
 1038          MCW  83,toconv
 1045          B    conv
 1049          MCW  w5,diff16
 1056          MCW  topcd9,toconv
 1063          B    conv
 1067          S    w5,diff16
 1074          A    diff16
 1078          A    diff16
 1082          A    diff16
 1086          A    diff16  16 * (bottab - 1 - topcd9)
 1090          A    diff16-2,w6
 1097          A    w6
 1101          A    diff16-2,w6  0.48 * (bottab - 1 - topcd9)
 1108          A    w5,w6  topcd9 + 0.48 * (bottab - 1 - topcd9)
 1115          MCW  w6-3,x3
 1122          A    x3
 1126          MZ   zones-1&X3,w6-2
 1133          MZ   zones&X3,w6
 1140          MCW  w6,x3
 1147          SW   2&X3
 1151          MCW  kless
 1155          SBR  bndry
 1159          BSS  snapsh,C
 1164          SBR  tpread&6,beginn
 1171          SBR  clrbot
 1175          SBR  loadxx&3,1187
 1182          SBR  clearl&3,botcod
 1189          LCA  stnum3,phasid
 1196          B    loadnx
     *
     * Convert toconv to decimal in w5
     *
 1200conv      SBR  convx&3
 1204          MN   toconv,w5
 1211          MN
 1212          MN
 1213          MCW
 1214          MZ   toconv,k99
 1221          MZ   toconv-2,k99-1
 1228          SBR  x3,zones-4
 1235convl     C    4&X3,k99
 1242          SAR  x3
 1246          A    kp1,w5-3
 1253          BU   convl
 1258          MZ   kb,w5-3
 1265convx     B    0-0
     *
     * Data
     *
 1273toconv    DCW  @0J   @
 1275k99       DCW  @99@
     zones     equ  *&2
 1307          dc   @99Z9R9I99ZZZRZIZ9RZRRRIR9IZIRIII@
 1310abot      DSA  botcod
 1311kless     DCW  @<@
 1316w5        DCW  #5
 1322w6        DCW  #6
 1331stnum3    DCW  @STNUM TRI@
 1332kp1       dcw  &1
 1333kb        DCW  #1
 1334gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
