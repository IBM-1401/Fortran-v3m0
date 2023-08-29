               JOB  Fortran compiler -- Variables Phase 3 -- 15
               CTL  6611
     *
     * This phase does housekeeping for Variables Phase 4
     *
     * On entry, X2 is one above the prefix of the topmost statement
     *
     x2        equ  94
     *
     * Stuff in the resident area
     *
     phasid    equ  110  Phase ID, for snapshot dumps
     snapsh    equ  333  Core dump snapshot
     loadnx    equ  700  Load next overlay
     clearl    equ  707  CS at start of overlay loader
     tpread    equ  780  Tape read instruction in overlay loader
     clrbot    equ  833  Bottom of core to clear in overlay loader
     *
     frebot    equ  2699
     *
     110       dcw  @varbl tri@
     099       dcw  000
     100       dc   0
     *
               ORG  849
     loaddd    equ  *&1          Load address
  853codsiz    DCW  #5  Code size, 84-86, in decimal
  856topcod    DCW  #3  Top of code & 1
  857beginn    CC   L
  859          CS   332
  863          CS
  864          MCW  msg,237
  871          W
  872          CC   J
  874          MCW  kb1,frebot
  881          MCW  x2,topcod
     *
     * Convert code size (84-86) to decimal
     *
  888          S    w2h
  892          S    w2l
  896          MZ   86,w2h-1
  903          MZ   84,w2l-1
  910l1        BWZ  l2,w2l-1,2
  918          A    ka0,w2l
  925          B    l1
  929l2        BWZ  l2x,w2h-1,2
  937          A    kq4,w2h
  944          B    l2
  948l2x       A    w2l-1,w2h
  955          MCW  86,codsiz
  962          MCW  w2h
  966          ZA   codsiz
  970          MZ   *-4,codsiz
     *
     * Done
     *
  977          BSS  snapsh,C
  982          SBR  tpread&6,beginn
  989          SBR  clrbot
  993          SBR  clearl&3,frebot
 1000          LCA  varbl4,phasid
 1007          B    loadnx
     *
     * Data
     *
 1047msg       DCW  @STORAGE ASSIGNMENT - SIMPLE VARIABLES@
 1048kb1       DCW  #1
 1050w2h       DCW  #2
 1052w2l       DCW  #2
 1054ka0       DCW  @A0@
 1056kq4       DCW  @?4@
 1066varbl4    DCW  @VARBL QUAD@
 1067gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
