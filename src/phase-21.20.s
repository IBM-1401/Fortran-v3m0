               JOB  Fortran compiler -- Subscripts Phase -- 21
               CTL  6611
     *
     * Subscripts which must be computed at object time are reduced
     * to the required parameters.
     *
     * On entry, x1 is the top of the prefix of the top statement
     * and x2 is one below the bottom statement.
     *
     x1        equ  89
     x2        equ  94
     x3        equ  99
     *
     * Stuff in the resident area
     *
     phasid    equ  110  Phase ID, for snapshot dumps
     snapsh    equ  333  Core dump snapshot
     loadnx    equ  700  Load next overlay
     clearl    equ  707  CS at start of overlay loader
     *
     110       dcw  @subscr@
     099       dcw  000
     100       dc   0
     *
               ORG  838
     loaddd    equ  *&1          Load address
  838beginn    CS   0&X2  clear below bottom statement
  842          CS
  843          SBR  x2,1&X1
  850          SBR  sx1
  854loop      BCE  done,0&X1,  below bottom statement
  862          MCW  0&X1,seqcod
  869          B    moveup
  873          BCE  endst1,seqcod-3,/  End statement?
  881          BCE  endst1,seqcod-3,F  Format statement?
  889schsub    BCE  sub6,0&X1,$
  897          chain5
  902          BW   endstm,0&X1
  910          chain5
  915          SBR  x1
  919          B    schsub
     *
     * Got x1 to within six of a $, which indicates subscripting.
     * Get to it exactly.
     *
  923sub6      BCE  gotsub,0&X1,$
  931          SBR  x1
  935          B    sub6
  939gotsub    SW   0&X1
  943          B    move2
  947          MN   0&X1
  951          SAR  x1
  955          B    x1dec4
  959morsub    SW   2&X1
  963          B    move2
  967          B    x1dec4
  971          BWZ  intsub,3&X1,S  A zone?
  979          BM   intsub,3&X1    B zone?
     *
     * No zone or AB zone means floating point subscript
     *
  987          CS   332
  991          CS
  992          SW   184  Global (?) error flag
  996          MN   seqcod,250
 1003          MN
 1004          MN
 1005          MCW  err12
 1009          W
 1010          BCV  *&5
 1015          B    intsub
 1019          CC   1
 1021intsub    SW   2&X1
 1025          B    move2
 1029          B    x1dec4
 1033          C    1&X1,kdol
 1040          BU   morsub
 1045          SW   1&X1
 1049          B    move2
 1053          MCW  x1,x3
 1060          B    schsub
     *
     * Move up prefix or tail of statement
     *
 1064moveup    SBR  movex&3
 1068          LCA  0&X1,0&X2
 1075          SAR  x1
 1079          C    0&X2
 1083          SAR  x2
 1087          MCW  x1,x3
 1094movex     B    0-0
     *
     * Copy x1 to x3, then decrement x1 by 4
     *
 1098x1dec4    SBR  x1decx&3
 1102          MCW  x1,x3
 1109          MN   0&X1
 1113          MN
 1114          MN
 1115          MN
 1116          SBR  x1
 1120x1decx    B    0-0
     *
     * End of a statement
     *
 1124endstm    MCW  x3,x1
 1131endst1    B    moveup  Move up tail of statement
 1135          B    loop
     *
     * Done
     *
 1139done      MCW  sx1,x1
 1146          BSS  snapsh,C
 1151          SBR  clearl&3,gmwm
 1158          LCA  stnum1,phasid
 1165          B    loadnx
     *
     * Move up a chunk of the statement
     *
 1169move2     SBR  move2x&3
 1173          LCA  0&X3,0&X2
 1180          SBR  x2
 1184          CW   1&X2
 1188move2x    B    0-0
     *
     * Data
     *
 1194sx1       DCW  #3
 1198seqcod    DCW  #4
 1245err12     DCW  @ERROR 12 - FLOATING POINT SUBSCRIPT, STATEMENT @
 1246kdol      DCW  @$@
 1255stnum1    DCW  @STNUM ONE@
 1256gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
