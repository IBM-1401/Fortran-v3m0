               JOB  Fortran compiler -- Arithmetic interpreter
               CTL  6611
               ORG  87
   89x1        DCW  000
   91          DC   00
   94x2        DCW  000
   96          dc   00
   99x3        DCW  000
  100          dc   0
     *
     * Arithmetic interpreter
     *
     * General form of interpreted string is
     * operand [ operator operand ... ],
     * however, if operand has a word mark, it's an operator,
     * usually a function call.  Operands are machine addresses,
     * with a tag in the tens digit to indicate type: A- or B-
     * zone alone indicates integer.  Operators are one character.
     * Subscript calculations are surrounded by $...$.
     *
     * Two accumulators in the print area are used.  The low-order
     * digit of an operand is loaded into accumulator 1 at 250; it
     * extends leftward  by the length of the operand, and rightward
     * from the left end by the mantissa width.  Accumulator 2 has its
     * high-order digit at acchi&1; it extends rightward by the mantissa
     * width.
     *
     * In the Fortran manual C24-1455, the high-order digit of
     * accum 2 is labeled ACCHI&1.
     *
     acchi     equ  279
     *
     * Mostly, index register usage is
     * X1 = operand address
     * X2 = interpreter's counter, low-order digit of accum 1
     * X3 = operand width
     *
               ORG  700
  700aritf     SBR  x2
  704          SBR  x1-3        Interpreter address for dumps
  708          SBR  ermsi&6     Interpreter address for err msgs
  712nxtop     MCW  2&X2,x1     x1 = Operand (result) address
  719          SAR  sx2a&6      Save x2-1
  723nxtop0    SBR  sx2b&6        twice
  727          BCE  dosub,0&X2,$  Subscript?
  735          SBR  res&6,0&X1  Save x1 (result address)
  742          CS   303         Clear accumumulators
  746          CS
  747          CS
  748          LCA  kz1,acchi&1     Set high-order zero in accum 2
  755nxtop1    S    x1&2        Clear x1
  759sx2a      SBR  x2,0-0      recover x2 = addr(operand) - 1
  766          C    4&X2,asgop  Compare op to assignment op
  773          MCW  4&X2,savop  Save whatever operator it is
  780          SW   201
  784          BL   func        func if assignment op .lt. operator
     *
     * Assignment op greater or equal to operator, i.e., operator is
     * blank, ., ) lozenge, } group mark, &, $, *, -, /, comma, %, #
     *
  789          SBR  nxtop2&6,4&X2  Save addr of operator
  796          BCE  dosub5,5&X2,$  Subscript?
  804          MCW  7&X2,x1     Second operand address to x1
  811          SAR  sx2a&6      save 4&x2
  815tstzon    BWZ  ariti,x1-1,K  Operand 2 tag is B zone (integer)?
  823          BWZ  ariti,x1-1,S  Operand 2 tag is A zone (integer)?
  831          SBR  x3,0        Loader plugs mantissa width into B
  838          CW   iflag       Indicate floating point
  842          MCW  0&X1,exp1-1   Save exponent 1
  849          SAR  x1          Save mantissa 1 address
  853          MCW  0&X1,250    mantissa 1 to accumulator 1
     * From here, X2 indexes accum 1, first high, then low digit
  860          SBR  x2          Set X2 to accum 1 address - op width
  864          LCA  kz1         Append a high-order zero to accum 1
  868nxtop2    BW   nosign,0-0  WM under operator?
  876          MZ   250,zas     Sign of operand 1 determines ZA or ZS
  883nosign    S    kz1,252&X3  Add zeros below mantissa
  890          C    1&X2,kz1    Compare operand high-order digit to 0
  897          A    x3,x2       x2 now at low-order digit of accum 1
  904          BCE  fdiv,savop,/  Divide?
  912          BCE  fmpy,savop,*  Multiply?
  920          S    savop         Turn it back to ZA
  924savop     ZA   zas           Copy this op code
  928          BCE  nmlz1,acchi&1,0   high-order digit of accum 2 zero?
  936          BE   clrwk         Accum 1 high-order digit is zero
  941          S    exp1-1,exp2-1  exp2 is now exp2 - exp1
  948          ZA   exp2,x1&1     Move abs(exp2-exp1) to x1
  955          C    x3,x1  compare mantissa width and abs(exp2-exp1)
  962          BM   e1gte2,exp2-1  exp1 .gt. exp2
  970          BH   exdgmw        abs(exp2-exp1) .gt. mantissa width
  975          A    exp2-1,exp1-1  Add exp2-exp1 to exp1
  982          ZA   250,250&X1    Shift mantissa right by exp2-exp1
  989          ZA   x3&1,x1&1     X1 and X3 now both mantissa width
  996addsub    MZ   zas,0&X2      Sign of accum 1 depends on op
 1003          A    acchi&X1,0&X2   Add (subtract) mantissas
     *
     * Relocatable functions return here too
     *
 1010fret      MZ   0&X2,zas
     *
     * Normalize floating-point result of a single arithmetic
     * operation; place the normalized result in the working
     * accumulator.  If exponent overflow is detected, go to ERMSG to
     * print message (NOF); then go to STR99.  If exponent underflow
     * is detected, go to STRZE.  Here, the low-order digit of the
     * result is indexed by x2.
     *
     * The normalized result is left in accum 2.
     *
 1017nmlz1     ZA   exp1-1,exp2-1
 1024nmlz2     MCW  rm,1&X2    Insert RM after low-order digit
 1031          MZ              Chain
 1032          MZ                two zeros
 1033          A               and add another one
 1034          MN              Decr A and B (copies junk to unused)
 1035          SBR  x1         X1 is now two below accum 1 high-order
 1039          S    acchi&2&X3    Clear accum 2
 1043nmlzl     BCE  strze,2&X1,|  Record mark indicates zero result
 1051          SBR  x1            Bump x1
 1055          BCE  nmlzl,1&X1,0  Zero means more normalization needed
 1063          MCM  1&X1,acchi&1      Normalize
 1070          S    x3,x2
 1077          CW                 Decrease AS and BS to
 1078          CW                   refer to X2 and X1
 1079          S                  S    x2,x1
 1080          S    x1,exp2-1     Store normalized exponent
 1087zas       ZA   acchi&X3        ZS if accum 1 negative
 1091          SW
 1092          BCE  clrwk,exp2-3,0
 1100          BM   strze,exp2-1  Exponent underflow
 1108          B    ermsg         Exponent overflow
 1114          DCW  @NOF@
     *
     * Exponent overflow; set result magnitude equal to largest
     * value possible in floating-point notation; set result sign
     * as appropriate.
     *
 1115str99     ZA   kp99,exp2-1   -99 to exp2
 1122          MN   kp99,acchi&X3   All 9's
 1129          MCW                  to mantissa
 1130          MCW  acchi-1&X3            in accum2
     *
     * Clear accum 1 after an individual arithmetic operation
     *
 1134clrwk     CS   acchi-1
 1138          B    nxtop1
     *
     * Exponent underflow, or result is zero.  Set floating-point
     * result to zero
     *
 1142strze     S    exp2-1  exp2 = 0
 1146          S    acchi&X3  accum 2 mantissa = 0
 1150          B    clrwk
     *
     * Division by zero
     *
 1154dverr     B    ermsg
 1160          dcw  @DZE@  Divide by zero message
 1161          B    str99  Insert overflow exponent
     *
     * exp1 is greater than exp2
     *
 1165e1gte2    BH   nmlz1  abs(exp2-exp1) .gt. mantissa width
 1170          S    x3&1,x1&1  subtr man. width from abs(exp2-exp1) 
 1177          MZ   acchi&X3,acchi&X1  Move zone over to new width
 1184          B    addsub  Go add (or subtract) mantissas
     *
     * abs(exp2-exp1) .gt. mantissa width
     *
 1188exdgmw    A    exp1-1,exp2-1  Restore exp2
 1195          B    clrwk
     *
     * Calculate subscripted address using a relocatable routine that
     * is only loaded if needed.
     *
 1199dosub5    SBR  x2,5&X2  Bump x2 to beginning of subscript info
 1206dosub     B    0-0  Loader plugs subscript routine address here
     *
 1210          MN   0&X2  Subtract 4 from x2
 1214          MN
 1215          MN
 1216          MN
 1217          SAR  sx2a&6
 1221sx2b      BCE  nxtop0,0-0,$
 1229          B    tstzon
     *
     * Floating-point divide
     *
 1233fdiv      BE   dverr     Divide by zero (compare was at nosign)
 1238          MN   acchi&X3,1&X2
 1245          MCW
 1246          MN
 1247          D    0&X1,251  Divide mantissas.
 1254          ZS   exp1-1    Negate exponent
 1258          B    exps      Go add exponents, normalize, etc.
     *
     * Floating-point multiply
     *
 1262fmpy      M    acchi&X3,251&X3  Multiply mantissas
 1269          SBR  x2,3&X2
 1276          S    kp2,exp2-1
 1283exps      A    exp1-1,exp2-1  Add exponents
 1290          MZ   acchi&X3,*&1  Prepare to
 1297          ZA   zas           set sign of result
 1301          B    nmlz2       Normalize
     *
     * Assignment operator is less than current operator, i.e.,
     * current operator is one of @, ?, A-I, !, J-R, |, S-Z, 0-9.
     * If not record mark, it's the first character of what would
     * otherwise be an operand, so bump the operand address.
     *
 1305func      BCE  done,4&X2,|  Done (record mark)?
 1313          SBR  sx2a&6,1&X2  Bump operand addr
 1320          C    acchi&1,kz1      High-order accum 2 mantissa digit
     * The loader plugs the relocatable function selector address here
 1327qfunct    B    0            Go to function selector
 1331done      BCE  res,acchi&1,0    Floating-point result zero?
 1339          BW   res,iflag    Integer result?
 1347          BW   fpres,4&X2   WM under operator?
 1355          SBR  x3,2&X3
 1362sexp2     MCM  exp2-2,acchi-1&X3  Move exp2 to accum 2
 1369res       LCA  acchi&X3,0     Store accumulator to saved B
 1376          BW   5&X2,4&X2    Return if done (word mark)
 1384          SAR  x2           Bump x2 to next operand
 1388          B    nxtop
     *
     * Round nonzero floating-point result
     *
 1392fpres     A    kp5,acchi-1&X3   Round mantissa
 1399          BWZ  carry,acchi&1,S  Carry in acc2 shown by A-zone?
 1407cpzone    MZ   acchi&X3,acchi-2&X3  Move zone from exp to man
 1414          B    sexp2
 1418carry     A    kp1,exp2-1   Bump exponent
 1425          BCE  fovfl,exp2-3,1  Overflow?
 1433          S    acchi&X3       Clear mantissa
 1437          LCA  k1b-1,acchi&1  and put 1 in its high-order digit
 1444          B    cpzone
     *
     * Floating-point overflow -- high-order digit of exp2 is 1
     *
 1448fovfl     MN   kp99,acchi&X3  99 to
 1455          MCW                 exponent
 1456          MCW  acchi-1&X3     all 9s to mantissa
 1460          S    kp1,exp2-1
 1467          B    cpzone
     *
     * Print appropriate error messages, which includes a mnemonic
     * three-character code and the display address in the generated
     * procedure of the source program statement being executed.  This
     * subroutine is used to record circumstances, occurring during
     * arithmetic operations, which may affect the calculation
     * adversely.
     *
 1471ermsg     SBR  ersvx&6    Save return address
 1475          CS   202&X3
 1479          SBR  ersx3&6,0&X3  Save x3
 1486ersvx     SBR  x3,0       Return address to x3
 1493          MCW  2&X3,212   Mnemonic to print area
 1500ermsi     SBR  217,0      Interpreter address to print area
 1507          W
 1508          SW   201
 1512          SBR  ermsgx&3,3&X3  Return address to exit
 1519ersx3     SBR  x3,0       Restore x3
 1526ermsgx    B    0
     *
     * Operand tens digit has A or B but not AB zone (integer arith.)
     *
 1530ariti     SBR  x3,0          Loader puts integer size in B
 1537          SW   iflag         Indicate integer
 1541          MCS  0&X1,250      Operand to accumulator 1
 1548          BCE  xdiv,savop,/  Divide?
 1556          BCE  xmpy,savop,*  Multiply?
 1564          BM   xsub,savop    Subtract?
 1572          A    0&X1,acchi&X3   Add operand to accumulator 2
 1579xsign     ZA   acchi&X3        Put a sign on the accumulator
 1583          B    clrwk
 1587xsub      S    0&X1,acchi&X3   Subtract operand from accumulator 2
 1594          B    xsign
 1598xmpy      LCA  0&X1,250      Move operand to accumulator 1
 1605          M    acchi&X3,251&X3
 1612          MCW  251&X3,acchi&X3
 1619          B    clrwk
 1623xdiv      BCE  dverr,250,    Divide by zero?
 1631          MCW  0&X1,250&X3
 1638          MN
 1639          SBR  moveq&3       Store addr to move to accum 2
 1643          LCA  acchi&X3
 1647          ZA   acchi&X3,250&X3
 1654          D    0&X1,251
 1661moveq     MCW  249,acchi&X3
 1668          B    clrwk
     *
     * Data
     *
 1674          dcw  000     Chained to RM
 1675rm        DCW  @|@
 1676          DCW  0
 1680exp2      DCW  @000|@  Exponent of accum 2, and zero and RM
 1683exp1      dcw  000     Exponent of accum 1, and zero
 1684k8        dcw  8
 1685kz1       DCW  0
 1686asgop     dcw  @#@     Assignment operator
 1687iflag     DCW  #1      Word mark indicates integer
 1689kp99      dcw  &99     Used for overflow
 1690kp2       DCW  &2
 1691kp5       dcw  &5
 1692kp1       dcw  &1
 1694k1b       dcw  @1 @
 1695          DCW  0
 1696gmwm      dc   @}@     group mark
               end
