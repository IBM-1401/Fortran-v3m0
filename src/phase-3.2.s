               JOB  Fortran compiler -- Scanner -- phase 03
               CTL  6611
     *
     * SCANNER phase: Insert statement numbers (not labels)
     * Classify statements (format statements already classified)
     *
     x1        equ  89
     x2        equ  94
     x3        equ  99
     *
     * Stuff in the resident area
     *
     phasid    equ  110  Phase ID, for snapshot dumps
     snapsh    equ  333  Core dump snapshot routine
     *
     pword     equ  685  The word PARAM
     topcor    equ  688  Top core address from PARAM card
     imod      equ  690  Integer modulus -- number of digits
     mantis    equ  692  Floating point mantissa digits
     condns    equ  693  P for condensed deck
     snapsw    equ  694  S for snapshot
     c1410     equ  695  T if run on 1410 in 1401 compatibility mode
     fmtsw     equ  696  X for no format, L for limited format
     *                blank for ordinary, A for A conversion
     param     equ  699  Parameter card is stored here
     *
     loadnx    equ  700  Load next overlay
     clearl    equ  707  Clear instruction in LOADNX
     loadex    equ  793  Branch that exits LOADNX
     *
     * Signals used when loading from cards
     *
     110       dcw  @:@  colon 5-8
     110       dcw  @SCANNER@
     089       dcw  000
     091       dc   00
     *
               ORG  838
     loaddd    equ  *&1          Load address
     *
     * Start here.
     * Check modulus and mantissa
     *
  838beginn    MCW  topcor,corchk&6
  845          SW   imod-1,mantis-1
  852          BCE  idef,imod,   Integer modulus blank on parameter card?
  860          B    ispec        No, use specified modulus 
  864idef      MCW  intdef,imod  Yes, use default modulus
  871ispec     BCE  fdef,mantis,  Floating point mantissa blank?
  879          B    fspec        No, use specified mantissa
  883fdef      MCW  fltdef,mantis  Yes, use default mantissa
  890fspec     C    imod,intmin  Compare modulus to minimum
  897          BH   badmod
  902          C    imod,digmax	 Check integer modulus
  909          BL   badmod
  914manchk    C    mantis,digmax  Check floating point mantissa
  921          BL   badman
  926          C    mantis,fltmin
  933          BH   badman
     *
     * Report modulus and mantissa
     *
  938badret    CS   332
  942          CS
  943          MCW  modmsg,210
  950          MCS  imod,213
  957          W
  958          CS   299
  962          MCW  manmsg,211
  969          MCS  mantis,214
  976          W
  977          CC   J
     *
  979corchk    BCE  corchk,0-0,0  TOPCOR stored into B
  987          B
  988          SBR  mvback&6    stores TOPCOR-2
  992          SBR  mvstmt&3
  996mvstmt    LCA  0-0,stmtsv  Copy statement to work area
 1003          SAR  mvstmt&3    Ready for next statement
 1007          MCW  stmtno,stmtsv  Insert statement number into stmt
 1014          A    k1,stmtno        and bump it
 1021          BCE  class2,stmtyp,F  Format stmt is already classified
     *
     * Skip over the label if any
     *
 1029          SBR  chklbl&6,stmtst
 1036          SBR  stmtpt,stmtst-1  Initialize statement pointer
 1043chklbl    BCE  ststmt,stmtst,:  Found the start of the statement?
 1051          SBR  chklbl&6
 1055          SBR  chklb2&6
 1059chklb2    BCE  chklb2,0,  Decrease B register
 1067          SBR  stmtpt     Set statement pointer
 1071          B    chklbl
     *
     * Start processing the statement proper.
     * Check for assignment statement.
     *
 1075ststmt    MCW  stmtpt,endchk&6
 1082          MCW  stmtpt,eqtest&6
 1089endchk    BCE  ckword,0,}   End of statement?
 1097          B
 1098          SBR  endchk&6
 1102eqtest    BCE  eq,0-0,#
 1110          B
 1111          SBR  eqtest&6
 1115          B    endchk
     *
     * Assignment statement.
     *
 1119eq        SW   endchk&4
 1123          MCW  endchk&6,svchar&3
 1130          CW   endchk&4
 1134svchar    MCW  0-0,char
 1141          SAR  svchar&3
 1145          BCE  lparen,char,%
 1153          BCE  lparen,char,}
 1161          BCE  ckword,char,,
 1169          B    svchar
     *
     * Check keyword
     *
 1173ckword    MCW  stmtpt,*&4
 1180          MCW  0-0,word
 1187          SW   word
 1191          SW
 1192          MCW  word,*&8
 1199          BCE  bfcs1,kbfcs,  Is 1st letter B, F, C or S?
 1207          chain3
 1210          MCW  word-1,*&8
 1217tqinua    BCE  qinua2,kqinua,  Is 2nd letter Q, I, N, U or A?
 1225          chain4
 1229          SW   stmtyp
 1233          B    other
     *
     * First letter is B(ackspace), F(ormat), C(ontinue),
     * S(top) or S(enselight)
     *
 1237bfcs1     C    word-2,knse  Is word [BFCS].NSE?
 1244          BE   sense
 1249          MCW  word,stmtyp  Use first letter (BFCS) for stmt type
 1256          B    classd
 1260sense     MCW  tsense,stmtyp
 1267          B    classd
     *
     * Second letter is (e)Q(uivalence), (d)I(mension),
     * (e)N(d) or (e)N(dfile), (p)U(nch) or (p)A(use)
     *
 1271qinua2    MCW  word-1,stmtyp
 1278          BCE  n2,tqinua&7,N
 1286          B    classd
     *
     * Second letter is N.  Check for ENDFILE.
     *
 1290N2        C    word-2,kdfile  Is word .NDFILE?
 1297          BE   classd
 1302          MCW  tslash,stmtyp  Set type to /
     *
     * Statement is classified
     *
 1309classd    CW   word
 1313          CW
 1314class2    CW   stmtyp
 1318mvback    LCA  stmtsv,0  Move the statement back
 1325          SBR  mvback&6
 1329          SBR  ckblnk&6
 1333          SBR  83        Address below last stmt, for next phase
 1337ckblnk    BCE  done,0-0,
 1345          B    mvstmt
     *
     * Left parenthesis or group mark
     *
 1349lparen    MCW  eqtest&6,x1
 1356          BCE  rparen,1&X1,)
 1364          B
 1365          B    class2
 1369rparen    BCE  lpar2,2&X1,%
 1377          SBR  x1
 1381          B    rparen
 1385lpar2     BCE  f,3&X1,F
 1393          B    class2
 1397f         BCE  class2,6&X1,:
 1405          chain2
 1407          MCW  tarith,stmtyp
 1414          SW   195
 1418          B    class2
     *
     * First letter is not BFCS and second letter is not QINUA
     *
 1422other     CW   word
 1426          CW
 1427          C    word,kfi  IF ( SENSE...?
 1434          BU   notif
 1439          BCE  slite,word-8,L
 1447          MCW  tssw,stmtyp  Sense switch
 1454          B    class2
     *
     * Ninth character is L -- assume IF ( SENSE LIGHT ... )
     *
 1458slite     MCW  tslite,stmtyp
 1465          B    class2
     *
     * Bad modulus message
     *
 1469badmod    CS   332
 1473          CS
 1474          MCW  msg42,218
 1481          W
 1482          CC   J
 1484          MCW  intdef,imod
 1491          B    manchk
     *
     * Bad mantissa message
     *
 1495badman    CS   332
 1499          CS
 1500          MCW  msg43,219
 1507          W
 1508          CC   J
 1510          MCW  fltdef,mantis
 1517          B    badret
     *
     * Not an IF statement, check for others
     *
 1521notif     BCE  do,word,D
 1529          BCE  lpar3,word-2,%
 1537          BCE  lpar5,word-4,%
 1545          BCE  goto,word,G
 1553          BCE  print,word,P
 1561          BWZ  read,word-4,2
 1569          BCE  rwd,word-5,D
 1577          MCW  k1,stmtyp
 1584          MN   word-5,stmtyp  Use numeric of sixth char
 1591          B    class2
     *
     * First letter is D(o)
     *
 1595do        MCW  tdo,stmtyp
 1602          B    class2
     *
     * Third character is left parenthesis
     *
 1606lpar3     MCW  tif,stmtyp
 1613          B    class2
     *
     * Fifth character is left parenthesis -- assume computed GOTO
     *
 1617lpar5     MCW  tcgo,stmtyp
 1624          B    class2
     *
     * First character is G
     *
 1628goto      MCW  tgo,stmtyp
 1635          B    class2
     *
     * First character is P
     *
 1639print     MCW  tprint,stmtyp
 1646          B    class2
     *
     * Fifth character is numeric -- assume it's READ
     *
 1650read      MCW  tread,stmtyp
 1657          B    class2
     *
     * Sixth character is D -- assume REWIND
     *
 1661rwd       MCW  trew,stmtyp
 1668          B    class2
     *
     * All done
     *
 1672done      BSS  snapsh,C
 1677          SBR  loadex&3,1010
 1684          SBR  clearl&3,2599
 1691          LCA  sorter,phasid
 1698          B    loadnx
 1702          DCW  #1
 1703          dcw  #1
     *
     stmtst    equ  2393  Statement start
     stmtyp    equ  2394  Statement type -- F for format
     stmtsv    equ  2397
     *
     * Constants and work areas
     *
               ORG  2398
 2400stmtno    dcw  001
 2401k1        dcw  1
 2404stmtpt    DCW  #3  Statement pointer
 2405char      DCW  #1  Character being examined
 2415word      DCW  #10          
 2420KQINUA    DC   @QINUA@   Test second character of statement
 2424KBFCS     DC   @BFCS@    Test first character of statement
 2430kfi       DCW  @ESNES%FI@  IF(SENSE spelled backward
 2433trew      DC   @Z@       Statement code for REWIND
 2434tread     dc   @L@       Statement code for READ
 2435tprint    dc   @P@       Statement code for PRINT
 2436tgo       dc   @G@       Statement code for GOTO
 2437tcgo      dc   @T@       Statement code for computed GOTO
 2438tif       dc   @E@       Statement code for IF
 2439tdo       dc   @D@       Statement code for DO
 2440tssw      DC   @W@       Statement code for IF ( SENSE SWITCH ...
 2442intdef    DCW  05  Default integer modulus
 2444fltdef    DCW  08  Default floating point mantissa digits 
 2446intmin    DCW  01  Minimum integer modulus
 2448digmax    dcw  20  Maximum int mod and max FP mantissa
 2450fltmin    DCW  02  Minimum floating point mantissa digits
 2460modmsg    DCW  @MODULUS IS@
 2471manmsg    DCW  @MANTISSA IS@
 2474knse      dcw  @ESN@     NSE (part of SENSELIGHT) spelt backward
 2475tsense    DCW  @J@       Statement code for SENSE LIGHT
 2480kdfile    dcw  @ELIFD@   DFILE (part of ENDFILE) spelt backward
 2481tslash    dcw  @/@       Statement code for END
 2482tarith    DCW  @R@       Statement code for arithmetic 
 2483tslite    DCW  @K@       Statement code for IF ( SENSE LIGHT...
 2501msg42     DCW  @ERROR 42 - MODULUS@
 2520msg43     DCW  @ERROR 43 - MANTISSA@
 2530sorter    DCW  @SORTER ONE@
               org  2600
 2600gmwm      dcw  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
