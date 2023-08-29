               JOB  Fortran compiler -- Continue Phase -- phase 45
               CTL  6611
     *
     * No object-time instructions are generated for these
     * statements.  This phase passes information required by
     * the Resort phases of the compiler.
     *
     x1        equ  89
     x3        equ  99
     *
     * Stuff in the resident area
     *
     phasid    equ  110  Phase ID, for snapshot dumps
     glober    equ  184  Global error flag -- WM means error
     snapsh    equ  333  Core dump snapshot
     loadnx    equ  700  Load next overlay
     clearl    equ  707  CS at start of overlay loader
     *
     110       dcw  @continue@
     *
               ORG  838
     loaddd    equ  *&1          Load address
  838beginn    BCE  done,0&X1,
  846          MCW  0&X1,codseq
  853          BCE  cont,codseq-3,C  Continue statement?
  861done      BSS  snapsh,C
  866          SBR  clearl&3,gmwm
  873          LCA  domsk,phasid
  880          B    loadnx
  884cont      LCA  0&X1,0&X3
  891          SAR  x1
  895          C    0&X3
  899          SAR  x3
  903          LCA  1&X1,2&X3  Replace statement code by gmwm
  910          C    0&X1
  914          SAR  x1
  918          B    beginn
     *
     * Data
     *
  925codseq    DCW  #4
  930domsk     DCW  @DOMSK@
  931gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
