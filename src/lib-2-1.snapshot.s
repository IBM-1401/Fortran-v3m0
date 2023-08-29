               JOB  Library -- snapshot routine
               CTL  6611
     *
   89X1        equ  89
     xxxxx1    equ  x1     for use in SFX regions
   94X2        equ  94
     xxxxx2    equ  x2     for use in SFX regions
   99X3        equ  99
     xxxxx3    equ  x3     for use in SFX regions
               ORG  333
     *
     phasid    equ  110
     topcor    equ  688    from parameter card
     *
     * Snapshot routine
     *
  333snapsh    SBR  exit&3
  337          SBR  sxx&6
  341          MCW  kz3,adr5-2  Start five-digit address at zero
  348          MCW  xxxxx3,sx3&6
  355          MCW  xxxxx1,sx1&6
  362          SBR  xxxxx1,1
  369          SBR  xxxxx3,202
  376          CS   332
  380          CS
  381          NOP  phasid,210  MCW on the compiler tape
  388          BSS  skip,F
     *
     * Print a header
     *
  393          CC   1
  395          MCW  xxxxx2,250
  402sxx       SBR  216,0       return address was stored in B
  409sx3       SBR  256,0       x3 was stored in B
  416sx1       SBR  244,0       x1 was stored in B
  423          W
  424          CC   K
  426          ZA   kp2,w2a
  433clearh    CS   332
  437          CS
  438          CC   J
  440          MCW  adr5,306    five-digit address
  447          MCW
  448          SBR  loop&6
  452          MCW  k9,w2b-1
  459loop      MCW  w2b-1,000
  466          MCW  dots
  470          SBR  loop&6
  474          A    km10,w2b    add I0 = -10
  481          BWZ  loop,w2b-1,2  no zone in counter high digit?
  489          A    kp1,adr5-2  bump hundreds digit of address
  496          W
  497get       SW   0&X3        move data and wm to print area
  501          MCW  0&X1,0&X3
  508          BW   nowm,0&X1   skip clearing print area wm
  516          CW   0&X3
  520nowm      C    xxxxx1,topcor  Done?
  527          BU   cont        no
  532          W
  533          WM
  535rx1       MCW  sx1&6,xxxxx1   Restore index regs
  542          MCW  sx3&6,xxxxx3
  549          CS   332
  553          CS
  554          BSS  halt,G
  559          B    exit 
  563halt      H
  564exit      h    0-0         B on compiler tape
  568cont      SBR  xxxxx1,1&X1
  575          BCE  bump3,xxxxx3-2,2
  583          SBR  xxxxx3,201
  590          W
  591          WM
  593          A    kp1,w2a
  600          C    w2a,kp15
  607          BU   clearh
  612          S    w2a
  616          CCB  clearh,1
  621skip      MCW  xqtd,220
  628          W    rx1
  632bump3     A    kp1,xxxxx3
  639          B    get
  651dots      DCW  @9........@
  653          dcw  @9-@
  658adr5      DCW  @00000@    Five digit address
  661kz3       dcw  @000@
  662kp2       DCW  &2
  664w2a       DCW  #2
  665k9        dcw  @9@
  667km10      DCW  @I0@
  669w2b       DCW  #2
  670kp1       dcw  &1
  672kp15      dcw  &15
  680xqtd      dcw  @EXECUTED@
               END
