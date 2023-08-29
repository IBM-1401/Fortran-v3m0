               JOB  Fortran compiler -- Replace phase one -- phase 51
               CTL  6611
     *
     * Object-time instructions which reference statement numbers
     * are corrected to the object-time addresses of the
     * statement.  Subscript strings are cleaned up.
     *
     x1        equ  89
     x2        equ  94
     x3        equ  99
     *
     * Stuff in the resident area
     *
     phasid    equ  110  Phase ID, for snapshot dumps
     subscr    equ  116  WM cleared if subscript code needed
     seqtab    equ  148  Bottom of sequence number table - 2
     botfmt    equ  154  Bottom of format strings or number table - 1
     negary    equ  163  16000 - arysiz
     snapsh    equ  333  Core dump snapshot
     loadnx    equ  700  Load next overlay
     clearl    equ  707  CS at start of overlay loader
     loadxx    equ  793  Exit from overlay loader
     clrbot    equ  833  Bottom of core to clear in overlay loader
     *
     * Runtime routines
     *
     aritf     equ  700  Arithmetic interpreter
     *
     110       dcw  @replace 1@
     089       dcw  000
     091       dc   00
     *
               ORG  838
     loaddd    equ  *&1          Load address
  838beginn    MCW  x3,sx3
  845          MCW  seqtab,*&7
  852          MCW  kgreat,0
  859          MCW  botfmt,x2
  866          MCW  kgreat,1600
  873getsub    BCE  getsb2,0&X2,$  within ten of top of subscript?
  881          chain9
  890botex     BCE  bottom,0&X2,>  greater sign below code?
  898          chain9
  907          SBR  x2
  911          B    getsub
  915getsb2    BCE  subtop,0&X2,$  top of subscript?
  923          SBR  x2
  927          B    getsb2
  931subtop    MN   0&X2
  935          SAR  x2
  939          BCE  subbot,0&X2,$  within 16 of bottom of subscript?
  947          chain15
  962          B    getsub
  966subbot    CW   subscr
  970dec3      MN   0&X2
  974          MN
  975          MN
  976          SAR  x2
  980          SW   1&X2
  984          BCE  dec1,0&X2,$
  992          MZ   *-4,2&X2
  999          B    dec3
 1003dec1      MN   0&X2
 1007          SAR  x2
 1011          B    getsub
 1015bottom    MCW  apass2,botex&3
 1022          MCW  x3,x2
 1029          B    getsub
 1033pass2x    BCE  done,0&X3,
 1041          MCW  x3,link&6
 1048          C    0&X3
 1052          SBR  x2
 1056          SBR  x3
 1060          BCE  taritf,1&X3,|  Top of arithmetic assignment
 1068testwm    BW   pass2x,4&X2
 1076          BWZ
 1077          BWZ
 1078          BM   nolink,3&X2
 1086          C    4&X2,a277x3
 1093          BE   pass2x
 1098          BWZ  addlnk,3&X2,B
 1106bumpx2    SBR  x2,3&X2
 1113          B    testwm
 1117addlnk    MCW  4&X2,x1  why not just MA 4&x2,link&6 ???
 1124          MZ   *-6,*&6  x1 tag
 1131link      SBR  4&X2,0
 1138          B    bumpx2
 1142nolink    MCW  4&X2,x1
 1149          MA   negary,x1
 1156          MCW  0&X1,x1
 1163          MCW  x1,4&X2
 1170          B    bumpx2
 1174taritf    BW   *&5,2&X3  Need to look for branch to aritf?
 1182          B    pass2x
 1186faritf    C    0&X3  Find the branch to aritf
 1190          SBR  x3
 1194          C    4&X3,baritf&3  Branch to arithmetic interpreter?
 1201          BE   pass2x         yes
 1206          B    faritf         no, look again
 1210done      MCW  sx3,x3
 1217          BSS  snapsh,C
 1222          SBR  loadxx&3,934
 1229          SBR  clearl&3,gmwm
 1236          LCA  load52,phasid
 1243          B    loadnx
 1249sx3       DCW  #3
 1250kgreat    DCW  @>@  greater than sign
 1253apass2    DSA  pass2x
 1256a277x3    DSA  277&X3
 1257baritf    B    aritf
 1270load52    DCW  @LOAD 52B&C@
 1271gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
