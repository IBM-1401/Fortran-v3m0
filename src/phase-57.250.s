               JOB  Fortran compiler -- Condensed deck phase one -- 57
               CTL  6611
     *
     * When requested (if there are no input errors), the comiler
     * will punch a self-loading card deck.  The deck is listed on
     * the printer if sense switch B is on.  This phase punches
     * only the clear-storage and bootstrap cards.
     *
     * Stuff in the resident area
     *
     phasid    equ  110  Phase ID, for snapshot dumps
     glober    equ  184  Global error flag -- WM means error
     arytop    equ  194  Top of arrays in object code
     snapsh    equ  333  Core dump snapshot
     topcor    equ  688  Top core address from PARAM card
     condns    equ  693  P for condensed deck
     loadnx    equ  700  Load next overlay
     clearl    equ  707  CS at start of overlay loader
     tpread    equ  780  Tape read instruction in overlay loader
     loadxx    equ  793  Exit from overlay loader
     clrbot    equ  833  Bottom of core to clear in overlay loader
     *
               ORG  838
  838punch     SBR  punchx&3
  842          A    kp1,175  bump sequence number
  849          BSS  *&6,B    punch and print?
  854          P
  855punchx    B    0-0
  859          MCW  180,280
  866          MCW
  867          WP
  868          BCV  *&5
  873          B    *&3
  877          CC   1
  879          B    punchx
  883kp1       dcw  &1
  884beginn    BCE  *&5,condns,P  punch condensed deck?
  892          B    done
  896          BW   done,glober
  904          LCA  arytop,arytop
  911          CS   180
  915          SW   101
  919          MCW  685,180
  926          BSS  *&5,B
  931          B    cont
  935          CC   1
  937          CS   332
  941          CS
  942          MCW  title,260
  949          W
  950          CC   J
  952          B    cont
  956done      BSS  snapsh,C
  961          SBR  tpread&6,884
  968          SBR  clrbot
  972          SBR  loadxx&3,884
  979          SBR  clearl&3,gmwm
  986          LCA  condek,110
  993          B    loadnx
  997cont      LCA  k0000,175  sequence number
 1004          BWZ  under4,topcor,2
 1012          MCW  b1g4k,152
 1019          B    punch      First bootstrap ge 4k
 1023          MCW  topcor,b2ag4k
 1030          MCW  b2bg4k,171
 1037          B    punch      Second bootstrap ge 4k
 1041          B    third
 1045under4    MCW  b1l4k,144
 1052          B    punch      First bootstrap lt 4k
 1056          MCW  topcor,b2al4k
 1063          MCW  b2bl4k,170
 1070          B    punch      Second bootstrap lt 4k
 1074third     MCW  r40,171
 1081          CS
 1082          LCA  b3,146
 1089          B    punch      Third bootstrap
 1093          B    done
 1140b1l4k     DC   @,008015,019026,030,034041,045,053,0570571026@
 1169b2al4k    DCW  @L068112,102106,113/101099/I99@
 1210b2bl4k    dc   @,027A070028)027B0010270B0261,001/001113I0@
 1221r40       DCW  @,0010011040@
 1267b3        DC   @,008015,022029,036040,047054,061068,072/061039@
 1310          DCW  @,008015,022026,030037,044,049,053053N000000@
 1319b1g4k     DC   @N00001026@
 1348b2ag4k    DCW  @L068116,105106,110117B101/I9I@
 1390b2bg4k    dc   @#071029C029056B026/B001/0991,001/001117I0?@
 1404title     DCW  @CONDENSED DECK@
 1412condek    DCW  @CONDECK2@
 1416k0000     DCW  @0000@
 1417gmwm      DCW  @}@
               ex   beginn
               END
