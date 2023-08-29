               JOB  Fortran compiler -- Dimension phase two -- 12
               CTL  6611
     *
     * Arrays are assigned their object-time addresses.
     *
     * On entry, X3 is one below the group mark below the bottom of
     * the array table, and 86 is the address of the low-order digit
     * of the offset field of the topmost (first) array table entry
     * if there are any arrays, or blank if there is no array table.
     *
     * On exit the fixed-width fields of the array table elements are
     * the base address as five digits, the top address as three
     * characters with a type zone in the second character, the
     * array element width (imod or mantis&2) and junk, and the
     * address of the low-order digit of the first array element
     * as three characters with a type zone in the second character.
     *
     x1        equ  89
     x2        equ  94
     x3        equ  99
     *
     * Stuff in the resident area
     *
     phasid    equ  110  Phase ID, for snapshot dumps
     glober    equ  184  Global error flag -- WM means error
     arytop    equ  194  Top of arrays in object code
     snapsh    equ  333  Core dump snapshot
     topcor    equ  688  Top core address from PARAM card
     imod      equ  690  Integer modulus -- number of digits
     mantis    equ  692  Floating point mantissa digits
     fmtsw     equ  696  X for no format, L for limited format
     *                blank for ordinary, A for A conversion
     loadnx    equ  700  Load next overlay
     clearl    equ  707  CS at start of overlay loader
     *
     110       dcw  @dimen two@
     094       dcw  000
     096       dc   00
     *
               ORG  838
     loaddd    equ  *&1          Load address
  838beginn    BCE  ord,fmtsw,    Ordinary formatting?
  846          SBR  x2,base5a
  853          BCE  oth,fmtsw,A   A-conversion formatting?
  861          SBR  x2,base5l
  868          BCE  oth,fmtsw,L   Limited formatting?
  876          SBR  x2,base5x
  883          BCE  oth,fmtsw,X   No formatting?
  891ord       MCW  x3,83
  898          A    kp2,mantis  Add exponent width to mantissa width
  905          SW   gm
  909          LCA  gm,1&X3    Put a GMWM below bottom of array table
  916          BCE  noary,86,  No arrays?
  924          MCW  86,x3
  931again     S    w6
  935          MCW  6&X3,next
  942          BCE  noeqv,1&X3,   No equivalence class link?
  950          MCW  3&X3,x2     Next member of equivalence class
  957          ZA   0&X3,w10-4  Offset
  964          M    5&X2,w10-1
  971          A    0&X2,w10-1  Offset of next in equivalence class
  978          MCW  w10-1,0&X3
  985noeqvr    MCW  0&X3,w6
  992          SAR  x3
  996          S    kp1,w6
 1003          MCW  x3,x2
 1010more      MCM  2&X2      Get X2 above the GMWM
 1014          MN               and then
 1015          MN                 back down
 1016          SAR  x2              below it
 1020          BCE  more,1&X2,|
 1028          MCW  0&X2,ch   First character of variable name
 1035          MCW  ch,*&8
 1042          BCE  intvar,ijklmn,0  Integer variable?
 1050          B
 1051          B
 1052          B
 1053          B
 1054          B
 1055          A    mantis,w6    Floating point variable
 1062var       MCW  w6,14&X3     low-order to what was prev
 1069          MCW  w6-3,x2      Thousands to X2
 1076          A    x2           Double it
 1080          MZ   zones&X2,12&X3  Thousands zones
 1087          MZ   zones&1&X2,14&X3    to variable address
 1094          ZA   kz1,w10-4    Clear
 1101          MCW  0&X3,w10-4   Get first dimension
 1108          MCW  kb1            and a blank
 1112          SBR  prep&6
 1116          NOP  0&X3         Get X2          
 1120          MCW                 down to
 1121          SAR  x2               second dimension
 1125          BCE  nodim2,0&X2,}  No second dimension if GM?
 1133prep      MCW  0&X2,0-0
 1140          M    0&X3,w10-4
 1147nodim2    LCA  kb3,8&X3     Clobber equivalence link
 1154          MCW  x1,sx1       Save x1
 1161          MCW  14&X3,x1     Address to x1
 1168          MCW  ch,*&8
 1175          BCE  intvr2,ijklm2,0  Integer variable?
 1183          B
 1184          B
 1185          B
 1186          B
 1187          B
 1188          M    mantis,w10-1  First dimension * width
 1195          MZ   kzab,7&X3     Mark floating-point zone
 1202          MCW  mantis,10&X3
 1209var2      MZ   7&X3,13&X3    Copy type zone
 1216          MCW  sx1,x1
 1223          S    10&X3,w6      Subtract variable width
 1230          A    w10-1,w6
 1237          MN   w6,8&X3       Low-order digits
 1244          MN                   to what was the
 1245          MN                     equivalence class link
 1246          SAR  *&4
 1250          MCW  0-0,x2
 1257          MCW  kz1
 1261          A    x2
 1265          MZ   zones&1&X2,8&X3
 1272          CW                 why not
 1273          SBR  *&7             just
 1277          MZ   zones&X2,0        MZ   ZONES&X2,6&X3 ?
 1284          A    kp1,w6
 1291          S    w6,base5    compute base5 = max(base5,w6)
 1298          BM   negdif,base5
 1306          A    w6,base5
 1313tstmor    BCE  nomore,next,  No more arrays if next is blank
 1321          MCW  next,x3
 1328          B    again
     *
 1332intvar    A    imod,w6
 1339          B    var
     *
     * At the end of an equivalence class (maybe the only one
     * in it).
     *
 1343noeqv     MCW  base5,0&X3
 1350          B    noeqvr
     *
 1354negdif    MCW  w6,base5
 1361          B    tstmor
     *
 1365intvr2    M    imod,w10-1   First dimension * width
 1372          MZ   kzb,7&X3     Mark integer zone
 1379          MCW  imod,10&X3
 1386          B    var2
     *
     * No more array table elements
     *
     * Convert topcor to five digits
     *
 1390nomore    S    w2a
 1394          S    w2b
 1398          MZ   topcor,w2a-1
 1405          MZ   topcor-2,w2b-1
 1412loop1k    BWZ  mod4,w2b-1,2  multiple of 4k?
 1420          A    ka0,w2b
 1427          B    loop1k
 1431mod4      BWZ  below4,w2a-1,2
 1439          A    kq4,w2a
 1446          B    mod4
 1450below4    A    w2b-1,w2a
 1457          MCW  topcor,top5
 1464          MCW  w2a
 1468          ZA   top5
 1472          MZ   *-4,top5
     *
     * Test for too big program
     *
 1479          S    base5,top5  topcor - top of arrays
 1486          S    kp1,top5
 1493          BM   toobig,top5
 1501          MN   top5,top3   low-order
 1508          MN                 digits of
 1509          MN                   free space
 1510          SAR  *&4
 1514          MCW  0-0,x2      thousands to x2
 1521          MCW  kz1           and a zero
 1525          A    x2          double it
 1529          MZ   zones&1&X2,top3
 1536          CW               why not
 1537          SBR  *&7           just
 1541          MZ   zones&X2,0      MCW  ZONES&X2,TOP3-2?
 1548          MCW  base3,arytop
 1555          MA   top3,arytop
 1562          B    notbig
 1566toobig    BW   notbig,w10  Don't repeat error message
 1574          CS   332
 1578          CS
 1579          MCW  error2,270
 1586          W
 1587          SW   glober,w10     set global and don't repeat flags
 1594          S    top5
 1598noary     MCW  topcor,arytop
 1605notbig    MCW  base3,86
 1612          CC   L
 1614          BCV  *&5
 1619          B    *&3
 1623          CC   1
 1625          CS   332
 1629          CS
 1630          MCW  storge,247
 1637          W
 1638          CC   J
 1640          MCW  83,x3
     *
     * Print the arrays and their addresses
     *
 1647nother    NOP  10&X3
 1651          MCM
 1652          SAR  x3
 1656          CS   299
 1660more3     BCE  more2,0&X3,|
 1668          B
 1669          MN   0&X3
 1673          MN
 1674          SAR  x3
 1678          BCE  noarys,0&X3,:   No arrays if colon
 1686          MN   201
 1690          MN
 1691          SAR  x2
 1695          SBR  x3,0&X3
     *
     * Move variable to print area -- need to reverse it
     *
 1702move      MCW  0&X3,ch2
 1709          SAR  x3
 1713          MCW  ch2,2&X2
 1720          SBR  x2
 1724          BW   movfin,1&X3
 1732          B    move
 1736movfin    C    0&X3      Skip
 1740          C                the
 1741          C                  fixed
 1742          C                    width
 1743          SAR  x2                fields
 1747          A    top5,5&X2
 1754          MA   top3,8&X2
 1761          MA   top3,14&X2
 1768          MCS  5&X2,218
 1775          MCW  8&X2,234
 1782          MZ   kb1,233
 1789          SW   220
     *
     * Convert top address of array to five digits
     *
 1793          S    w2c
 1797          S    w2d
 1801          MZ   8&X2,w2c-1
 1808          MZ   6&X2,w2d-1
 1815lp1ka     BWZ  mod4a,w2d-1,2  Multiple of 4k?
 1823          A    ka0,w2d
 1830          B    lp1ka
 1834mod4a     BWZ  low4,w2c-1,2
 1842          A    kq4,w2c
 1849          B    mod4a
 1853low4      A    w2d-1,w2c
 1860          MCW  8&X2,224
 1867          MCW  w2c
 1871          ZA   224
 1875          MZ   *-4,224
 1882          MCW  hyphen,219
 1889          MN   5&X2,230
 1896          MN
 1897          MN
 1898          SAR  *&4
 1902          MCW  0,x2
 1909          MCW  kz1
 1913          A    x2
 1917          MZ   zones&1&X2,230
 1924          CW
 1925          SBR  *&7
 1929          MZ   zones&X2,0
 1936          BCV  *&5
 1941          B    *&3
 1945          CC   1
 1947          W
 1948          CS   299
 1952          MCM  1&X3
 1956          SAR  x3
 1960          BCE  done,0&X3,
 1968          B    nother  Do another one
     *
 1972more2     MCM  0&X3
 1976          SBR  x3
 1980          B    more3
     *
     * Print No Arrays message
     *
 1984noarys    CS   332
 1988          CS
 1989          MCW  noarym,209
 1996          W
 1997          BCV  *&5
 2002          B    done
 2006          CC   1
     *
     * Done
     *
 2008done      CC   L
 2010          BSS  snapsh,E
 2015          SBR  clearl&3,gmwm
 2022          LCA  varbl1,phasid
 2029          B    loadnx
     *
     * Formatting other than ordinary formatting
     *
 2033oth       MCW  0&X2,base3  Base address
 2040          MCW                and decimal equivalent & 1
 2041          B    ord
     *
     * Data
     *
 2049base5     DCW  04280  Decimal format base address for arrays
     *                   Eventually, 1 above top of arrays
 2052base3     DSA  4279   Base5 - 1 in machine address format
 2057          DCW  04617
 2060base5a    DSA  4616   A format base address for arrays
 2065          DCW  02016
 2068base5l    DSA  2015   L format base address for arrays
 2073          DCW  01697
 2076base5x    DSA  1696   X (no) format base address for arrays
 2081top5      DCW  00000  topcor as five digits     
 2084top3      DCW  000    topcor less arrays as 3 characters
 2085gm        dc   @}@
 2095w10       DCW  #10
 2096kb1       DCW  #1
 2098zones     DCW  @ 9@
 2129          DCW  @9Z9R9I99ZZZRZIZ9RZRRRIR9IZIRIII@
 2130kp2       dcw  &2
 2136w6        DCW  #6
 2139next      DCW  #3
 2140kp1       dcw  &1
 2141ch        DCW  #1
 2147ijklmn    DCW  @IJKLMN@
 2148kz1       DCW  0
 2151kb3       DCW  #3
 2154sx1       DCW  #3  Save area for X1
 2160ijklm2    DCW  @IJKLMN@
 2161kzab      dcw  &1  A and B zones
 2162kzb       DCW  -1  B zone
 2164w2a       DCW  #2
 2166w2b       DCW  #2
 2168ka0       dcw  @A0@
 2170kq4       dcw  @?4@
 2206error2    DCW  @MESSAGE 2 - OBJECT PROGRAM TOO LARGE@
 2251storge    DCW  @STORAGE ASSIGNMENT-ARRAYS & EQUATED VARIABLES@
 2252ch2       DCW  #1
 2254w2c       DCW  #2
 2256w2d       DCW  #2
 2257hyphen    DCW  @-@
 2266noarym    DCW  @NO ARRAYS@
 2272varbl1    DCW  @VARBL1@
 2273gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
