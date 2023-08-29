               JOB  Fortran compiler -- Sort two phase -- phase 05
               CTL  6611
     *
     * SORT TWO phase: Add three characters to each statement and
     * chain statements of the same type together, leaving the
     * address of the first statement of each type in TYPTAB,
     * which starts at 838.
     * x1 has the address of the group mark word mark after (lower
     * address) the last (lowest address) statement.
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
     typtab    equ  840  Type table (word marks set in Phase 3)
     *                 Indexed by 30*(zone of statement code) +
     *                 3*(numeric part of statement code).  Each
     *                 entry is the address of the earliest (highest
     *                 address) statement of a type.  Each statement
     *                 has a pointer to the next one (lower in core)
     *                 of the same type as its first three (highest
     *                 address) characters.
     *
     110       dcw  @sort 2@
     *
     * X1 is the address at the bottom of the last statement
     * X2 is X1 - 3*(number of statements)
     *
               ORG  1022
     loaddd    equ  *&1          Load address
 1022beginn    MCW  x1,x3
 1029          SW   gm
 1033          MCM  0&X1  Address at bottom of next statement
 1037          MN         Address of GM below next statement
 1038          MN         Address at top of this statement
 1039          SAR  x1
 1043          LCA  0&X1,stmt  Save this statement
 1050          MCM  0&X1  Address at bottom of next statement
 1054          SAR  x1
 1058          MCM  0&X3,0&X2  Move down by 3*(statement number)
 1065          SBR  x2
 1069          LCA  stmt&3,1&X2  Move again, this time with its gm
 1076          S    x3&1         clear x3
 1080          MCW  0&X2,work6   Copy statement number and stmt code
 1087          MN   work6-5,x3   Numeric part of statement code
 1094          MCW  x3,work6-2
 1101          A    x3
 1105          A    work6-2,x3   X3 = 3*(numeric part of stmt code)
 1112          BWZ  over,work6-5,2  Stmt type has no zone
 1120          A    kp30,x3
 1127          BWZ  over,work6-5,S  Stmt type has A zone
 1135          A    kp30,x3
 1142          BM   over,work6-5    Stmt type has B zone
 1150          A    kp30,x3
     *
     * Here X3 is 30*(zone of stmt code) + 3*(numeric part of stmt code)
     * Work is initially an array of 3-character empty fields, but
     * we store the address of each record in typtab&x3, resulting in
     * statements of the same type code being chained together
     *
 1157over      MCW  typtab&X3,1&X2  Link statement to next statement
 1164          LCA  gm,2&X2  Mark bottom of next statement
 1171          SBR  typtab&X3  Save statement address in typtab
 1175          MCM  2&X2     Move X2 above new statement bottom
 1179          SAR  x2
 1183          C    x2,topcor  Done?
 1190          BU   beginn   No, do another one
     *
     * Done -- load next overlay
     *
 1195          BSS  snapsh,C
 1200          SBR  clearl&3,2899
 1207          LCA  sort3,phasid
 1214          B    loadnx
     *
     * Data
     *
 1218          DCW  0
 1219gm        dc   @}@
     stmt      equ  1919  Save area for statement
               ORG  2000
 2005work6     DCW  #6
 2007kp30      dcw  &30
 2013sort3     DCW  @SORT 3@
 2014gmwm      dcw  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
