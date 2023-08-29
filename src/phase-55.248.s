               JOB  Fortran compiler -- Replace phase 2 -- Phase 55
               CTL  6611
     *
     * Address of the fixed- and floating-word work-areas are
     * inserted into the generated object program.  Instructions
     * which branch to the relocatable routines are corrected to
     * show the object core-storage addresses of these routines.
     * Unused core storage is cleared.
     *
     x1        equ  89
     x2        equ  94
     x3        equ  99
     *
     * Stuff in the resident area
     *
     phasid    equ  110  Phase ID, for snapshot dumps
     subent    equ  191  Entry to subscript routine, from subsc
     snapsh    equ  333  Core dump snapshot
     topcor    equ  688  Top core address from PARAM card
     loadnx    equ  700  Load next overlay
     clearl    equ  707  CS at start of overlay loader
     tpread    equ  780  Tape read instruction in overlay loader
     loadxx    equ  793  Exit from overlay loader
     clrbot    equ  833  Bottom of core to clear in overlay loader
     *
     * Stuff in phase 52A
     *
     subsc     equ  909   subscript entry in function table
     conbot    equ  930   bottom of constants - 1
     arybot    equ  933   bottom of arrays - 1
     *
     * Runtime addresses
     *
     aritf     equ  700  Arithmetic interpreter
     fmtbas    equ  1697  base address for limited and normal
     *
               ORG  934
  934beginn    SBR  sx3,1&X3
  941          SW   1&X3
  945          SBR  sx2,0&X2
  952          SBR  sx1,0&X1
  959          MCW  topcor,x2
  966          C    0&X2
  970          C
  971          C
  972          SBR  1393
  976          MCW  86,x2
  983          MN   0&X2
  987          SAR  sx2a
     *
     * Go through the relocatable library looking for codes
     * that indicate various kinds of relocation:
     * T with a word mark means A is an address in the function
     *   table; convert the T to a B.
     *
  991loop      C    x3,sx2
  998loopt     BE   loopx
 1003          C    0&X3
 1007          SBR  x2
 1011          SBR  x3
 1015          BCE  transf,1&X3,T  op code is T?
 1023checka    MCW  4&X3,w3        check A field address
 1030          BCE  semund,w3-2,;  semicolon?
 1038          BCE  semund,w3-2,_  underscore?
 1046          BCE  rbrack,w3-2,]  right bracket?
 1054          MCW  w3,4&X3        W3 back to A address
 1061checkb    MCW  7&X3,w3        check B field address
 1068          BCE  semund,w3-2,;  semicolon?
 1076          BCE  semund,w3-2,_  underscore?
 1084          MCW  w3,7&X3        W3 back to B address
 1091          B    loop
     *
     * Replace T XXX with B YYY where YYY is taken from XXX.
     *
 1095transf    BCE  loop,4&X3,$
 1103          C    0&X3,baritf&3
 1110          BE   loop
 1115          BW   checka,4&X2  Not a transfer if any
 1123          BWZ                 of the next three
 1124          BWZ                   characters has a word mark
 1125          MCW  branch,1&X3  Convert to branch
 1132          MCW  4&X2,x1      table address to X1
 1139          MCW  0&X1,x1      table entry to X1 (why???)
 1146          MCW  x1,4&X2        and A address
 1153          B    checka
     *
     * Repeat the loop for the format code
     *
 1157loopx     MCW  apass3,loopt&3
 1164          MCW  sx1,x3
 1171          MCW  afmt,sx2
 1178          B    loop
     *
     * Clear unused core
     *
 1182pass3     MCW  sx3,x3
 1189          SBR  x3,1&X3
 1196          MZ   x3,k999a
 1203          MZ
 1204          MCW
 1205          MZ   83,k999b
 1212          MZ
 1213          MCW
 1214          C    k999a,k999b
 1221          BE   equal
 1226          MCW  83,x3
 1233clrhlp    CS   0&X3  clear hundred at a time
 1237          SBR  x3
 1241          C    x3,k999a
 1248          BU   clrhlp
 1253clr1lp    C    x3,sx3
 1260          BE   clrl1x
 1265          LCA  kb1,0&X3  clear
 1272          SBR  x3          one at
 1276          CW   1&X3          a time
 1280          B    clr1lp
     *
     * X3 and 83 in same hundreds
     *
 1284equal     MCW  83,x3
 1291          B    clr1lp
     *
     * Fill empty core with right brackets, except for the
     * last character, which gets a record mark.
     *
 1295clrl1x    MCW  83,x3
 1302          MCW  rm,0&X3
 1309          SBR  x3
 1313          MCW  krbrak,0&X3
 1320          MCW  0&X3
 1324          SBR  x3
 1328          LCA  kb1,2&X3
 1335          LCA  kb1
 1339          MCW  subsc,subent
 1346          BSS  snapsh,C
 1351          SBR  tpread&6,838
 1358          SBR  clrbot
 1362          SBR  loadxx&3,838
 1369          SBR  clearl&3,gmwm
 1376          LCA  snap,phasid
 1383          B    loadnx
     *
     * A field begins with right bracket
     *
 1387rbrack    SBR  4&X3,0
 1394          B    checkb
     *
     * A or B field begins with semicolon or underscore
     * Semicolon adds or subtracts next two digits to arubot.
     * Underscore adds or subtracts next two digits from conbot.
     * AB zone means add, else subtract.
     *
 1398semund    SBR  exit&3
 1402          MCW  conbot,x2
 1409          BCE  *&8,w3-2,_  underscore?
 1417          MCW  arybot,x2
 1424          BCE  nooff,w3,0  No offset if low order digit zero
 1432          BWZ  add,w3,B    Add unzoned offset 
 1440          SW   w3-1
 1444decr      A    kp1,w3      subtract
 1451          BWZ  decrx,w3,B    unzoned w3
 1459          MN   0&X2            from
 1463          SAR  x2                X2
 1467          B    decr
 1471decrx     CW   w3-1
 1475nooff     MCW  x2,w3
 1482exit      B    0
 1486add       MN   w3,rew3&6
 1493          MN
 1494rew3      SBR  w3,0&X2  x2 plus unzoned offset to w3
 1501          B    exit
     *
     * Data
     *
 1507k999a     DSA  999
 1510k999b     DSA  999
 1513sx3       DCW  #3
 1516sx2       DCW  #3
 1519sx1       DCW  #3
 1522sx2a      DCW  #3
 1525w3        DCW  #3
 1526baritf    B    aritf
 1530branch    B
 1533apass3    DSA  pass3
 1536afmt      DSA  fmtbas-1  one before format
 1537kb1       DCW  #1
 1538rm        DCW  @|@
 1539krbrak    DCW  @]@
 1547snap      DCW  @SNAPSHOT@
 1548kp1       dcw  &1
 1549gmwm      DCW  @}@
               ex   beginn
               END
