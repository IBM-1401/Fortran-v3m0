               JOB  Fortran compiler -- Sort three phase -- phase 06
               CTL  6611
     *
     * SORT THREE phase: Sort statements by type, shift to low
     * memory.
     * 81-83 is the address of the last character (lowest in core,
     * one above gmwm) of the last (lowest in core) statement.
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
     typtab    equ  840  Type table (word marks set in Phase 3)
     *                 Indexed by 30*(zone of statement code) +
     *                 3*(numeric part of statement code).  Each
     *                 entry is the address of the earliest (highest
     *                 address) statement of a type.  Each statement
     *                 has a pointer to the next one (lower in core)
     *                 of the same type as its first three (highest
     *                 address) characters.
     *
     110       dcw  @sort 3@
     *
               ORG  1022
     loaddd    equ  *&1          Load address
 1022beginn    MCW  83,x3  Address at end of last statement
 1029          SW   gm
 1033          SBR  x1,2899  Bottom of free storage
 1040          SW   2900
 1044          MN   0&X3   Compute address below last statement,
 1048          LCA  gm       put a gmwm there
 1052          SBR  save&6     and store address below gmwm
 1056          SBR  w3,tabixs  Get last typtab index
 1063loop      MCW  w3,x3      Get next head
 1070          MCW  0&X3,x3      of chain to x3
 1077          SAR  w3
 1081          BCE  done,x3,X  End of the table?
 1089          MCW  typtab&X3,x3  Head of list of statements of type
 1096          BCE  loop,x3,   No statements of the type
     *
     * Move all statements of the type down to low core
     *
 1104save      MCW  0&X3,0-0   Move statement to save area
 1111          SAR  x2
 1115          BCE  *&5,1&X2,}  Did we move the GM?
 1123          B    noroom     No, maybe we're out of space
 1127          SBR  x2,2&X2    Get back above gmwm, to bottom of stmt
 1134more      MCM  0&X2       Compute address above top of statement
 1138          SBR  sx2&6        and save it
 1142          MCM  0&X2,1&X1  Move statement to bottom of free area,
 1149          SBR  x1           bump pointer to bottom,
 1153          MN   0&X1           then back down to GM
 1157          SBR  x1               and save it
 1161sx2       SBR  x2,0-0     Move up to record mark or GM
 1168          BCE  more,0&X1,|  More to go if stmt contains RM
 1176          SBR  x1,1&X1    Bump pointer above GM
 1183          CW   bigflg
 1187          MN   0&X1       Now subtract
 1191          MN                four from
 1192          MN                  x1 to recover
 1193          MN                    space used for
 1194          SAR  x1                 same-type link
 1198          LCA  gm,0&X1    Mark top of statement
 1205          SBR  83         Store address of top of statement
 1209          SBR  x1           and in x1
 1213more2     MCM  1&X1       Compute address above top of statement,
 1217          MN                get back down to RM or GMWM
 1218          SAR  x1             and save it
 1222          BCE  more2,0&X1,|  More to go if stmt contains RM
 1230          MN   0&X3       Subtract
 1234          MN                six
 1235          MN                  from
 1236          MN                    x3
 1237          MN                    ,,
 1238          MN                    ,,
 1239          SAR  x3               ,,
 1243          MN   0&X1       Compute -1&x1 into B-star
 1247          LCA  3&X3       Copy sequence number
 1251          MCW  pound,0&X3
 1258more3     MCM  2&X3       Point x3
 1262          MN                back at
 1263          MN                  top of
 1264          SAR  x3               statement
 1268          BCE  more3,1&X3,|  More to go if stmt contains RM
 1276          BCE  loop,0&X3,  Last statement on chain?
 1284          MCW  0&X3,x3     No, get next statement in chain
 1291          B    save          and save it
     *
     * No room to move statement below bottom statement
     *
 1295noroom    BW   toobig,bigflg
 1303          SW   bigflg
 1307          MCW  topcor,x2
 1314          MN   0&X2
 1318          SAR  x2         X2 is topcor-1 now
 1322          MCW  x2,x3
 1329moveup    LCA  0&X2,0&X3  Move statement up
 1336          SAR  x2
 1340          MCW  0&X3,prefix
 1347          BCE  moved,prefix-6,#  Statement already moved?
 1355          LCA  0&X3,0&X3  No, decrement X3 so as not to
 1362          SAR  x3           clobber recently moved statement
 1366moved     C    save&6,x2  Done?
 1373          BU   moveup     No, move another one
 1378          MCW  x3,save&6  Below last moved statement
 1385          MCW  x3,x2
 1392          MZ   x3,x3999   compute x3 & x00 - 1
 1399          MZ
 1400          MCW
 1401          MZ   x1,x1999   compute x1 & x00 - 1
 1408          MZ
 1409          MCW
 1410          C    x1999,x3999
 1417          BE   noclr
 1422clr       CS   0&X3       Clear from x3 down to x1 & x00
 1426          SBR  x3
 1430          C    x3,x1999
 1437          BU   clr
 1442noclr     ZA   tablen,tabcnt  Table length to table counter
 1449          S    x3&1
     *
     * Fill type table with blanks
     *
 1453clrtab    MCW  kb3,typtab&X3  Mark end of chain
 1460          S    kp1,tabcnt
 1467          BM   clrfin,tabcnt  Done clearing table?
 1475          A    kp3,x3
 1482          B    clrtab
     *
     * Relink moved statements into type table
     *
 1486clrfin    MCM  1&X2       Get X1 to top of statement
 1490          MN
 1491          SAR  x2
 1495          BCE  clrfin,0&X2,|  More to do if RM instead of GMWM
 1503          SBR  x2,1&X2    X2 is now bottom of next statement
 1510          S    x3&1
 1514          C    0&X2
 1518          SAR  *&4
 1522          MCW  0-0,prefix   Save prefix
 1529          MN   prefix-6,x3  3 times
 1536          MCW  x3,tabcnt      numeric part of
 1543          A    x3               statement code
 1547          A    tabcnt,x3          to x3
 1554          BWZ  zonfin,prefix-6,2  add 30 times
 1562          A    kp30,x3              zone part
 1569          BWZ  zonfin,prefix-6,S      of statement
 1577          A    kp30,x3                  code
 1584          BM   zonfin,prefix-6            to x3
 1592          A    kp30,x3
 1599zonfin    MN   0&X2       minus 2
 1603          MN
 1604          MCW  typtab&X3  Link to next statement same type
 1608          C    0&X2       Down to next word mark
 1612          SAR  typtab&X3  link type table to statement type
 1616          C    x2,topcor  Done?
 1623          BU   clrfin
 1628          MCW  w3,x3      Recover x3
 1635          NOP  3&X3
 1639          SAR  w3           plus 3
 1643          B    loop       Back to sorting
     *
     * Load next overlay
     *
 1647done      BSS  snapsh,C
 1652          SBR  tpread&6,typtab-2  Next overlay read address
 1659          SBR  clrbot               and bottom of clear area
 1663          SBR  loadxx&3,typtab-2  Next overlay entry address
 1670          SBR  clearl&3,tabcnt    Top of clear
 1677          LCA  gmmsg,phasid       Next phase ID
 1684          B    loadnx             Load it
     *
     * Program is too big
     *
 1688toobig    CS   332
 1692          CS
 1693          CC   1
 1695          MCW  msg2,270
 1702          W
 1703          CC   1
 1705          BCE  halt,cdovly,1
 1713          RWD  1
 1718halt      H    halt
     *
     * Data
     *
     * First is table of table indexes in the reverse order
     * we want statements sorted into low core
     *
 1724          dcw  @XXX@  End-of-table sentinel
 1727          DSA  117  I DIMENSION
 1730          DSA  84   Q
 1733          DSA  108  F FORMAT
 1736          DSA  9    3 WRITE TAPE
 1739          DSA  3    1 READ
 1742          DSA  18   6 WRITE OUTPUT TAPE
 1745          DSA  81   M
 1748          DSA  42   U PUNCH
 1751          DSA  15   5 READ INPUT TAPE
 1754          DSA  69   L
 1757          DSA  87   R ARITHMETIC
 1760          DSA  105  E IF
 1763          DSA  27   9
 1766          DSA  96   B BACKSPACE
 1769          DSA  57   Z REWIND
 1772          DSA  75   N ENDFILE
 1775          DSA  39   T COMPUTED GOTO
 1778          DSA  111  G GOTO
 1781          DSA  36   S STOP
 1784          DSA  93   A PAUSE
 1787          DSA  63   J SENSE LIGHT
 1790          DSA  66   K IF SENSE LIGHT
 1793          DSA  48   W IF SENSE SWITCH
 1796          DSA  99   C CONTINUE
 1799tabixs    DSA  102  D DO                 Last of table indexes
     *
 1802x1999     DSA  999  x1 & x00 - 1
 1805x3999     DCW  999  x3 & x00 - 1
 1806gm        dc   @}@
 1807bigflg    dc   0  Word mark set if too big
 1810w3        DCW  #3
 1811pound     dcw  @#@
 1820prefix    DCW  #9         Statement prefix
 1822tablen    dcw  &39        Type table length
 1825kb3       DCW  #3         three blanks -- end of chain sentinel
 1826kp1       dcw  &1
 1827kp3       dcw  &3
 1829kp30      dcw  &30
 1839gmmsg     DCW  @GROUP MARK@
 1875msg2      DCW  @MESSAGE 2 - OBJECT PROGRAM TOO LARGE@
               ORG  2001
 2003tabcnt    DCW  #3
               org  2900
 2900gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
