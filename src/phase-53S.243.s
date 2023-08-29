               JOB  Fortran compiler -- Snapshot -- Phase 53S
               CTL  6611
     *
     * Same as snapshot in phase 00
     *
     x1        equ  89
     x2        equ  94
     x3        equ  99
     *
     * Stuff in the resident area
     *
     phasid    equ  110
     topcor    equ  688  Top core address from PARAM card
     *
     * Return in phase 53R after loading
     *
     begin2    equ  938
     *
               ORG  333
  333snapsh    SBR  exit&3
  337          SBR  sxx&6
  341          MCW  kz3,adr5-2  Start five-digit address at zero
  348          MCW  x3,sx3&6
  355          MCW  x1,sx1&6
  362          SBR  x1,1
  369          SBR  x3,202
  376          CS   332
  380          CS
  381          MCW  phasid,210
  388          BSS  skip,F
     *
     * Print a header
     *
  393          CC   1
  395          MCW  x2,250
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
  508          BW   dowm,0&X1   skip clearing print area wm
  516          CW   0&X3
  520dowm      C    x1,topcor  Done?
  527          BU   cont        no
  532          W
  533          WM
  535rx1       MCW  sx1&6,x1   Restore index regs
  542          MCW  sx3&6,x3
  549          CS   332
  553          CS
  554          BSS  halt,G
  559          B    exit 
  563halt      H
  564exit      B    0-0
  568cont      SBR  x1,1&X1
  575          BCE  bump3,x3-2,2
  583          SBR  x3,201
  590          W
  591          WM
  593          A    kp1,w2a
  600          C    w2a,kp15
  607          BU   clearh
  612          S    w2a
  616          CCB  clearh,1
  621skip      MCW  xqtd,220
  628          W    rx1
  632bump3     A    kp1,x3
  639          B    get
  651dots      DCW  @9........@
  653          dcw  @9-@
  658adr5      DCW  00000      Five digit address
  661kz3       dcw  000  
  662kp2       DCW  &2
  664w2a       DCW  #2
  665k9        dcw  9  
  667km10      DCW  @I0@
  669w2b       DCW  #2
  670kp1       dcw  &1
  672kp15      dcw  &15
  679          DCW  @EXECUTE@
  680xqtd      DCW  @}@  Changed to D by reloader phase 53R
               ex   begin2
               END
