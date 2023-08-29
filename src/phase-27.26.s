               JOB  Fortran compiler -- List Phase Three -- phase 27
               CTL  6611
     *
     * Each input-output statement is reduced to the address of
     * the list string (when present), the format string (when
     * present), and the tape unit number (when applicable).
     *
     * On entry, x1 is the top of the top I/O statement and x2
     * is one below the table of I/O strings, formats and numbers.
     *
     * On exit, 83 is the top of code in high core and x2 is one
     * below the bottom of code in high core.
     *
     x1        equ  89
     x2        equ  94
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
     110       dcw  @listr tri@
     *
               ORG  845
     loaddd    equ  *&1          Load address
  845beginn    MCW  x2,83
  852          SW   gm
  856          LCA  gm,0&X2  GM below I/O string table
  863          SBR  x2
  867testio    BW   notio,0&X1
  875          B    move  move prefix
  879          B    move  move tape number and list (r/w tape),
     *                  tape number and format (r/w i/o tape),
     *                  or format (read/print/punch)
  883          BCE  testio,1&X2,}  End of statement?
  891          CW   1&X2
  895          C    0&X1  get down to wm
  899          SAR  x1
  903          SBR  x1,1&X1
  910          B    move  move list (r/w i/o tape) or only gmwm
  914          B    testio
     *
     * Not I/O, copy everything else
     *
  918notio     CW   0&X1
  922copy      BCE  done,0&X1,
  930          B    move  move prefix
  934          B    move  move body
  938          B    copy
     *
     * Move from code area to list area
     *
  942move      SBR  movex&3
  946          LCA  0&X1,0&X2
  953          SAR  x1
  957          C    0&X2
  961          SAR  x2
  965movex     B    0-0
     *
  969done      BSS  snapsh,D
  974          SBR  tpread&6,838
  981          SBR  clrbot
  985          SBR  loadxx&3,937
  992          SBR  clearl&3,gmwm
  999          LCA  stnum2,phasid
 1006          B    loadnx
     *
 1011gm        DCW  @ }@
 1017stnum2    DCW  @STNUM2@
 1018gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
