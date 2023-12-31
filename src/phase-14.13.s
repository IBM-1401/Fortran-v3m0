               JOB  Fortran compiler -- Variable Phase Two -- 14
               CTL  6611
     *
     * The entire program is shifted to the top (leftmost part) of
     * available storage, leaving room for subsequent compiler phases.
     * The remaining storage is cleared for tables including the
     * array table generated by Dimension Phase Two.
     *
     * On entry, 83 is one below the GM below the bottom of
     * the array table, x1 is below the bottom of the last
     * statement in sorted order at the bottom of free core,
     * and x2 is one below the bottom of the last transformed
     * statement at the top of free core, in sorted order.
     *
     * On exit, 83 is topcor-2, x1 is the prefix of the first
     * (topmost) statement, x2 is x1&1, topcd9 (840) is top of
     * code & x00 - 1, diff (845) is topcor-1 - topcd9, and
     * bndry (848) is topcd9 + 0.3 * diff
     *
     x1        equ  89
     x2        equ  94
     x3        equ  99
     *
     * Stuff in the resident area
     *
     phasid    equ  110  Phase ID, for snapshot dumps
     snapsh    equ  333  Core dump snapshot
     topcor    equ  688  Top core address from PARAM card
     loadnx    equ  700  Load next overlay
     clearl    equ  707  CS at start of overlay loader
     cdovly    equ  769  1 if running from cards, N if from tape
     tpread    equ  780  Tape read instruction in overlay loader
     loadxx    equ  793  Exit from overlay loader
     clrbot    equ  833  Bottom of core to clear in overlay loader
     *
     frebot    equ  2699
     *
     110       dcw  @varbl two@
     089       dcw  000
     091       dc   00
     099       dcw  000
     100       dc   0
     *
               ORG  838
     loaddd    equ  *&1          Load address
  840topcd9    DCW  #3  top of code & x00 - 1 is bottom of hash
  845diff      DCW  #5  diff = topcor-1 - topcd9 is size of hash
  848bndry     DCW  #3  top of hash table
  849beginn    MCW  83,x3
  856          BCE  toobig,x1,$
  864          SBR  tblbot,2&X3
  871          MCW  x2,x3
     *
     * Clear from below the bottom transformed statement down
     * to frebot.
     *
  878clrlp     CS   0&X3
  882          SBR  x3
  886          C    x3,kfree
  893          BU   clrlp
     *
     * Move transformed statements down to frebot
     *
  898          SBR  x1,frebot
  905          MN   0&X1
  909          SAR  x1
  913more      MCM  0&X2
  917          SAR  nextx2&6
  921          MCM  0&X2,1&X1  Move one statement down
  928          MN
  929          SBR  x1
  933nextx2    SBR  x2,0
  940          BCE  more,0&X1,|  More to do if RM
  948          MN   0&X2
  952          CW
  953          SW   0&X1
  957          C    x2,tblbot  Done moving statements?
  964          BU   more       No
     *
     * X2 is now at the bottom of the array table and
     * X1 is at the top of the moved-down transformed code
     *
  969          CW   0&X2       Why clear this WM?
  973          CW
  974          SBR  topcd9,2&X1
  981          MN   zones-32,topcd9  99
  988          MN
  989          MCW  topcor,x3
  996          MN   0&X3
 1000          SW
 1001          SAR  83  topcor-2
 1005          SBR  x3
 1009clrlp2    CS   0&X3       Clear the array table and
 1013          SBR  x3           transformed code at top of core
 1017          C    x3,topcd9  Down to top of code & x00 ?
 1024          BU   clrlp2     No, more to do
     *
     * Compute topcd9 (hash table base), diff (10 * size of hash
     * table) and bndry (top of hash table)
     *
 1029          MCW  kless,0&X3
 1036          MCW  83,toconv
 1043          B    conv5     Convert topcor-1 to decimal
 1047          MCW  w5,diff
 1054          MCW  topcd9,toconv  Convert topcd9 to decimal
 1061          B    conv5
 1065          S    w5,diff   diff = topcor-1 - topcd9
 1072          A    diff-1,w6   diff / 10
 1079          A    w6          diff / 5
 1083          A    diff-1,w6   diff / 5 + diff / 10 = 3 * diff / 10
 1090          A    w5,w6       topcd9 + diff * 0.3
 1097          MCW  w6-3,x3     (topcd9 + diff * 0.3) / 1000
 1104          A    x3          2 * (topcd9 + diff * 0.3) / 1000
 1108          MZ   zones-31&X3,w6-2
 1115          MZ   zones-30&X3,w6  to machine address
 1122          MCW  w6,x3
 1129          SW   2&X3
 1133          MCW  kless
 1137          SBR  bndry
 1141          MCW  x1,x2
 1148          MN   0&X2
 1152          SAR  x1
     *
     * Done
     *
 1156          BSS  snapsh,C
 1161          SBR  tpread&6,beginn
 1168          SBR  clrbot
 1172          SBR  loadxx&3,857
 1179          SBR  clearl&3,gmwm
 1186          LCA  varbl3,phasid
 1193          B    loadnx
     *
     * Program is too big
     *
 1197toobig    CS   332
 1201          CS
 1202          CC   1
 1204          MCW  error2,270
 1211          W
 1212          CC   1
 1214          BCE  halt,cdovly,1
 1222          RWD  1
 1227halt      H    halt
     *
     * Convert toconv from machine to decimal
     *
 1231conv5     SBR  convx&3
 1235          MN   toconv,w5
 1242          MN
 1243          MN
 1244          MCW
 1245          MZ   toconv,zones-32
 1252          MZ   toconv-2,zones-33
 1259          NOP  zones-34
 1263          SAR  x3
 1267convl     C    4&X3,zones-32  look for correct zones
 1274          SAR  x3
 1278          A    kp1,w5-3   add one to thousands
 1285          BU   convl
 1290          MZ   kb1,w5-3
 1297convx     B    0
     *
     * Data
     *
 1305toconv    DCW  @0J   @
 1339zones     DCW  @9999Z9R9I99ZZZRZIZ9RZRRRIR9IZIRIII@
 1342tblbot    DCW  #3
 1345kfree     DSA  frebot
 1346kless     DCW  @<@
 1351w5        DCW  #5
 1357w6        DCW  #6
 1366varbl3    DCW  @VARBL TRI@
 1402error2    DCW  @MESSAGE 2 - OBJECT PROGRAM TOO LARGE@
 1403kp1       dcw  &1
 1404kb1       DCW  #1
 1405gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
