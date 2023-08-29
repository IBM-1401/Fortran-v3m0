               JOB  Fortran compiler -- GOTO Phase -- phase 41
               CTL  6611
     *
     * An unconditional branch instruction is generated in-line
     * in place of the original statement
     *
     x1        equ  89
     x3        equ  99
     *
     * Stuff in the resident area
     *
     phasid    equ  110  Phase ID, for snapshot dumps
     snapsh    equ  333  Core dump snapshot
     loadnx    equ  700  Load next overlay
     clearl    equ  707  CS at start of overlay loader
     *
     110       dcw  @gomsk@
     *
               ORG  838
     loaddd    equ  *&1          Load address
  838loop      BCE  done,0&X1,
  846          MCW  0&X1,codseq
  853          BCE  goto,codseq-3,G  goto statement?
  861done      BSS  snapsh,C
  866          SBR  clearl&3,gmwm
  873          LCA  stoppz,phasid
  880          B    loadnx
     *
  884goto      LCA  0&X1,0&X3  seqno, code, gmwm
  891          SAR  x1
  895          C    0&X3
  899          SAR  x3
  903          LCA  1&X3,2&X3  move gmwm up
  910          SBR  x3
  914          LCA  0&X1,0&X3  move label up
  921          SAR  x1
  925          C    0&X3
  929          SAR  x3
  933          MCW  branch,1&X3  replace gmwm by branch
  940          LCA  1&X1           with the gmwm below it
  944          SBR  x3
  948          MZ   x2zone,4&X3
  955          B    loop
     *
     * Data
     *
  962codseq    DCW  #4  statement code and sequence number
  972stoppz    DCW  @STOP/PAUSE@
  973branch    B
  974x2zone    DCW  @K@
  975gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   loop
               END
