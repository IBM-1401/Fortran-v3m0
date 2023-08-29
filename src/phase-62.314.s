               JOB  Fortran compiler -- GEAUX phase 2 -- phase 62
               CTL  6611
     *
     * The arithmetic routine is loiaded.  Communication is
     * established between that routine and the generated coding.
     * The index registers are initialized (but they're not).
     *
     x1        equ  89
     *
     * Addresses in the resident area
     *
     nstmts    equ  183  Number of statements, including generated stop
     *                 Beginning of code by now
     glober    equ  184  Global error flag -- WM means error
     reltab    equ  188  Relocatable function table entry addresses
     subent    equ  191  Entry to subscript routine
     imod      equ  690  Integer modulus -- number of digits
     mantis    equ  692  Floating point mantissa digits & 2
     cdovly    equ  769  1 if running from cards, N if from tape
     *
     * Addresses in ARITF
     *
     setfp     equ  831   put mantissa width into B
     qfunct    equ  1327  branch to function selector
     dosub     equ  1206  branch to subscript routine
     ariti     equ  1530  put integer size in B
     gmwm      equ  1696  group mark
     *
               ORG  201
  201beginn    BCE  cdovly,cdovly,1  load from cards
  209retry     RTW  1,700
  217          BER  taperr
  222          RWD  1
     *
     * Return here after loading
     *
  227ldret     MCW  subent,dosub&3   subscript routine entry
  234          CW   gmwm
  238          MCW  reltab,qfunct&3  relocatable function table
  245          MCW  imod,ariti&6     integer modulus
  252          MCW  mantis,setfp&6   FP mantissa width & 2
  259          CC   1
  261          BW   280,glober
  269          MCW  nstmts,x1        entry address
  276          H    0&X1
  280halt      H    halt
  284taperr    BSP  1
  289          H    3333,3333
  296          B    retry
  300          DCW  0
  301          DCW  @}@
               ex   beginn
               END
