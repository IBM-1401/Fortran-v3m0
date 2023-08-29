               JOB  Fortran compiler -- Format loader -- Phase 54A
               CTL  6611
     *
     * This phase selects the proper I/O routine and loads it into
     * its object core-storage location.
     *
     * Limited format routine is first (54B), normal format routine
     * is second (54C), A-conversion format routine is third (54D).
     *
     * Stuff in the resident area
     *
     phasid    equ  110  Phase ID, for snapshot dumps
     snapsh    equ  333  Core dump snapshot
     imod      equ  690  Integer modulus -- number of digits
     fmtsw     equ  696  X for no format, L for limited format
     *                 blank for ordinary, A for A conversion
     loadnx    equ  700  Load next overlay
     clearl    equ  707  CS at start of overlay loader
     cdovly    equ  769  1 if running from cards, N if from tape
     tpread    equ  780  Tape read instruction in overlay loader
     loadxx    equ  793  Exit from overlay loader
     clrbot    equ  833  Bottom of core to clear in overlay loader
     *
     * Runtime addresses
     *
     fmtbas    equ  1697  base address of limited and normal
     fmtbaa    equ  4280  base address of A-conversion
     agm       equ  4616  GMWM at end of A-conversion
     lgm       equ  2015  GMWM at end of limited routine
     ngm       equ  4269  GMWM at end of normal routine
     nswich    equ  3138  Switch in normal routine
     *
               ORG  934
  934beginn    SW   gmwm,fmtbas
  941          BCE  tape,cdovly,N
     *
     * Load format routine from cards
     *
  949          BCE  cardl,fmtsw,L
  957skip1     R          skip limited routine (54B)
  958          BCE  *&5,68,B  EX card?
  966          B    skip1
  970          BCE  cardx,fmtsw,X
  978          R    40    load normal routine (54C)
  982nret      CW   ngm   Return here from normal load
  986          C    imod,k01
  993          BU   ctesta
  998          LCA  nop,nswich
 1005ctesta    BCE  carda,fmtsw,A
 1013skip2     R
 1014          BCE  done,68,B  EX card?
 1022          B    skip2
 1026cardl     R    40    load limited routine (54B)
 1030lret      CW   lgm   return here from limited load
 1034cardx     R
 1035          BCE  ctesta,68,B  EX card?
 1043          B    cardx
 1047carda     R    40    load A-conversion routine (54D)
 1051aret      CW   agm   return here from A-conversion load
 1055          B    done
     *
     * Load format routine from tape
     *
 1059tape      BCE  tapel,fmtsw,L
 1067          RTW  1,gmwm    skip limited format routine
 1075          BER  taperr
 1080          BCE  tapex,fmtsw,X
 1088          RTW  1,fmtbas  load normal format routine
 1096          BER  taperr
 1101          C    imod,k01
 1108          BU   *&8
 1113          LCA  nop,nswich
 1120          BCE  tapea,fmtsw,A
 1128skipa     RTW  1,gmwm    skip A-conversion routine
 1136          BER  taperr
 1141done      BSS  snapsh,C
 1146          SBR  clearl&3,gmwm
 1153          LCA  repl2,phasid
 1160          B    loadnx
 1164tapel     RTW  1,fmtbas  load limited routine
 1172          BER  taperr
 1177tapex     RTW  1,gmwm    skip normal routine
 1185          BER  taperr
 1190          B    skipa
 1194tapea     RTW  1,fmtbaa  load A-conversion routine
 1202          BER  taperr
 1207          B    done
     *
     * Tape error routine
     *
 1211taperr    SBR  taperx&3
 1215          MA   am13,taperx&3  Back up exit to read instruction
 1222          BSP  1
 1227          H    3333,3333
 1234taperx    B    0
     *
     * Data
     *
 1239k01       DCW  01
 1240nop       NOP
 1249repl2     DCW  @REPLACE 2@
 1252am13      DSA  15987  -13 as an address
 1253gmwm      DCW  @}@
               ex   beginn
               END
