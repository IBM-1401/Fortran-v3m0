               JOB  Fortran compiler -- Squeeze phase -- phase 08
               CTL  6611
     *
     * Remove statement keywords
     * Note unrecognizable statements and remove them
     * 81-83 = start (top address) of first (top in memory)
     * statement.  Remember, statements are sorted by type now,
     * and pushed to the bottom of available core.
     *
     x1        equ  89
     x2        equ  94
     x3        equ  99
     *
     * Stuff in the resident area
     *
     phasid    equ  110  Phase ID, for snapshot dumps
     snapsh    equ  333  Core dump snapshot
     loadnx    equ  700  Load next overlay
     clearl    equ  707  CS at start of overlay loader
     loadxx    equ  793  Exit from overlay loader
     *
     110       dcw  @squoze@
     089       dcw  000
     091       dc   00
     094       dcw  000
     096       dc   00
     099       dcw  000
     100       dc   0
     *     
               ORG  838
     loaddd    equ  *&1          Load address
  838beginn    MCW  83,x2
  845          MCW  83,x1
  852next      MCW  0&X1,seq
  859          MCW  0&X1,prefix
  866          BCE  arith,prefix-3,R   Arithmetic?
  874          BCE  endstm,prefix-3,/  End?
  882switch    BCE  same,prefix-3,X    Initially nonexistent stmt,
     *                                   later current one
     *
     * Compute address of keyword if not the same statement
     * type as the previous one
     *
  890          MZ   prefix-3,switch&7  Move statement code
  897          MN   prefix-3,switch&7    to switch D-modifier
  904          MN   prefix-3,w1
  911          ZA   w1,w3      w3 =
  918          A    w3           3 * numeric part
  922          A    w1,w3          of stmt code
  929          MZ   nozone,w3
  936          LCA  tabadr,gettab&3  Table address
  943          A    w3,gettab&3        + 3 * numeric to gettab
  950          MZ   prefix-3,gettab&2
  957          CW   gettab&1
  961          MCW  x2,save    Save x2
  968          MCW               and x1
  969          MCM  indexs,x1-2  x1,x2,x3 = 27, 54, 81
  976gettab    MCW  0,x3       Get address of keyword from table
  983          MCW  save,x2    Retrieve x2
  990          MCW               and x1
  991same      LCA  0&X1,0&X2  Move statement up
  998          SAR  x1         Address of next lower source
 1002          C    0&X2       Get B-star below nextg word mark
 1006          SAR  x2         Address of next lower target
 1010          C    0&X1,0&X3  Correct keyword?
 1017          SAR  x1         Get X1 below keyword
 1021          BU   wrong
 1026mvmore    LCA  0&X1,0&X2  Move part of stmt below keyword up
 1033          SAR  x1         Get below bottom of source statement
 1037          C    0&X2       Get below bottom
 1041          SAR  x2           of target statement
 1045ifdone    BCE  done,0&X1,   Done?
 1053          B    next
     *
     * Load next overlay
     *
 1057done      CS   0&X2
 1061          CS
 1062          BSS  snapsh,C
 1067          SBR  loadxx&3,839   Set entry address for next phase
 1074          SBR  clearl&3,gmwm  Top of cleared area
 1081          LCA  dimen1,phasid  Name of next phase
 1088          B    loadnx
     *
     * Keyword doesn't match statement code
     *
 1092wrong     CS   332
 1096          CS
 1097          SW   184        What does this do?
 1101          MN   seq,249
 1108          MN
 1109          MN
 1110          MCW  error1
 1114          W
 1115          BCV  pagovl
 1120          B    noovl
 1124pagovl    CC   1
 1126noovl     MCM  2&X2       Get above statement's top
 1130          MN                and then          
 1131          MN                  down two
 1132          SAR  x2
 1136          BCE  noovl,1&X2,|  More to move if RM
 1144          C    0&X1       Get below keyword
 1148          SAR  x1
 1152          B    ifdone     Go test if done
     *
     * Arithmetic statement
     *
 1156arith     LCA  0&X1,0&X2  Move prefix up
 1163          SAR  x1           and move
 1167          LCA  0&X2,0&X2      index registers down
 1174          SBR  x2               to statement
 1178          B    mvmore
     *
     * End statement
     *
 1182endstm    C    0&X1       Get below
 1186          C                 statement
 1187          SAR  x1
 1191          B    ifdone
     *
     * Table of addresses of statement keywords
     *
 1197table     DSA  rdtape  1 READ TAPE
 1200          DSA  0
 1203          DSA  wrtape  2 WRITE TAPE
 1206          DSA  0
 1209          DSA  rdintp  5 READ INPUT TAPE
 1212          DSA  wrottp  6 WRITE OUTPUT TAPE
 1215          DSA  0
 1218          DSA  0
 1221          DSA  nozone  9
 1224          DSA  0
 1227          DSA  stop    S STOP
 1230          DSA  cgoto   T Computed GOTO
 1233          DSA  punch   U PUNCH
 1236          DSA  0
 1239          DSA  ifsw    W IF ( SENSE SWITCH ...
 1242          DSA  0
 1245          DSA  0
 1248          DSA  rewind  Z REWIND
 1251          DSA  slite   J SENSE LIGHT
 1254          DSA  ifsl    K IF ( SENSE LIGHT ... )
 1257          DSA  read    L READ
 1260          DSA  0
 1263          DSA  endfil  N ENDFILE
 1266          DSA  0
 1269          DSA  print   P PRINT
 1272          DSA  equiv   Q
 1275          DSA  0         Arithmetic
 1278          DSA  pause   A PAUSE
 1281          DSA  backsp  B BACKSPACE
 1284          DSA  cont    C CONTINUE
 1287          DSA  do      D DO
 1290          DSA  if      E IF
 1293          DSA  format  F FORMAT
 1296          DSA  goto    G GOTO
 1299          DSA  0
 1302          DSA  dim     I DIMENSION
     *
     * Statement keywords spelled backward
     *
 1306goto      DCW  @OTOG@                 GO TO
 1311cgoto     dcw  @%OTOG@                GO TO (
 1313if        dcw  @FI@                   IF
 1327ifsw      DCW  @HCTIWSESNES%FI@       IF ( SENSE SWITCH
 1332pause     dcw  @ESUAP@                PAUSE
 1336stop      dcw  @POTS@                 STOP
 1338do        DCW  @OD@                   DO
 1346cont      dcw  @EUNITNOC@             CONTINUE
 1353format    dcw  @%TAMROF@              FORMAT (
 1357read      dcw  @DAER@                 READ
 1370rdintp    DCW  @EPATTUPNIDAER@        READ INPUT TAPE
 1375punch     dcw  @HCNUP@                PUNCH
 1380print     DCW  @TNIRP@                PRINT
 1395wrottp    DCW  @EPATTUPTUOETIRW@      WRITE OUTPUT TAPE
 1403rdtape    dcw  @EPATDAER@             READ TAPE
 1412wrtape    DCW  @EPATETIRW@            WRITE TAPE
 1419endfil    dcw  @ELIFDNE@              END FILE
 1425rewind    DCW  @DNIWER@               REWIND
 1434backsp    DCW  @ECAPSKCAB@            BACKSPACE
 1443dim       DCW  @NOISNEMID@            DIMENSION
 1454equiv     DCW  @ECNELAVIUQE@          EQUIVALENCE
 1467ifsl      DCW  @THGILESNES%FI@        IF ( SENSE LIGHT
 1477slite     DCW  @THGILESNES@           SENSE LIGHT
     *
     * Other data
     *
     indexs    equ  *&1
 1491          DCW  @0270005400081|@
 1494seq       DCW  #3  Sequence number from statement
 1498prefix    DCW  #4
 1499w1        DCW  #1  Used to compute 3 * numeric part of code
 1502w3        DCW  #3
 1503nozone    DCW  #1
 1506tabadr    DSA  table-3
 1514save      DCW  #8
 1520dimen1    DCW  @DIMEN1@
 1566error1    DCW  @ERROR 1 - UNDETERMINABLE STATEMENT, STATEMENT @
 1567gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
