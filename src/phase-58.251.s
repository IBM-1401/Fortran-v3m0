               JOB  Fortran compiler -- Condensed deck phase 2 -- 58
               CTL  6611
     *
     * This phase punches cards that will initialize the index
     * registers and sense lights, the snapshot or the linkage
     * routine, the arithmetic routine, and certain final
     * addresses and constants.
     *
     * Stuff in the resident area
     *
     glober    equ  184  Global error flag -- WM means error
     gotxl     equ  185  XLINKF was referenced if no WM
     reltab    equ  188  Relocatable function table entry addresses
     subent    equ  191  Entry to subscript routine
     snapsh    equ  333  Core dump snapshot
     imod      equ  690  Integer modulus -- number of digits
     mantis    equ  692  Floating point mantissa digits & 2
     condns    equ  693  P for condensed deck
     loadnx    equ  700  Load next overlay
     clearl    equ  707  CS at start of overlay loader
     cdovly    equ  769  1 if running from cards, N if from tape
     tpread    equ  780  Tape read instruction in overlay loader
     loadxx    equ  793  Exit from overlay loader
     clrbot    equ  833  Bottom of core to clear in overlay loader
     *
     * Address in Phase 57
     *
     punch     equ  838  Punch a card and maybe print it too
     *
     * Addresses in ARITF
     *
     setfp     equ  831   put mantissa width into B
     qfunct    equ  1327  branch to function selector
     dosub     equ  1206  branch to subscript routine
     ariti     equ  1530  put integer size in B
     *
               ORG  884
  884beginn    MCW  cdovly,r2
  891          BW   skipx1,gotxl  need XLINKF if no WM, skip if WM
     *
     * Skip snapshot
     *
  899          MCW  cdovly,r1  read or NOP
  906          SBR  tstcnt&3,rt1
  913          SBR  taperx&3,reset1
  920r1        R    test1
  924reset1    MCW  kp9,errcnt
  931rt1       RT   1,1
  939          BER  taperr
  944test1     BCE  *&5,68,B
  952          B    r1
     *
     * Setup second reader to punch
     *
  956          SBR  swich2&3,test2
  963          SBR  tstcnt&3,rt2
  970          SBR  taperx&3,reset2
  977          A    kp1,w1
  984skipx1    BCE  *&5,condns,P
  992          B    r2
  996          BW   errmsg,glober
     *
     * Set index registers and sense lights with zeroes
     * Part of ARITF deck now
     *
 1004          MCW  r40&3,171
 1011          MCW  load1  to set index registers and sense lights
 1015          CS
 1016          LCA  kz14,114  zeroes
 1023          MCW  branch,swich1
 1030          NOP  punch
     *
     * Load topcor, imod, mantis, gmwm
     *
 1034          MCW  r40&3,171
 1041          MCW  load
 1045          CS
 1046          MCW  load2,157  Load mantis, imod, topcor
 1053          SW   gmwm
 1057          MCW  gmwm,108
 1064          MCW  mantis  FP size
 1068          MCW          integer size
 1069          LCA          topcor
 1070swich1    NOP  punch   sometimes branch
     *
     * Copy or skip a deck
     *
 1074r2        R    swich2
 1078reset2    MCW  kp9,errcnt
 1085rt2       RT   1,1
 1093          BER  taperr
 1098swich2    B    chg2  sometimes test2, sometimes endeks
 1102taperr    BSP  1
 1107          S    kp1,errcnt
 1114tstcnt    BWZ  rt2,errcnt,B
 1122          NOP  3333
 1126          H
 1127taperx    B    reset2
 1131test2     BCE  end2,68,B
 1139          MCW  71,171
 1146          chain5
 1151          B    swich1
 1155chg2      SBR  swich2&3,test2  skip first card, punch the rest
 1162          B    r2
     *
     * Errors prevent condensed deck
     *
 1166errmsg    CS   332
 1170          CS
 1171          MCW  errors,243
 1178          W
 1179          CC   J
 1181          B    r2
     *
     * Copy another deck
     *
 1185end2      A    kp1,w1
 1192          BCE  endeck,w1,3
 1200          BCE  r2,w1,2
 1208          BW   *&5,gotxl  skip XLINKF if WM
 1216          B    r2         get XLINKF if no WM
 1220          MCW  cdovly,r3
 1227          SBR  tstcnt&3,rt3
 1234          SBR  taperx&3,reset3
     *
     * Skip a deck
     *
 1241r3        R    test3
 1245reset3    MCW  kp9,errcnt
 1252rt3       RT   1,1
 1260          BER  taperr
 1265test3     BCE  *&5,68,B
 1273          B    r3
 1277          SBR  tstcnt&3,rt2
 1284          SBR  taperx&3,reset2
 1291          B    end2
 1295endeck    SBR  swich2&3,endeks
 1302          B    r2
 1306endeks    BCE  done,swich1,N
     *
     * imod, mantis, reltab, subent to ARITF
     *
 1314          CS   171
 1318          SW   101
 1322          MCW  r40&3,171
 1329          MCW  load
 1333          MCW  mvimod&6,146  to put imod into ARITF
 1340          MCW  imod,102
 1347          B    punch
 1351          MCW  where,146     to put mantis into ARITF
 1358          MCW  mantis,102
 1365          B    punch
 1369          MCW  funce&3,146   mcw 3,qfunc&3
 1376          MCW  reltab,103    relocatable function table address
 1383          B    punch
 1387          MCW  sube,146
 1394          MCW  subent,103
 1401          B    punch
     *
 1405done      BSS  snapsh,C
 1410          SBR  tpread&6,838
 1417          SBR  clrbot
 1421          SBR  loadxx&3,838
 1428          SBR  clearl&3,gmwm
 1435          LCA  condek,110
 1442          B    loadnx
     *
     * Data
     *
 1463load2     DCW  @L008693,689691,693@  topcor imod mantis gmwm
 1506errors    DCW  @CONDENSED DECK DEFERRED DUE TO INPUT ERRORS@
 1534load      DCW  @L039000,040040,040040,040040@
 1535          dc   @$@
 1536kp9       DCW  &9
 1537kp1       dcw  &1
 1538r40       R    40
 1569load1     DCW  @L014100,092097,081082,083084@
 1583kz14      DCW  @00000000000000@
 1584branch    B
 1585errcnt    DCW  #1  tape error count
 1586w1        DCW  #1
 1587mvimod    MCW  2,ariti&6  integer size to arithmetic routine
 1596where     DSA  setfp&6    where to put FP size
 1597funce     WR   qfunct&3   used to create  mcw  3,qfunct&3
 1603sube      DSA  dosub&3
 1611condek    DCW  @CONDECK3@
 1612gmwm      DCW  @}@
               ex   beginn
               END
