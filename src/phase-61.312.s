               JOB  Fortran compiler -- GEAUX phase one -- Phase 61
               CTL  6611
     *
     * This phase prints the end of compilation message, initializes
     * the sense lights, and prepares the branch into the object
     * program coding.
     *
     x1        equ  89
     *
     * Addresses in the resident area
     *
     nstmts    equ  183  Number of statements, including generated stop
     *                 Beginning of code by now
     glober    equ  184  Global error flag -- WM means error
     gotxl     equ  185  XLINKF was referenced if no WM
     snapsh    equ  333  Core dump snapshot
     phasld    equ  381  Loads phase ID in snapshot
     snapex    equ  564  Halt end exit in snapshot
     condns    equ  693  P for condensed deck
     loadnx    equ  700  Load next overlay
     clearl    equ  707  CS at start of overlay loader
     cdovly    equ  769  1 if running from cards, N if from tape
     tpread    equ  780  Tape read instruction in overlay loader
     loadxx    equ  793  Exit from overlay loader
     clrbot    equ  833  Bottom of core to clear in overlay loader
     *
               ORG  838
  838beginn    LCA  w4,84  Initialize
  845          SW   84       sense
  849          SW              lights
  850          SW
  851          CC   1
  853          CS   332
  857          CS
  858          MCW  endmsg,218
  865          W
  866          MCW  nstmts,x1  entry address for generated code
  873          BW   errors,glober
  881          CC   J
  883          CS   332
  887          CS
  888          MCW  start,217
  895          W
  896afterr    SW   gmwm
  900          LCA  gmwm,condns  why here???
  907          BCE  cards,cdovly,1
  915          BW   skiptp,gotxl
  923          SBR  retry&3,rd333
     *
     * Load overlay loader
     *
  930rd333     RTW  1,snapsh
  938          BER  taperr
  943          B    aftovl
  947taperr    BSP  1
  952          H    4444,4444
  959retry     B    skiptp
  963cards     BW   skipld,gotxl
  971          R    40  load overlay loader
     *
     * Skip overlay loader
     *
  975skipld    R
  976          BCE  done,68,B
  984          B    skipld
  988skiptp    RTW  1,gmwm
  996          BER  taperr
     *
 1001done      BSS  snapsh,C
 1006          LCA  nop,phasld
 1013          LCA  halt,snapex
     *
     * Return here after loading overlay loader
     *
 1020aftovl    CW   680  in case of overlay loader, clear its gmwm
 1024          SBR  clearl&3,gmwm
 1031          SBR  tpread&6,201
 1038          SBR  loadxx&3,201
 1045          SBR  clrbot,beginn
 1052          B    loadnx
     *
 1056errors    CC   J
 1058          CS   332
 1062          CS
 1063          MCW  errmsg,228
 1070          W
 1071          B    afterr
 1078w4        DCW  #4
 1096endmsg    DCW  @END OF COMPILATION@
 1113start     DCW  @PRESS START TO GO@
 1114nop       NOP
 1115halt      H
 1143errmsg    DCW  @CORRECT ERRORS AND RECOMPILE@
 1144gmwm      DCW  @}@
               ex   beginn
               END
