               JOB  Fortran compiler -- Normal format -- Phase 54C
               CTL  6611
     *
     * Normal format routine
     *
     * For each input-output statement, an entry to the Format
     * Routine is compiled.  Following this appears:
     * 1. a code indicating the appropriate I/O device;
     *    & is read, - is punch, * is print, otherwise digit part
     *    is tape number and no zone is read tape, a zone is write
     *    tape, b zone is read input tape, ab zone is write output
     *    tape;
     * 2. the address of a series of instructions (format string)
     *    which determines the arrangement of the data (compiled
     *    from the referenced format statement); and
     * 3. the address of the specified list of data (list string).
     *
     * The format string consists of
     * 1. branches to appropriate closed subroutines of the Format
     *    routine,
     * 2. parameters describing the data which are needed by these
     *    subroutines,
     * 3. the data itself (H-conversion fields), and
     * 4. certain register-updating instructions.
     *
     x1        equ  89
     x2        equ  94
     x3        equ  99
     *
     * Address in format loader
     *
     nret      equ  982   return here from normal load
     *
     * Address in function loader
     *
     lisent    equ  912  I/O list processing continuation address
     *
     * Runtime addresses
     *
     snapsh    equ  333  entry to snapshot routie
     manwid    equ  837  Mantissa width. in arithmetic interpreter
     *
               ORG  1697
 1697beginn    SBR  x1
 1701          MCW  0&X1,unit
 1708          MCW  *-6,tape  assume tape I/O without word marks
 1715          SBR  relent&3,7&X1
 1722          MCW  6&X1,lstpos
 1729          ZA   *-6,a12k
 1736          CW   rdflag    start by assuming write
 1740          SW   gmwm
 1744          MCW  3&X1,x2
 1751          SBR  x3,200
 1758          SBR  endrec,334
 1765          BCE  readcd,0&X1,&  read card
 1773          BCE  punch,0&X1,-   punch
 1781          BCE  clearp,0&X1,*  print
 1789          BM   rdtape,0&X1    read tape formatted
 1797          BWZ  clearw,0&X1,B  write tape formatted
 1805          SBR  x2,getwm
 1812          CS   332
 1816          CS
 1817          CS
 1818          SBR  x3,100
 1825          MCW  lca,tape  tape I/O with word marks
 1832          SW   0&X3
 1836          B    1943
 1840          BWZ  rdtape,unit,2
 1848          SBR  recpos,100
     *
     * Find the right-hand (higher core address) of a hollerith
     * field with a left-hand end having a word mark, as it is
     * moved to the output buffer.
     *
 1855chars     MCW  0&X1,0&X3
 1862          SAR  x2
 1866          B    incx3
 1870          BW   *&5,1&X2
 1878          B    chars
 1882          B    chklen
 1886          SBR  2222,redoio
 1893          B    1832
     *
     * Move a field to the output buffer
     *
 1897gotwm     B    chklen
 1901          LCA  0&X3,0&X1
 1908          B    1943
 1912getwml    B    incx3      get x3 up to
 1916getwm     BW   gotwm,1&X3   one below next WM
 1924          B    getwml
     *
 1928          SBR  2222
 1932          MCW  x3,recpos
 1939          B    0&X2
     *
 1943          SBR  2006
 1947          MCW  x2,sx2&6
 1954          BW   2031,flag
 1965             t lisent
 1968lstpos    DCW  #3  Position in I/O list
 1969          SBR  x2
 1973          MZ   nozone,x1-1
 1980          BCE  2046,x1,.
 1988          BCE  2007,x1,
 1996sx2       SBR  x2,0
 2003          B    0
     *
 2007          BW   relent,rdflag
 2015          C    recpos,x3
 2022          BU   2208
 2027          B    relent
 2031          CW   flag
 2035          MCW  sx1,x1
 2042          B    1973
     *
 2046          MCW  2&X2,x3
 2053          MCW  5&X2,x1
 2060          MCW  1&X1,ch
 2067          BW   lca,1&X1
 2075          CW   wmflag
 2079lca       LCA  gmwm,1&X1
 2086          B    incx3
 2090          SBR  x2,*&13
 2097          BWZ  rdtape,unit,2
 2105          B    redoio
 2109          MCW  ch,1&X1
 2116          BW   relent,wmflag
 2124          CW   1&X1
 2128          SW   wmflag
 2132relent    B    0   enter here from relocatable function table
 2136unit      DCW  #1  tape unit number
     *
     * Increment X3 by 1.
     *
 2137incx3     SBR  incx3x&3
 2141          SBR  x3,1&X3
 2148incx3x    B    0
     *
 2152          SBR  x2
 2156          MN   0&X2
 2160          MN
 2161          MN
 2162          MN
 2163          SAR  2309
 2167          MCW  2&X2,count
 2174          SBR  2207,3&X2
 2181          B    *&5
 2185          SBR  x2
 2189          S    k1,count
 2196          BM   0&X2,count
 2204          B    0
     *
 2208          SBR  x2
 2212          MCW  recpos,x3
 2219          B    0
     *
 2223          BW   *&13,rdflag
 2231          C    recpos,x3
 2238          BU   2208
 2243          MCW  lstpos,*&7
 2250          BCE  2298,0,,
 2258          MCW  lstpos,listp2
 2268             t lisent
 2271listp2    DCW  #3
 2272          BCE  relent,x1,
 2280          MCW  listp2,lstpos
 2287          MCW  x1,sx1
 2294          SW   flag
 2298          BW   2208,rdflag
 2306          B    0
     *
 2310          SBR  x2
 2314          ZA   2&X2,a12k
 2321          B    3&X2
     *
 2327a12k      DSA  12000
     *
     * copy the argument to the output buffer
     *
 2328          SBR  x2
 2332cpargl    BW   *&8,rdflag
 2340          MCW  0&X2,0&X3
 2347          MCW  0&X3,0&X2  Why?
 2354          B    incx3
 2358          SBR  x2,1&X2
 2365          BW   *&5,0&X2
 2373          B    cpargl
 2377          B    chklen
 2381          B    0&X2
     *
 2385          SBR  x2
 2389          MCW  3&X2,count2
 2396dec2      S    k1,count2
 2403          BWZ  more,count2,B  still positive?
 2411          BCE  7&X2,0&X2,I
 2419          BCE  7&X2,0&X2,A
 2427          B    10&X2
 2431more      B    1943
 2434          S
 2438          DC   @_00@
 2539          sw
 2442          DC   @;0J@
 2443          BW   3651,rdflag
 2451          CS   24
 2455          SW   0&X3
 2459          MN
 2460          SBR  x3
 2464          SBR  sw1&3,2&X3
 2471          SBR  cw2&3
 2475          SW   1
 2479          BCE  ifmt,0&X2,I
 2487          BCE  afmt3,0&X2,A
 2495          mcw  0&x1
 2501          DC   @;00@
 2502          MCW
 2503          SBR  x1
 2507          SW   0&X1
 2511          A    6&X2,x3
 2518          SBR  cw1&3,2&X3
 2525          MCW  k0dot0  0.0
 2529          SW   2&X3
 2533          BCE  *&9,1&X1,0
 2541             v 2674
 2548          DC   @;0K2@
 2549          BCE  efmt,0&X2,E
 2557          a    a12k  Not E format
 2563          DC   @;00@
 2564          B    *&8
 2568efmt      s    a12k
 2574          DC   @;00@
 2575          mn
 2578          DC   @;00@
 2581          dc   w2
 2582          MN
 2583          mcw
 2586          DC   @;00@
 2587          BCE  ffmt1,0&X2,F
 2595          C    w2,kz4-2  two zero digits
 2602          BE   *&9
 2607          BM   *&8,savzon
 2615          MZ   nozone,savzon
 2622          za   a12k
 2628          DC   @;00@
 2629          mn
 2633          DC   @;00@
 2635          dc   sbr&6
 2636          MN
 2637sbr       SBR  x1,0&X1
 2644          ZA   manwid,w3  mantissa width in aritf
 2651          S    k2,w3        includes the exponent width
 2658          c    w3
 2664          DC   @;00@
 2665          BH   2728
 2670          B    2797
     *
 2674          MCW  kx,2&X3  blank X blank
 2681          MCW           0.0
 2682          SBR  x3,2&X3
 2689          SBR  cw3&3
 2693          A    9&X2,x3
 2700          B    noovfl
     *
 2704ffmt1     BM   2766,savzon
 2712          C    6&X2,w2
 2719          BL   2629
 2724          B    2674
     *
 2728          S    23
 2732          mcm
 2738          DC   @_0A001@
 2739          MCW  kz4
 2743          MZ         nozone
 2744          MCW  w2,x1
 2751          MCW  kz4-3  one zero digit
 2755          MCW  gmwm,3&X1
 2762          B    2797
 2766          MZ   nozone,0&X1
 2773          C    9&X2,w2
 2780          BU   *&8
 2785          c
 2788          DC   @_0A@
 2791          dc   k5
 2792          BH   ifmt2
 2797          mz
 2800          DC   @;0K@
 2803          dc   @0|0@  0&x1
 2804          B    ifmt2
     *
     * Check record length
     *
 2808chklen    SBR  chklex&3
 2812          C    endrec,x3
 2819          BL   chklex
 2824          NOP  3700  snapshot routine is clobbered
 2828          H
 2829chklex    B    0
     *
 2833ifmt      mcw  0&x1
 2839          DC   @_00@
 2840          A    6&X2,x3
 2847          MCW  6&X2,x1
 2854          za
 2857          dc   @_00@
 2860          DC   @0|0@  0&x1
 2861          B    incx3
 2865ifmt2     MCS  0&X1,0&X3
 2872          SBR  sx3&6
 2876          MN   0&X1,0&X3  at least show the low order digit
 2883          SBR  mcs&3,0&X3
 2890          SBR  cw3&3
 2894sw1       SW   0
 2898          BM   *&5,0&X1
 2906          B    sx3
 2910getb      BCE  gotb,0&X3,  found a blank?
 2918          SBR  x3
 2922          BW   sx3,1&X3  end of the field, no sign
 2930          B    getb
 2934gotb      MZ   bzone,0&X3  set the sign
 2941          SW   1&X3
 2945          SBR  cw3&3,1&X3
 2952sx3       SBR  x3,111
 2959          BCE  cw2,0&X2,I
 2967          A    9&X2,x3
 2974          BCE  ffmt2,0&X2,F
 2982          MN   0&X3
 2986          MN
 2987          MN
 2988          MN
 2989          SBR  x3
 2993ffmt2     SBR  sx3a&6,1&X3
 3000          S    1&X3
 3004          MN
 3005          SAR  x3
 3009          BCE  findgm,0&X2,E
 3017          BWZ  findgm,savzon,B
 3025          C    9&X2,w2
 3032          BH   sx3a
 3037          A    w2,x3
 3044findgm    BCE  sx3a,3&X1,}  gm
 3052          MN   1&X1,2&X3
 3059          SBR  x1,1&X1
 3066          BWZ  sx3a,2&X3,B
 3074          SBR  x3
 3078          B    findgm
 3082sx3a      SBR  x3,0
 3089          BAV  *&1
 3094          A    kp5,0&X3
 3101          MCW  nozone,0&X3
 3108          BCE  ffmt3,0&X2,F
 3116          SBR  x3,4&X3
 3123          MN   0&X3
 3127          MCW  w2
 3131          MZ
 3132          MCW
 3133ffmt3     BAV  ovfl
 3138noovfl    cw
 3141          DC   @_00@
 3142cw1       CW   0
 3146cw2       CW   0
 3150cw3       CW   0
 3154sw2       sw
 3157          DC   @_0A@
 3158          B    chklen
 3162          B    dec2
     *
 3166ovfl      MCW  cw1&3,x1
 3173          MZ   nozone,0&X1
 3180          MCW           dot
 3181          A             one
 3182          BAV  *&9
 3187mcs       MCS  0
 3191          B    noovfl
 3195          MN   0&X1
 3199          C
 3200          MN
 3201          SBR  x1
 3205          C    cw2&3,x1
 3212          BL   xxfld
 3217          SW   0&X1
 3221          MCW  1&X1,0&X1
 3228          CW
 3229          MCW  k1,1&X1
 3236          B    noovfl
 3240xxfld     MCW  1&X3,0&X3  clear the field
 3247          MCW
 3248          MCW
 3249          MCW  kx,3&X1    then put blank x blank in it
 3256          B    noovfl
     *
 3260          dcw  1
 3261          dcw  @.@
 3262nozone    DCW  #1
 3266kz4       DCW  @0000@
     *
 3267ifmt3     MCW  x1,x3
 3274          MZ   zas2,3288
 3281          mn   0&x3
 3287          DC   @_0A@
 3288          ZA
 3289          MCW  4146,x1
 3296          lca
 3299          dc   @_00@
 3302          DC   @0|0@  0&x1
 3303          B    4155
     *
     * End of file on input
     *
 3307eofrd     NOP  4002
 3311          H
     *
     * Tape read
     *
 3312rdtape    SW   rdflag
 3316clearr    CS   332
 3320          CS
 3321          B    redoio
     *
     * After tape read
     *
 3325endrd     BEF  eofrd
 3330          BCE  redoio,12&X3,}  short -- noise -- record?
 3338          chain12
 3350          B    1928
 3354          B    clearr
     *
     * End of tape on output
     *
 3358eofwr     MN   unit,*&4
 3365          WTM  0
 3370          NOP  4003
 3374          H
     *
     * Write tape
     *
 3375clearw    CS   332
 3379          CS
 3380          B    1928
 3384redoio    MN   unit,tape&3
 3391          MCW  kr,tape&7  Assume it's read, not write
 3398          ZA   kr,w3      @R@ used as -9 here
 3405          BW   doio,rdflag
 3413          MCW  kw,tape&7  oops, it's write
 3420          A    kp41,w3
 3427doio      LCA  gmwm,snapsh
 3434tape      RT   0,0&X3
 3442          LCA  beginn,snapsh  unclobber
 3449          BER  taperr
 3454          BCE  endrd,tape&7,R
 3462          BEF  eofwr
 3467          B    clearw
     *
     * Print
     *
 3471clearp    CS   snapsh
 3475          CS
 3476          B    1928
 3480          BCE  k2,200,     No spacing
 3488          BCE  dble,200,0  Double space?
 3496          MN   200,*&2     set skip-to channel
 3503          CC   0
 3505k2        W
 3506          BCV  *&5
 3511          B    clearp
 3515          CCB  clearp,1
 3520dble      CCB  k2,J
     *
     * Punch
     *
 3525punch     MCW  a281,endrec
 3532          CS   1928,285
 3539          SW   200
 3543          LCA  279,180
 3550          P
 3551          SSB  punch,4
     *
     * Read a card
     *
 3556readcd    CS   80
 3560          MCW  a281,endrec
 3567          SW   1,rdflag
 3574k1        R
 3575          LCA  80,279
 3582          SSB  1928,1
 3587          B    readcd
     *
     * Tape I/O error
     *
 3591taperr    MN   unit,bsp&3
 3598          MN   unit,skp&3
 3605bsp       BSP  0
 3610          BCE  *&6,tape&7,R
 3618skp       SKP  0
 3623          S    k1,w3
 3630          BWZ  doio,w3,B
 3638          NOP  1111
 3642          H
 3643          B    redoio
     *
 3647kp5       dcw  &5
 3648savzon    DCW  #1
 3650w2        DCW  00
     *
 3651          SW   0&X3
 3655          MCW  x1,4146
 3662          MCW  x3,x1
 3669          A    6&X2,x1
 3676          BCE  ifmt4,0&X2,I
 3684          BCE  afmt2,0&X2,A
 3692          A    9&X2,x1
 3699ifmt4     SW   0&X1
 3703          SBR  cw4&3,0&X1
 3710          s
 3713          DC   @;00@
 3714          S
 3715          BCE  3762,0&X3,
 3723          MZ   bzone,zas2
 3730          BCE  3778,0&X3,-
 3738          BCE  3778,0&X3,@
 3746bzone     ZS   zas2
 3750          BCE  3778,0&X3,&
 3758          B    3786
 3762          BW   4132,1&X3
 3770          B    incx3
 3774          B    3715
 3778          SW   1&X3
 3782          B    incx3
 3786          BCE  ifmt3,0&X2,I
 3794          sbr  x1
 3800          DC   @_0J@
 3801          mz   nozone
 3807          DC   @;0K@
 3808          CW   flag1,flag2
 3815          CW   flag3
 3819          S    w3a
 3823          BCE  afmt1,0&X2,A
 3831          B    chkch1
     *
 3835dot       SBR  w3,0&X3
 3842          SW   flag3
 3846          BW   *&8,flag1
 3854          SBR  w3,1&X3
 3861notdot    BW   ckefmt,1&X3
 3869          BCE  ckefmt,1&X3,
 3877          B    incx3
 3881chkch1    BCE  dot,0&X3,.
 3889          C    0&X3,kz4-3  one zero digit
 3896          BL   4163
 3901          BH   chkch2
 3906          BW   4163,flag1
 3914          B    notdot
     *
     * Check validity of character
     *
 3918chkch2    BCE  er1121,0&X2,F  no exponent if F format
 3926          SBR  w3b,4&X3
 3933          MZ   abzone,zas
 3940          BCE  exp,0&X3,E
 3948cksign    MZ   0&X3,zas
 3955          BCE  sign,0&X3,&
 3963          BCE  sign,0&X3,-
     *
     * Data and FORMAT specifications disagree in mode or
     * acceptable characters.
     *
 3971er1121    NOP  1121
 3975          H
 3976abzone    B    er1121
     *
 3980exp       BWZ  *&9,1&X3,2
 3988          B    incx3
 3992          B    cksign
 3996          BCE  *&5,1&X3,
 4004          B    *&5
 4008          B    incx3
 4012sign      SW   1&X3
 4016          BW   zas,2&X3
 4024          BCE  zas,2&X3,
 4032          SBR  x3
 4036zas       ZA   1&X3,w3a  sometimes zs
 4043          B    *&16
 4047ckefmt    BCE  er1121,0&X2,E  E format?
 4055          SBR  w3b,1&X3
 4062zas2      za
 4065          DC   @;0K@
 4066          BW   *&5,flag1
 4074          B    4140
 4078          BW   *&15,flag3
 4086          S    9&X2,w3b
 4093          ZA   w3b,w3
 4100          S    w3,w3c
 4107          A    a12k,w3a
 4114          ZS   w3c
 4118          A    w3c,w3a
 4125          za   w3a
 4131          DC   @;00@
 4132          BCE  ifmt3,0&X2,I
 4140          mcw
 4143          DC   @;00@
 4146          dc   000
 4147          LCA
 4148          MCW  *&4,x3
 4155cw4       CW   0
 4159          B    sw2
     *
 4163          BW   *&12,flag1
 4171          SBR  w3c,0&X3
 4178          SW   flag1
 4182          BW   notdot,flag2
 4190          MN   0&X3,2&X1
 4197          SBR  x1
 4201          SW   flag2
 4205          BCE  notdot,4&X1,}  gm
 4213          CW   flag2
 4217          B    notdot
     *
 4223w3a       DCW  #3
 4226w3b       DCW  #3
 4229w3c       DCW  #3
 4232w3        DCW  #3
 4233k5        DCW  @5@
 4234flag      dc   #1
 4235rdflag    DCW  #1  read if WM, write if no WM
 4238endrec    DCW  #3  Address of end of record, either 334 or 281
 4241recpos    DCW  #3
 4242ch        DCW  #1
 4243wmflag    DCW  #1  WM if char being copied has a WM
 4246count     DCW  #3
 4249sx1       DCW  #3
 4252count2    DCW  #3
 4255k0dot0    DCW  @0.0@
 4258kx        DCW  @ X @
 4259kr        DCW  @R@
 4260kw        dcw  @W@
 4262kp41      DCW  &41
 4265a281      DSA  281
 4266flag1     DCW  #1
 4267flag2     DCW  #1
 4268flag3     DCW  #1
 4269gmwm      DCW  @}@
               ex   nret
               JOB  Fortran compiler -- A conversion -- Phase 54D
               ORG  4280
 4280afmt1     BW   *&12,flag1
 4288          SBR  w3c,0&X3
 4295          SW   flag1
 4299          BW   atest,flag2
 4307          MN   0&X3,2&X1
 4314          MZ   0&X3,2&X1
 4321          SBR  x1
 4325          SW   flag2
 4329          BCE  atest,4&X1,}  gm
 4337          CW   flag2
 4341atest     BW   *&9,1&X3  End of source field?
 4349          B    incx3
 4353          B    afmt1
 4357          SBR  w3b,1&X3
 4364          MCW  4146,*&7
 4371          MCW  0,0
 4378          LCA
 4379          MCW  cw4&3,x3
 4386          B    sw2
 4390afmt2     mcw  k3b 
 4396          DC   @;00@
 4397          mcw  w20
 4403          DC   @;0K@
 4404          SW   0&X1
 4408          SBR  cw4&3,0&X1
 4415          B    3786
     *
     * Move data to A format field
     *
 4419afmt3     MCW  2501,*&7
 4426amcw      MCW  0,0
 4433          MCW
 4434          SBR  x1
 4438          SBR  src,1&X1
 4445          SBR  trgend,0&X3
 4452          MA   6&X2,trgend
 4459          SBR  target,1&X3
 4466          MCW  amcw&6,srcend
 4473          MA   am2,srcend
 4480aloop     MN   1&X1,2&X3
 4487          MZ   1&X1,2&X3
 4494          C    target,trgend
 4501          BE   aend
 4506          C    src,srcend
 4513          BE   aend
 4518          MA   a001,src
 4525          MA   a001,target
 4532          SBR  x1,1&X1
 4539          SBR  x3,1&X3
 4546          B    aloop
 4550aend      SBR  cw3&3,0&X3
 4557          MCW  trgend,x3
 4564          SBR  x3,2&X3
 4571          B    cw2
     *
 4577k3b       DCW  #3
 4597w20       DCW  #20
 4600target    DCW  #3
 4603src       DCW  #3
 4606trgend    DCW  #3
 4609srcend    DCW  #3
 4612am2       DSA  15998  -2 = 16000 - 2 = 15998
 4615a001      DSA  1
 4616          DCW  @}@
               ex   nret
               END
