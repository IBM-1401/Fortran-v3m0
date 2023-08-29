               JOB  Fortran compiler -- phases 00-02
               CTL  6611
     *
     * SNAPSHOT, SYSTEM MONITOR, and LOADER phase.
     *
     * Read and store the source program, in reverse order, starting
     * at the top of core, with blanks removed except within
     * Hollerith fields in FORMAT statements.  Each statement begins
     * with 000.  Format statements then have F, while others have R.
     * Then the label, if any, followed by a colon.  The end of each
     * statement is marked by a group mark with a word mark.  After
     * the last card, a STOP statement is inserted.
     *
               ORG  81
   86          DC   @      @
   89X1        DCW  @000@
     xxxxx1    equ  x1     for use in SFX regions
   91          DC   @00@
   94X2        DCW  @000@
     xxxxx2    equ  x2     for use in SFX regions
   96          DC   @00@
   99X3        DCW  @000@
     xxxxx3    equ  x3     for use in SFX regions
  104          DC   @0    @
  110phasid    DCW  @LOADER@  Phase ID, for snapshot
  111          DCW  #1  WM cleared if DO statement appears
  112          DCW  #1  WM cleared if DO statement appears
  113          DCW  #1  WM cleared if DO statement appears
  114          DCW  #1  WM cleared when an I/O list of DO is processed
  115          DCW  #1  WM cleared if I/O list and not limited format
  116subscr    DCW  #1  WM cleared if subscript code needed
  117series    DCW  #1  Need series routine if no WM
  118sincos    DCW  #1  Saw sinf or cosf if no WM
  119logf      DCW  #1  Saw logf if no WM
  120expf      DCW  #1  Saw expf if no WM
  121          DCW  #1  Saw atanf if no WM
  122sawabs    DCW  #1  Saw absf if no WM
  123sawneg    DCW  #1  Saw negation operator (unary minus) if no WM
  124xfixf     DCW  #1  Saw xfixf if no WM
  125floatf    DCW  #1  Saw floatf if no WM
  126          DCW  #1  Saw sqrtf if no WM 
  127          DCW  #1  Saw user function R if no WM
  128          DCW  #1  Saw user function U if no WM
  129          DCW  #1  Saw user function P if no WM
  130          DCW  #1  Saw user function W if no WM
  131          DCW  #1  Saw user function Y if no WM
  132          DCW  #1  Saw user function Z if no WM
  133          DCW  #1  Saw user function J if no WM
  134          DCW  #1  Saw user function K if no WM
  135          DCW  #1  Saw user function L if no WM
  136          DCW  #1  Saw user function M if no WM
  137          DCW  #1  Saw user function D if no WM
  138          DCW  #1  Saw user function H if no WM
  139          DCW  #1  Saw xlinkf if no WM
  142negar2    DCW  #3  Looks like negary -- see phase 20
  145tblbot    DCW  #3  One below numbers, formats, I/O lists
  148seqtab    DCW  #3  Bottom of sequence number table - 2
  151docnt     DCW  #3  Count of DO statements
  154botfmt    DCW  #3  Bottom of format strings or number table - 1
  157negar3    DCW  #3  Looks like negary -- see phase 20
  160arysiz    DCW  #3  Total array size & 2
  163negary    DCW  #3  16000 - arysiz
  180          DC   #17
  183nstmts    DCW  #3  Number of statements, including generated stop
  184glober    DC   #1  Global error flag -- WM means error
  185gotxl     DCW  #1  XLINKF was referenced if no WM
  188reltab    DCW  #3  Relocatable function table entry addresses
  191subent    DCW  #3  Entry to subscript routine
  194arytop    DCW  #3  Top of arrays in object code
  195          DC   #1
  199          DCW  @V3M0@
               ORG  333
     *
     * Snapshot routine
     *
               sfx  s
  333snapsh    SBR  exit&3
  337          SBR  sxx&6
  341          MCW  kz3,adr5-2  Start five-digit address at zero
  348          MCW  xxxxx3,sx3&6
  355          MCW  xxxxx1,sx1&6
  362          SBR  xxxxx1,1
  369          SBR  xxxxx3,202
  376          CS   332
  380          CS
  381          MCW  phasid,210
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
  508          BW   dowm,0&X1   skip clearing print area wm
  516          CW   0&X3
  520dowm      C    xxxxx1,topcor  Done?
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
  564exit      B    0-0
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
  658adr5      DCW  00000      Five digit address
  661kz3       dcw  000  
  662kp2       DCW  &2
  664w2a       DCW  #2
  665k9        dcw  9  
  667km10      DCW  @I0@
  669w2b       DCW  #2
  670kp1       dcw  &1
  672kp15      dcw  &15
  680xqtd      dcw  @EXECUTED@
               sfx             End of snapshot routine
     *
     * Storage for parameter card
     *
               da   1x19
  685pword          5   The word PARAM
  688topcor         8   Top core address from PARAM card
  690imod           10  Integer modulus -- number of digits
  692mantis         12  Floating point mantissa digits
  693condns         13  P for condensed deck
  694snapsw         14  S for snapshot
  695c1410          15  T if run on 1410 in 1401 compatibility mode
  696fmtsw          16  X for no format, L for limited format
     *                blank for ordinary, A for A conversion
  699param          19  Parameter card is stored here
     *
     * Load next overlay
     *
               sfx  l
  700loadnx    MCW  clrbot-2,k999-2  Set clear end high digit
  707clearl    CS   0-0
  711          SBR  clearl&3
  715          C    clearl&3,k999
  722          BU   clearl
  727          SW   clrwm&4
  731          MCW  clearl&3,clrwm&6
  738          CW   clrwm&4
  742clrl      C    clrwm&6,clrbot
  749          BE   cdovly     Load the overlay
  754clrwm     LCA  blank,0    Clear with blank and word mark
  761          SBR  clrwm&6
  765          B    clrl  
  769cdovly    R    40         Card overlay unless nop
  773rdagin    MCW  einit,ecount  Initialize error count
  780tpread    RTW  1,beginn   Load overlay from tape
  788          BER  tperr      Error?
  793          B    beginn     No, run the overlay
  797tperr     BSP  1
  802          S    one,ecount
  809          BWZ  tpread,ecount,B  Still positive?
  817          H    3333,3333  Too many tape errors
  824          B    rdagin     Read again
  830k999      DSA  999
  833clrbot    DCW  #3         Address to clear down to
  834blank     DCW  #1
  835einit     DCW  &9         Initial error count
  836one       dcw  &1
  837ecount    DCW  #1
               sfx             End of load next overlay routine
     *
     * Start here
     *
  838beginn    BCE  card,1,    Being loaded from cards?
  846          MCW  nop,cdovly  Turn off card overlay
  853card      CS   80
  857          SW   1,gm
  864          SW   81,84
  871          CS   332
  875          CS
     *
     * Read and check parameter card
     *
  876          R               Read parameter card
  877          LCA  19,param   Save it
  884          C    param-14,kparam  Is it a parameter card?
  891          BU   noparm     No, announce error
  896          SW   73         Set word marks for
  900          SW   6,7          Fortran margins
  907          SW   topcor-2
  911          MCW  80,pword
     *
     * Determine this machine's core size, compare it to
     * size on parameter card
     *
  918          CS   0-0
  922          SBR  corsiz
  926          MCW  topcor,toconv
  933          B    adconv     Covert topcor to five digits
  937          MCW  convtd,top5
  944          MCW  corsiz,toconv
  951          B    adconv     Convert corsiz to five digits
  955          MCW  convtd,cor5
  962          A    kp1,top5   Top addr + 1 = size
  969          A    kp1,cor5   Cor addr + 1 = size
  976          CS   332
  980          CS
  981          CC   1
  983          CS   332
  987          CS
  988          MCW  stmsg,228  Start Fortran Compilation msg
  995          W
  996          CC   J
  998          MCW  top5,231
 1005          MCW  spsize     Specified size
 1009          W
 1010          CS   235
 1014          MCW  cor5,228
 1021          MCW  actsiz     Actual size
 1025          BCE  bignuf,c1410,T  Compiling for 1410 compatibility?
 1033          W
 1034          C    cor5,top5
 1041          BH   psgtm       Print Spec size gt Mach size
 1046          C    top5,k3900  Compare top to 3900
 1053          BL   bignuf
 1058          CC   J
 1060          CS   332
 1064          CS
 1065          MCW  sizerr,218  Machine size error
 1072          W
 1073          B    useact
 1077psgtm     MCW  sgtm,267  Spec. size gt Mach. size msg
 1084          MCW  sgtm2     Rest of the message
 1088          W
 1089useact    MCW  corsiz,topcor  Use actual size
 1096bignuf    MCW  topcor,cleard&3
     *
     * Clear from top of this machine's memory down to DOWNTO
     *
 1103cleard    CS   0-0
 1107          SBR  cleard&3
 1111          C    cleard&3,downto
 1118          BU   cleard
     *
 1123          R
 1124          MZ   *-6,azone  Set A zone after card storage area
 1131          MZ   *-6,intrst&7   Set A zone in BCE D-modifier
 1138          MZ   *-6,blnkok&7     ,,
 1145          MZ   *-6,intchr-1   Add A zone to interesting chars
 1152          MCW  prefix,card1-1  Set default prefix
 1159          MCW  topcor,*&4
 1166          CW   0-0
 1170          SBR  mvchar&6
     *
     * Process next card
     *
 1174rdloop    BW   movecd,flag
 1182          BCE  done,1,:
     *
     * No system after end card
     *
 1190nosys     CC   1
 1192          CS   332
 1196          CS
 1197          MCW  msg1,270
 1204          W
 1205          CC   1
 1207halt1     H    halt1
     *
     * Move card to save area                 
     *
 1211movecd    MCW  72,card72  Move card to save area
 1218          MCW
 1219          MCW
 1220          BCE  done,card1,:
 1228c12t      BIN  prthdg,  Unconditional at first, becomes BCV
 1233afthdg    CS   300
 1237          CS
 1238          MCW  72,283   Move card to print area
 1245          MCW  6,215
 1252          BCE  lstcmt,card1,C    Print now if comment
 1260crd1sw    B    notcnt  Becomes NOP after first card
 1264          BCE  notcnt,card6,0
 1272          BCE  notcnt,card6,
     *
     * Continuation card
     *
 1280          A    kp1,cntcnt        Bump continuation count
 1287          BCE  cntok,cntcnt-1,0  Nine or fewer?
 1295          MCW  cntmsg,300        Put error msg in print area
 1302cntok     W               List the card
 1303          MCW  card7a,svchar&3   Set save char addr to col 7
     *
     * Process the card (NOTCNT comes back here)
     *
 1310svchar    MCW  0-0,char          Save a character
 1317          SW   svchar&1
 1321          A    k1,svchar&3       Bump addr of char to save
 1328          CW   svchar&1
 1332crd2sw    NOP  blnkok            Branch if copying everything
 1336          BCE  svchar,char,      Skip blanks
 1344          MCW  char,*&8
 1351          BCE  intrst,intchr,0
               chain5
 1364mvchar    MCW  char,0
 1371          SBR  mvchar&6
 1375bumpns    A    kp1,nchar        Bump character counter
 1382          C    mvchar&6,botcor  Core full of source code?
 1389          BE   bigsrc
 1394crd3sw    BCE  holler,char,H
 1402crd4sw    NOP  branch,crd3sw
     *
 1409test7     C    svchar&3,card7a  At column 7?
 1416crd5sw    BU   svchar
 1421          SW   mvchar&4
 1425crd6sw    MCW  mvchar&6,X2
 1432          CW   mvchar&4
 1436          MCW  nop2,crd6sw
 1443          MCW  nop2,crd5sw
 1450          A    k10,colcnt
 1457          BCE  col3,colcnt-1,5    Three columns done?
 1465          SW   flag
 1469          BWZ  svchar,colcnt-1,2  More than seven columns done?
 1477          MCW  brnch2,crd5sw
 1484          MCW  0&X2,work7
 1491          C    kfmt,work7  FORMAT% ?
 1498          BU   svchar
     *
     * Process a format statement
     *
 1503          MCW  branch,crd3sw
 1510          MCW  0&X3,work6
 1517          MCW  kf,work6-3
 1524          MCW  work6,0&X3
 1531          B    svchar
     *
 1535slash     MCW  kat,char   Convert slash to at-sign
 1542          B    mvchar
     *
     * Not a continuation card
     *
 1546notcnt    MCW  nop,crd1sw
 1553          A    kp1,nstmt
 1560          MCW  nop,crd3sw
 1567          MCW  nop,crd4sw
 1574          MCW  5,211      Move label to print area
 1581          S    cntcnt     Clear continuation count
 1585          MCW  nop,crd2sw
 1592          MCS  nstmt,203  Move statement count to print area
 1599          W
 1600          SW   mvchar&4
 1604          MCW  mvchar&6,mvchr2&6
 1611          CW   mvchar&4
 1615          MCW  move,crd6sw
 1622mvchr2    LCA  gm,0
 1629          SBR  X3         Save address of first char stored
 1633          SBR  mvchar&6
 1637          MCW  colon,card6  Colon after label, if any
 1644          MCW  brnch2,crd5sw
 1651          MCW  k20,colcnt   Initialize column counter
 1658          MCW  save2a,svchar&3
 1665          B    svchar
     *
 1669col3      C    0&X2,kend  END card?
 1676          BU   svchar
 1681          CW   flag
 1685          B    svchar
     *
 1689at        MCW  kminus,char  Convert at sign to minus
 1696          B    mvchar
     *
     * Saw an interesting character
     *
 1700intrst    BCE  testlc,char,    Test for A zone
 1708          BCE  testlc,char,|   Record mark
 1716          BCE  slash,char,/
 1724          BCE  at,char,@
 1732          MCW  kstar,300
 1739          MCW  procd
 1743          MCW  char
 1747          B    mvchar
     *
     * Character is H, probably hollerith
     *
 1751holler    MCW  mvchar&6,X1
 1758          MCW  nop,crd3sw
 1765          MCW  nop,crd4sw
 1772          MCW  branch,crd2sw
 1779          MCW  4&X1,hcount  Remember, source is stored backward
 1786          BCE  at2,hcount-1,@
 1794          BWZ  nzhm1,hcount-1,2
 1802at2       MCW  hcount-2,hcount  One digit of hollerith coiunt
 1809          MCW  kz2
 1813          B    test7
     *
     * No zone at hcount-1
     *
 1817nzhm1     BCE  at3,hcount,@
 1825          BWZ  nzh,hcount,2
 1833at3       MCW  hcount-2,hcount
 1840          MCW  kz1,hcount-2
 1847          B    test7
     *
     * No zone at hcount.  Reverse the digits
     *
 1851nzh       MCW  hcount,workh1
 1858          MCW  hcount-2,hcount
 1865          MCW  workh1,hcount-2
 1872          B    test7
     *
     * Convert address to five digits
     *
               sfx  c
 1876adconv    SBR  exit&3
 1880          S    cnvw2a
 1884          S    cnvw2b
 1888          MZ   toconv,cnvw2a-1
 1895          MZ   toconv-2,cnvw2b-1
 1902loop1     BWZ  loop2,cnvw2b-1,2
 1910          A    cnvka0,cnvw2b
 1917          B    loop1
 1921loop2     BWZ  lp2x,cnvw2a-1,2
 1929          A    cnvkq4,cnvw2a
 1936          B    loop2
 1940lp2x      A    cnvw2b-1,cnvw2a
 1947          MCW  toconv,convtd
 1954          MCW  cnvw2a
 1958          ZA   convtd
 1962          MZ   *-4,convtd  Clear zone in output
 1969exit      B    0-0
               sfx
     *
 1973blnkok    BCE  testlc,char,   Test for A zone
 1981          S    kp1,hcount
 1988          C    hcount,pze  Hollerith count down to zero?
 1995          BU   mvchar      Nope, just move the character
 2000          MCW  move2,crd4sw
 2007          MCW  nop2,crd2sw
 2014          MCW  svchar&3,X1
 2021          C    0&X1,comma
 2028          BE   mvchar
 2033          MCW  mvchar&6,*&7
 2040          MCW  0,0
 2047          MCW  comma
 2051          SBR  mvchar&6
 2055          A    kp1,nchar
 2062          B    bumpns
 2066          B    mvchar
     *
     * Finished reading the source deck
     *
 2070done      MCW  mvchar&6,X1
 2077          LCA  gm,0&X1
 2084          SBR  X1
 2088          CC   1
 2090          CS   332
 2094          CS
 2095          MCS  nchar,205
 2102          MCW  msgchr,222
 2109          W
 2110          CC   J
 2112          MCW  nstmt,nstmts
 2119          LCA  stop,0&X1
 2126          SBR  X1
 2130          SW   2&X1
 2134          A    kp1,nstmts
 2141          BCE  notbig,3000,
 2149          B    bigsrc
 2153notbig    SBR  clearl&3,2999
 2160          SBR  clrbot,beginn  Change address to clear down to
 2167          BSS  snapsh,C
 2172          LCA  scanr1,phasid  SCANNER
 2179          CS   80         Get
 2183          SW   1,40         ready
 2190          SW   47,54          for
 2197          SW   61,68            card
 2204          SW   72                 overlay
 2208          BCE  loadnx,cdovly,N  Running from tape?
 2216          R
 2217          C    7,scanr2
 2224          BE   loadnx
 2229          B    nosys
     *
     * Source program too big
     *
 2233bigsrc    CS   332
 2237          CS
 2238          CC   1
 2240          MCW  msg2,270
 2247          W
 2248          CC   1
 2250          BCE  halt2,cdovly,1  Running from cards?
 2258          RWD  1             No, rewind the tape
 2263halt2     H    halt2
     *
     * Print listing page heading
     *
 2267prthdg    CC   1
 2269          MCW  kat,c12t&4  Change to BCV
 2276          CS   299
 2280          A    k1,pagnum
 2287          MCS  pagnum,299
 2294          MCW  kpage,295
 2301          MCW  80
 2305          W
 2306          CS   299
 2310          MCW  paghdg,234
 2317          W
 2318          CC   J
 2320          B    afthdg
     *
     * No parameter card
     *
 2324noparm    CC   1
 2326          CS   332
 2330          CS
 2331          MCW  msg3,270
 2338          W
 2339          CC   1
 2341          BCE  halt3,cdovly,1  Running from cards?
 2349          RWD  1             No, rewind the tape
 2354halt3     H    halt3
     *
     * List comment card
     *
 2358lstcmt    MCW  final,203
 2365          MCW  5,211
 2372          W
 2373testlc    BLC  done
 2378          R
 2379          B    rdloop
     *
 2388intchr    DCW  @$@/|  @  Interesting characters
 2423paghdg    DCW  @ SEQ   STMNT      FORTRAN STATEMENT@
     *
     * Card save area
     *
               da   1x78
     save2          2
     card1          6
     card6          11
     card7          12
     card72         77
     azone          78
     *
     * Constants and work areas
     *
 2503colcnt    DCW  #2
 2506card7a    DSA  card7  Address of column 7 in save area
 2509save2a    DSA  save2
 2510k1        dcw  1
 2511brnch2    dc   @b@
 2513k20       dc   20
 2520work7     DCW  #7
 2527kfmt      DCW  @%TAMROF@  'FORMAT%' spelled backward
 2528nop2      DC   @N@
 2529gm        DC   @}@
 2533prefix    DCW  @000R@     Default statement prefix -- arithmetic
 2534colon     DCW  @:@
 2536k10       dcw  10
 2537move      dc   @m@
 2548procd     DCW  @ PROCESSED @
 2549nop       NOP
 2554kparam    dcw  @PARAM@
 2557corsiz    DCW  #3         Actual machine size (top addr)
 2560toconv    DCW  #3         Address to be converted to five digits
 2565convtd    DCW  #5         Address converted to five digits
 2566kp1       dcw  &1
 2594stmsg     DCW  @START OF FORTRAN COMPILATION@
 2620spsize    DCW  @MACHINE SIZE SPECIFIED IS @
 2643actsiz    DCW  @ACTUAL MACHINE SIZE IS @
 2648cor5      DCW  #5         CORSIZ as five digits
 2653top5      DCW  #5         TOPCOR as five digits
 2658k3900     DCW  03900
 2676sizerr    DCW  @MACHINE SIZE ERROR@
 2722sgtm      DCW  @SPECIFIED IS GREATER THAN ACTUAL MACHINE SIZE.@
 2743sgtm2     DCW  @ERROR - MACHINE SIZE @
 2746downto    DSA  2999                         dcw  @R99@
 2787msg1      DCW  @MESSAGE 1-SYSTEM DOES NOT FOLLOW END CARD@
 2802cntmsg    DCW  @CONTINUE CD ERR@
 2807nchar     DCW  #5         Number of characters
 2810botcor    DSA  3000       Bottom of space to store program
 2811branch    DCW  @B@
 2817work6     DCW  #6
 2818KF        DCW  @F@
 2819kat       dcw  @@@
 2822nstmt     DCW  #3         Number of statements
 2824cntcnt    DCW  #2         Count of continuation cards
 2827kend      dcw  @DNE@      END spelled backward
 2828flag      DCW  #1         Word mark is a flag
 2829kminus    DCW  @-@
 2830kstar     DCW  @*@
 2831char      DCW  #1         Character from input
 2834hcount    DCW  #3         Hollerith count
 2836kz2       DCW  00         Two zeros
 2837kz1       DCW  0   
 2838workh1    DCW  #1         Work space for hollerith count
 2840cnvw2a    DCW  #2         Work space for address conversion
 2842cnvw2b    DCW  #2         Work space for address conversion
 2844cnvka0    dcw  @A0@       Constant for address conversion
 2846cnvkq4    dcw  @?4@       Constant for address conversion
 2849pze       dcw  &000       plus zero
 2850move2     MCW
 2851comma     dcw  @,@
 2867msgchr    DCW  @INPUT CHARACTERS@
 2878stop      DCW  @ }POTS:R000@  STOP spelled backward, etc.
 2885scanr1    dcw  @SCANNER@
 2892scanr2    dcw  @SCANNER@
 2928msg2      DCW  @MESSAGE 2 - OBJECT PROGRAM TOO LARGE@
 2931pagnum    DCW  #3
 2939kpage     DCW  @   PAGE @
 2968msg3      DCW  @MESSAGE 3 - NO PARAMETER CARD@
 2971final     DCW  #3
               org  2999
 2999gmwm      dcw  @}@
               END  beginn
