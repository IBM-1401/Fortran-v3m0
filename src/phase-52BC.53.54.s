               JOB  Fortran compiler -- Loader Phase -- phase 52B
               CTL  6611
     *
     * Relocatable function routines and subroutines are loaded.
     * A table of the starting addresses of these routines is
     * created.
     *
     * Relocation of relocatable functions in the 1401 Fortran
     * compiler is accomplished by tagging the load instruction in
     * location 40, and the subsequent set word mark instructions, to
     * indicate what fields are to be relocated.  It is assumed that
     * they are relocated by the load address less 2000, since they
     * are assembled to be loaded at 2000.  The utility that converts
     * Autocoder decks to relocatable form assumes addresses above
     * 2000 are to be relocated.
     * 
     * If the index tag of the A field of the load instruction has A
     * and B zones, it means the B address of the load instruction and
     * both addresses of the set word mark instructions, except those
     * that are 040, are to be relocated.  Otherwise they are not to
     * be relocated.  If the index tag of the B address of the load
     * instruction has an A zone it indicates that only the B address
     * (word mark + 4--6) of the first field is to be relocated,  If
     * it has an B zone it indicates that only the A address (word
     * mark + 1--3) is to be relocated.  If it has both A and B zones
     * it indicates that both addresses are to be relocated.
     * 
     * If the index tag of either address in a set word mark
     * instruction has an A zone it indicates that only the B address
     * (word mark + 4-6) of the tagged field is to be relocated,  If
     * it has a B zone it indicates that only the A address (word
     * mark + 1-3) is to be relocated.  If it has both A and B zones
     * it indicates that both addresses are to be relocated.
     *
     * The beginning of the series routine used by the transcendental
     * functions is marked by underscore characters (11-7-8) in
     * columns 1-5 of the first load card.  The base address is saved
     * at this point in SERBAS.  Then, addresses above 4k, which are
     * above 14k, are converted to addresses above 2k, and relocated
     * by SERBAS.  This is done so that the transcendental function
     * routines can access addresses within the series function.
     *
     x1        equ  89
     x2        equ  94
     x3        equ  99
     *
     * Stuff in the resident area
     *
     phasid    equ  110  Phase ID, for snapshot dumps
     func1     equ  111  Switch to select first relocatable func
     sincos    equ  118  Saw sinf or cosf if no WM
     funcn     equ  139  Switch to select last relocatable func
     gotxl     equ  185  XLINKF was loaded
     reltab    equ  188  Top of relocatable functions & 1
     arytop    equ  194  Top of arrays in object code
     snapsh    equ  333  Core dump snapshot
     topcor    equ  688  Top core address from PARAM card
     loadnx    equ  700  Load next overlay
     clearl    equ  707  CS at start of overlay loader
     cdovly    equ  769  1 if running from cards, N if from tape
     tpread    equ  780  Tape read instruction in overlay loader
     loadxx    equ  793  Exit from overlay loader
     clrbot    equ  833  Bottom of core to clear in overlay loader
     *
     * Stuff in previous phase (52A)
     *
     exlink    equ  840   139 I xlinkf entry
     user1     equ  876   127 R user function entry
     sx2       equ  927
     conbot    equ  930   bottom of constants - 1
     arybot    equ  933   bottom of arrays - 1
     *
     110       dcw  @funload b@
     089       dcw  000
     091       dc   00
     094       dcw  000
     096       dc   00
     *
               ORG  333
     loadd1    equ  *&1          Load address
  333          H    333
  337beginn    CS   80
  341          MCW  x3,sx3
  348          SBR  x3,1&X3
  355          SW   1,40           set word
  362          SW   47,54            marks to
  369          SW   61,68              read relocatable
  376          SW   72                   subprograms
  380          MCW  cdovly,rdcard  cards if 1, tape if NOP
  387          B    rdrec          skip boundary -- five brackets
  391          MCW  83,x2
  398          MN   0&X2
  402          MN
  403          SBR  tstund&6
  407          MCW  kund1       too big if this gets clobbered
  411          NOP
  412outer     MCW  x3,add14k&3
  419          MZ   branch,add14k&2  x3 zone
  426          MCW  k14k,x3
     * why not sbr  x3,0-0 ???
  433add14k    NOP  0-0         subtract 2000 from x3 because
  437          SAR  x3            reloctables org at 2000
  441getund    B    rdrec
  445chkund    C    5,kund4     does record begin with underlines
  452          BU   notund      no
  457          MCW  x3,serbas   save base address for series function
  464          B    getund      yes, get another record
  468notund    MCW  afunc1,x1   next load switch
  475sbrnop    SBR  afunc1,1&X1   nop for second pass SIN flag
  482          C    x1,afuncn   end of load flags?  
  489          BE   switch      yes                 
  494          MCW  sbr,sbrnop
  501          C    sx2,auser1
  508swich1    BE   gotusr      user functions?
  513retusr    MCW  sx2,x2      decrement
  520          C    0&X2          function table
  524          SAR  sx2             pointer
  528          BW   skip,0&X1   Don't need deck if WM in load flag
  536mcwnop    MCW  nop,swich2  allow storing load address unless nop
  543tstrel    BWZ  norel,42,2  No relocation
  551          MN   46,load&6   load from where
  558          chain5
  563          MZ   46,load&6   load to where
  570          MN               dont clobber x3 zone tag
  571          MZ
  572load      LCA  0,0&X3      load the field from the record
  579          SBR  x2
  583swich2    NOP  mz45        skip storing load address if branch
  587          MCW  sx2,x1
  594          SBR  3&X1,1&X2   store function load address
  601          MCW  branch,swich2  skip over storing load address
  608mz45      MZ   45,savzon   relocation tag for first field
  615          B    reloc
  619          S    x1&1
  623loop      C    50&X1,a40   why not BCE norelx,50&x1,0 ???
  630          BE   norelx      at WM address 040 or at 1040 instr
  635          MCW  50&X1,swcw&3
  642          MZ   branch,swcw&2  x3 tag
  649          BCE  swcw,swcw,)
  657          MCW  sw,swcw     in case we are doing the B field
  664swcw      SW   0&X3  set or clear relocated word mark
  668          SAR  x2
  672          B    cont  branch around phase loader
  676          NOP  0
  680          DCW  @}@
               org  201
  203          dsa  loadd1    load address for card-to-tape program
               EX   loadxx
               JOB  Fortran compiler -- Loader Phase -- phase 52C
     110       dcw  @funload c@
               ORG  934
     loaddd    equ  *&1          Load address
  934cont      MZ   49&X1,savzon  relocation tag from SW instruction
  941          B    reloc
     * Add either 3 or 4 to x1 to get to next SW address
     * This would be simpler if SBR/NOP x1,1&x1 then SBR x1,3&x1 ???
  945nopadd    NOP  k4,x1  sometimes add, sometimes nop
  952addnop    A    k3,x1  sometimes add, sometimes nop
  959          BCE  exch43,nopadd,A
  967          MCW  add,nopadd
  974          MCW  nop,addnop
  981          BCE  nopadd,swcw,)  ???
  989          B    loop
  993exch43    MCW  nop,nopadd
 1000          MCW  add,addnop
 1007          B    loop
     *
     * Done with relocation of one deck
     *
 1011norelx    MCW  46,where    top address loaded?
 1018          MCW  nop,nopadd  reset add 3/4
 1025          MCW  add,addnop    toggle
 1032          B    rdrec
 1036          BCE  exend,68,B  EX card?
 1044          BCE  exend,40,/  END card?
 1052          B    tstrel
 1056exend     MCW  where,*&11  can we use load&6 here ???
 1063          MZ   branch,*&3  x3 tag
 1070          NOP  0&X3
 1074          SAR  x3
 1078          SBR  sx3
 1082          SBR  x3,1&X3     next function load address
 1089tstund    BCE  outer,0,_   not too big if still underline
 1097          CS   332
 1101          CS
 1102          CC   1
 1104          MCW  error2,270
 1111          W
 1112          CC   1
 1114          BCE  halt,cdovly,1
 1122          RWD  1
 1127halt      H    halt
     *
     * No relocation, simply execute the load code
     *
 1131norel     SBR  71,norelx
 1138          MCW  branch,68
 1145          B    40
     *
     * Read a record of the relocatable library either
     * from card or tape
     *
 1149rdrec     SBR  rdrecx&3
 1153          MCW  kb1,1   in case it was a GM in the prev record
 1160rdcard    R    rdrecx  NOP if loaded from tape
 1164reread    MCW  kp9,errcnt
 1171rdtape    RT   1,1
 1179          BER  taperr
 1184rdrecx    B    0
     *
 1188taperr    BSP  1
 1193          S    kp1,errcnt
 1200          BWZ  rdtape,errcnt,B
 1208          NOP  3333
 1212          H
 1213          B    reread
     *
     * Relocate fields of loaded instructions
     *
 1217reloc     SBR  relocx&3
 1221          BWZ  relocx,savzon,2  No relocation
 1229          BWZ  relx1,savzon,S   B field relocation only
 1237          MCW  x3,sx3
 1244          BWZ  relnz1,4&X2,2    is relocated field below 4k
 1252          MCW  serbas,x3        no, must be above 14k = 16k-2k
 1259          MZ   *-4,4&X2         thousands tag set to 2
 1266relnz1    MA   x3,4&X2          Relocate A field
 1273          MCW  sx3,x3
 1280          BM   relocx,savzon    A field relocation only
 1288relx1     MCW  x3,sx3
 1295          BWZ  relnz2,7&X2,2    is relocated field below 4k
 1303          MCW  serbas,x3        no, must be above 14k = 16k-2k
 1310          MZ   *-4,7&X2         thousands tag set to 2
 1317relnz2    MA   x3,7&X2          Relocate B field
 1324          MCW  sx3,x3
 1331relocx    B    0
     *
     * Don't need the function
     * Skip until end or ex record
     *
 1335skip      B    rdrec
 1339          BCE  getund,40,/
 1347          BCE  getund,68,B
 1355          B    skip
     *
     * Got to end of load flags
     * Start over at SINCOS to store the entry table
     *
 1359switch    NOP  done           second time it is a branch
 1363          MCW  branch,switch  only do this once
 1370          SBR  afunc1,sincos  start over at sincos
 1377          MCW  sx3,x2
 1384          SBR  reltab,1&X2    relocatable entry table address
 1391          MCW  nop,sbrnop
 1398          MCW  nop,mcwnop
 1405          MCW  branch,swich2  skip storing load address
 1412          MCW  sx3,sx3d
 1419          B    chkund
     *
     * Down to user functions in the address table
     *
 1423gotusr    MCW  sx3,sx3c  save first user function address
 1430          MCW  nop,swich1
 1437          B    retusr
     *
 1441done      MCW  sx3,x3         top of function entry table
 1448          MCW  topcor,x2
 1455          C    0&X2
 1459          SAR  x2
 1463          SBR  arybot         bottom of arrays - 1
 1467          C    0&X2
 1471          SAR  conbot         bottom of constants - 1
 1475          BCE  blank,exlink,  is xlinkf loaded
 1483          MCW  exlink,x1      yes
 1490          MA   a13,x1         why not MCW  arytop,13&x1 ???
 1497          MCW  arytop,0&X1    store within XLINKF
 1504          CW   gotxl
 1508blank     MCW  sx3c,x1  first user function address
 1515          MCW  sx3d,x2  last function load address & 1
 1522          SBR  tpread&6,934
 1529          SBR  clrbot
 1533          SBR  loadxx&3,934
 1540          SBR  clearl&3,1696
 1547          LCA  reload,phasid
 1554          B    loadnx
     *
     * Data
     *
 1560k14k      DSA  14000    14000 is 16000-2000
 1563afunc1    DCW  func1    address of first function switch
 1564          dc   #1
 1565kund1     DCW  @_@      one underline character
 1566branch    B
 1570kund4     DCW  @____@   four underline characters (11-7-8)
 1573serbas    DCW  #3       base address for series function
 1576afuncn    DSA  funcn&1  address of last function switch
 1577sbr       SBR
 1580auser1    DSA  user1    first user function entry
 1581nop       NOP
 1582savzon    DCW  #1
 1585a40       DSA  40
 1586sw        SW
 1587k4        dcw  4
 1588k3        dcw  3
 1589add       A
 1592where     DCW  #3
 1628error2    DCW  @MESSAGE 2 - OBJECT PROGRAM TOO LARGE@
 1629kb1       DCW  #1
 1630kp9       DCW  &9
 1631errcnt    DCW  #1  tape error counter
 1632kp1       dcw  &1
 1635sx3       DCW  #3
 1638sx3d      DCW  #3
 1641sx3c      DCW  #3
 1644a13       DSA  13
 1653reload    DCW  @RELOAD SS@
 1654          DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
