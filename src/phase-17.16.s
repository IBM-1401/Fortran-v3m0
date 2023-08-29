               JOB  Fortran compiler -- Variables Phase 5 -- 17
               CTL  6611
     *
     * A check is made for unreferenced variables
     *
     x1        equ  89
     x2        equ  94
     x3        equ  99
     *
     * On entry and exit, X1 is the top of code, topcor is the top of
     * the symbol table, and 83 is the bottom of the symbol table.
     *
     * Each element of the scalar symbols table consists of the
     * three-character run-time address, with a word mark under
     * the first character, a group mark, with a word mark under
     * it if the variable is not referenced, and the variable, with
     * characters reversed.
     *
     * Stuff in the resident area
     *
     phasid    equ  110  Phase ID, for snapshot dumps
     snapsh    equ  333  Core dump snapshot
     topcor    equ  688  Top core address from PARAM card
     loadnx    equ  700  Load next overlay
     clearl    equ  707  CS at start of overlay loader
     tpread    equ  780  Tape read instruction in overlay loader
     loadxx    equ  793  Exit from overlay loader
     clrbot    equ  833  Bottom of core to clear in overlay loader
     *
     110       dcw  @varbl quin@
     *
               ORG  857
     loaddd    equ  *&1          Load address
  857beginn    CC   J
  859          MCW  x1,sx1         Memorize top of code
  866          MCW  topcor,x2      Top of symbol table
  873loop      BCE  tabent,0&X2,}  GM means bottom of sym tab name
  881          SBR  x2
  885          C    x2,83          Bottom of symbol table?
  892          BU   loop           No
     *
     * Done
     *
  897          MCW  sx1,x1         Recall top of code
  904          BSS  snapsh,D
  909          SBR  tpread&6,838
  916          SBR  clrbot
  920          SBR  loadxx&3,838
  927          SBR  clearl&3,2698
  934          LCA  const1,phasid
  941          B    loadnx
     *
     * X2 is at GM below a name in the symbol table
     *
  945tabent    BW   unref,0&X2     Unreferenced if GM has WM
  953          MN   0&X2
  957          SBR  x2
  961          B    loop
     *
     * Unreferenced symbol
     *
     * Move X3 (initially X2) up to WM above symbol
     *
  965unref     CS   299
  969          MCW  err11,233
  976          MCW  x2,x3
  983loopu     NOP  1&X3           Why not
  987          SAR  x3               just SBR  X3,1&X3?
  991          BW   *&5,2&x3       At WM above symbol?
  999          B    loopu
 1003          MN   234            Why not
 1007          MN                    just
 1008          SAR  x1                 SBR  X1,232?
 1012          SBR  x3,1&X3
 1019loopw     MCW  0&X3,ch        Move symbol
 1026          SAR  x3               to print
 1030          MCW  ch,2&X1            line while
 1037          SBR  x1                   reversing characters
 1041          BW   *&5,1&X3               to correct
 1049          B    loopw                    order
 1053          W
 1054          BCV  *&5
 1059          B    *&3
 1063          CC   1
 1065          MN   0&X2
 1069          SAR  x2
 1073          B    loop
     *
     * Data
     *
 1079sx1       DCW  #3
 1088const1    DCW  @CONST ONE@
 1121err11     DCW  @ERROR 11 - UNREFERENCED VARIABLE @
 1122ch        DCW  #1
 1123gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
