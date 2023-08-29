               JOB  Fortran compiler -- Overlay loader
               CTL  6611
     *
     * XLINKF loader - Function I.
     *
     * Inputs are in 84-86, (274..279)&x3 and maybe exit&(1..3).
     *
     * If the character addressed by 84-86 is $, clear from 3+(contents
     * of 84-86) down to DOWNTO, else clear from top of core.
     *
     * If the target in (274..279)&x3 is zero with some zone, load from
     * cards.  If the target is negative or blank, load the first record
     * from tape at 1 and branch to 1.  Otherwise hunt for it, and when
     * found load the next block at 333 and the one after that at 700,
     * and branch to the address stored into exit&3.
     *
     x1        equ  89
     x2        equ  94
     x3        equ  99
     *
     * Address in phase 61
     *
     aftovl    equ  1020  return here after loading this module
     *
     target    equ  279&x3
     blanks    equ  699
     *
               ORG  333
  333halt      H    halt
  337          MCW  86,x2
  344          CS   80
  348          BCE  setclr,0&X2,$  Set the clear address
     *
     * Clear from top of core or the specified clear address down to
     * DOWNTO.
     *
  356clear     CS   0
  360          SBR  clear&3
  364          C    clear&3,downto
  371          BU   clear
  376          SW   target-5
  380          MZ   target,kz6
  387          C    kz6,target
  394          BE   cdloop         Target is zero with some zone
  399          BM   load1,target   Target is negative
  407          MZ   kz6-5,target   Clear zone of low-order target char
  414          C    blanks,target
  421          BE   load1          Target is blanks
     *
     * Set GMWM in 22
     *
  426          SW   22
  430          MCW  gmwm,22
     *
     * Hunt for LIB in 8-10 and the target (target) in 12-17
     *
  437hunt      RT   1,1
  445          BEF  endfil
  450          C    10,lib
  457          BU   hunt
  462          C    17,target
  469          BE   found
  474          B    hunt
     *
     * End of file.  Change the NOP to a halt and branch to load
     * from cards, then rewind the tape and hunt again.  Thereby, the
     * tape is only searched twice.
     *
  478endfil    NOP  cdloop  Becomes  h    cdloop
  482          MCW  halt,endfil
  489          RWD  1
  494          B    hunt
     *
     * Found the target
     * Load the next block at 333 and the one after that at 700,
     * then branch to the address plugged into exit&3
     *
  498found     LCA  kz6-1,101  clear
  505          LCA  kz6-1        index
  509          LCA  kz6-1          registers
  513          RTW  1,333      Hope short enough not to clobber us
  521          BER  taperr
  526          MCW  kz6-5,kz6-1
  533          SBR  taperx&3,read2
  540read2     RTW  1,700
  548          BER  taperr
  553exit      B    0
  557taperr    A    k1,kz6-1
  564          BCE  errhlt,kz6-1,9  Nine errors?
  572          BSP  1
  577taperx    B    found
  581errhlt    H    errhlt
     *
     * Set the clear start address
     *
  585setclr    MCW  3&X2,clear&3
  592          MZ   kz6-5,clear&2
  599          B    clear
     *
     * Target is 00000X where X is zero with some zone.
     * Read cards until one with comma (SW) in column 1 is found,
     * then branch to it.
     *
  603cdloop    SW   1
  607          R
  608          BCE  1,1,,
  616          B    cdloop
     *
     * Load a block into 1 and branch to it
     *
  620load1     RWD  1
  625          RTW  1,1
  633          B    1
     *
     * Data
     *
  642kz6       DCW  000000
  645downto    DSA  699
  648lib       DCW  @LIB@
  678          DC   #30
  679k1        dcw  @1@
  680gmwm      dcw  @}@
               ex   aftovl
               END
