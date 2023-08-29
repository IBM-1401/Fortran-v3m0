               JOB  Fortran compiler -- Limited I/O -- Phase 54B
               CTL  6611
     *
     * Limited I/O routine -- no formatting
     *
     x1        equ  89
     x3        equ  99
     *
     * Address in format loader
     *
     lret      equ  1030  return here from limited load
     *
               ORG  1697
 1697          SBR  x1
 1701          SW   gmwm
 1705          CW   0&X1
 1709          MCW  x3,sx3
 1716          LCA  a001,x3
 1723          BWZ  write,0&X1,S
 1731          MCW  kr,tape&7  read D modifier
 1738setup     MCW  6&X1,w3
 1745loop      MCW  w3,*&7
 1752          BCE  done,0-0,.
 1760          MA   a006,w3
 1767          MCW  w3,*&4
 1774          MCW  0-0,w6
 1781          SW   w6-2
 1785          MA   a001,w6
 1792          MCW  w6,*&4
 1799          MCW  0-0,w1
 1806          MCW  w6,*&7
 1813          LCA  gmwm,0-0
 1820          MCW  w6-3,tape&6  I/O address
 1827          MN   0&X1,tape&3  tape unit number
 1834          S    errct,errct
 1841          MZ   x3zone,tape&5
 1848tape      RTW  1,0
 1856          BEF  endfil
 1861          BER  taperr
 1866          MCW  w6,*&7
 1873          MCW  w1,0-0
 1880          MA   a001,w3
 1887          CW   w6-2
 1891          B    loop
 1895done      MCW  sx3,x3
 1902          SW   0&X1
 1906          B    7&X1
 1910write     MCW  kw,tape&7  write D modifier
 1917          B    setup
 1921taperr    BCE  errhlt,errct,I
 1929          MN   tape&3,*&4
 1936          DCW  @U%UOB@         BSP  0-0
 1941          BCE  skip,tape&7,W
 1949          A    k1,errct
 1956          B    tape
 1960skip      MN   tape&3,*&4
 1967          DCW  @U%UOE@         SKP  0-0
 1972          B    tape
 1976errhlt    H    errhlt,777
 1983endfil    H    endfil,888
 1992sx3       DCW  #3
 1995a001      DSA  1
 1996kr        DCW  @R@
 1999w3        DCW  #3
 2002a006      DSA  6
 2008w6        DCW  #6
 2009w1        DCW  #1
 2010errct     DCW  #1
 2011x3zone    dcw  @A@
 2012kw        DCW  @W@
 2013k1        dcw  1
 2014          DCW  #1
 2015gmwm      DCW  @}@
               ex   lret  Return to format loader after loading
               END
