               JOB  Fortran compiler -- Reloading Snapshot -- Phase 53R
               CTL  6611
     *
     * The snapshot coding which was replaced by 52B is retained.
     * If a snapshot is requested for phases 52 and 53, it is taken
     * at this point.
     *
     * Stuff in the resident area
     *
     phasid    equ  110  Phase ID, for snapshot dumps
     snapsh    equ  333  Core dump snapshot
     xqtd      equ  680  GMWM should be D in EXECUTED
     loadnx    equ  700  Load next overlay
     clearl    equ  707  CS at start of overlay loader
     tpread    equ  780  Tape read instruction in overlay loader
     loadxx    equ  793  Exit from overlay loader
     clrbot    equ  833  Bottom of core to clear in overlay loader
     *
     110       dcw  @reload ss@
     *
               ORG  934
     loaddd    equ  *&1          Load address
  934beginn    B    begin1
     *
     * Load the format package
     *
  938begin2    MCW  d,xqtd  Replace GMWM with D making EXECUTED
  945          CW   xqtd      and clear the WM
  949          BSS  snapsh,C
  954          SBR  tpread&6,beginn
  961          SBR  clrbot
  965          SBR  loadxx&3,beginn
  972          SBR  clearl&3,gmwm
  979          LCA  format,phasid
  986          B    loadnx
  990D         dcw  @D@
  999format    DCW  @FORMATPAK@
     *
     * Reload the snapshot phase 53S
     *
 1000begin1    SBR  tpread&6,snapsh
 1007          SBR  clrbot,begin1
 1014          SBR  loadxx&3,begin2
 1021          SBR  clearl&3,gmwm
 1028          LCA  snap53,phasid
 1035          B    loadnx
 1048snap53    DCW  @SNAPSHOT53@
               ORG  1696
 1696gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
