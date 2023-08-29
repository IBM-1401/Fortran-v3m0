               JOB  Fortran compiler -- Arith Phase Three -- phase 35
               CTL  6611
     *
     * Initialization for Arith Phase Four takes place.
     *
     * Stuff in the resident area
     *
     phasid    equ  110  Phase ID, for snapshot dumps
     snapsh    equ  333  Core dump snapshot
     loadnx    equ  700  Load next overlay
     clearl    equ  707  CS at start of overlay loader
     *
     110       dcw  @arith 3@
     *
               ORG  838
     loaddd    equ  *&1          Load address
  838beginn    BSS  snapsh,C
  843          SBR  clearl&3,gmwm
  850          LCA  arith4,phasid
  857          b    loadnx
  910          dc   #50
  960          dc   #50
 1010          dc   #50
 1060          dc   #50
 1067arith4    DCW  @ARITH 4@
 1068gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
