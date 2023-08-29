               JOB  Fortran compiler -- Load Phases 52BC -- phase 52A
               CTL  6611
     *
     * As the object coding may originate at 1697, the coding for
     * phase 52 must be split into two parts, the first of which
     * replaces the snapshot coding in positions 333-680.   This
     * phase loads the two sections.
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
     * Address in normal format routine
     *
     iolist    equ  2132
     *
     110       dcw  @load 52b&c@
     *
               ORG  838
     loaddd    equ  *&1          Load address
  840exlink    DCW  #3    139 I xlinkf entry address
  843          DCW  #3    138 H user function 12 entry address
  846          DCW  #3    137 D user function 11 entry address
  849          DCW  #3    136 M user function 10 entry address
  852          DCW  #3    135 L user function 09 entry address
  855          DCW  #3    134 K user function 08 entry address
  858          DCW  #3    133 J user function 07 entry address
  861          DCW  #3    132 Z user function 06 entry address
  864          DCW  #3    131 Y user function 05 entry address
  867          DCW  #3    130 W user function 04 entry address
  870          DCW  #3    129 P user function 03 entry address
  873          DCW  #3    128 U user function 02 entry address
  876user1     DCW  #3    127 R user function 01 entry address
  879          DCW  #3    126 Q sqrtf entry address
  882          DCW  #3    125 F floatf entry address
  885          DCW  #3    124 X xfixf entry address
  888          DCW  #3    123 N negation entry address
  891          DCW  #3    122 A absf entry address
  894          DCW  #3    121 T atanf entry address
  897          DCW  #3    120 E expf entry address
  900          DCW  #3    119 G logf entry address
  903          DCW  #3    118 SC sinf or cosf entry address
  906          DCW  #3    117 series
  909          DCW  #3    116 subscript
  912          DSA  iolist  115 I/O list and not limited format
  915          DCW  #3    114 I/O list
  918          DCW  #3    113
  921          DCW  #3    112
  924funtab    DCW  #3    111
  927          DSA  funtab
  930conbot    DCW  #3    bottom of constants - 1
  933arybot    DCW  #3    bottom of arrays - 1
     *
  934beginn    B    loadb
  938loadc     SBR  tpread&6,beginn
  945          SBR  clrbot
  949          SBR  loadxx&3,337
  956          SBR  clearl&3,gmwm
  963          LCA  funldc,phasid
  970          B    loadnx
  982funldc    DCW  @FUNLOAD C@
  983loadb     SBR  tpread&6,333
  990          SBR  clrbot,loadb
  997          BSS  snapsh,C
 1002          SBR  loadxx&3,loadc
 1009          SBR  clearl&3,gmwm
 1016          LCA  funldb,phasid
 1023          B    loadnx
 1035funldb    DCW  @FUNLOAD B@
               ORG  1696
 1696gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
