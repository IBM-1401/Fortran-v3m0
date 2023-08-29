               JOB  Fortran compiler -- Insert group-mark phase -- 07
               CTL  6611
     *
     * Replace the colon (5-8) that separates each statement from
     * its appendage (prefix) by a group mark with a word mark.
     * Replace integer modulus by 05 if it's zero.
     * Replace mantissa digits by 08 if it's zero.
     * 81-83 = start (top address) of first (top in memory)
     * statement.  Remember, statements are sorted by type now.
     *
     x1        equ  89
     x2        equ  94
     x3        equ  99
     *
     * Stuff in the resident area
     *
     phasid    equ  110  Phase ID, for snapshot dumps
     snapsh    equ  333  Core dump snapshot
     topcor    equ  688  Top core address from PARAM card
     imod      equ  690  Integer modulus -- number of digits
     mantis    equ  692  Floating point mantissa digits
     loadnx    equ  700  Load next overlay
     clearl    equ  707  CS at start of overlay loader
     *
     110       dcw  @group mark@
     089       dcw  000
     091       dc   00
     094       dcw  000
     096       dc   00
     *
               ORG  838
     loaddd    equ  *&1          Load address
  838beginn    MCW  83,x1
  845          SW   gm
  849loop      BCE  colon,0&X1,:
  857switch    BCE  done,0&X1,  NOP if working on format
  865          BCE  seegm,0&X1,}
  873          SBR  x1
  877          B    loop
  881colon     LCA  gm,0&X1  Replace colon by GMWM
  888          SBR  x1       get below colon
  892          C    0&X1       and then
  896          SAR  x1           below bottom word mark
  900          B    loop     Process next statement
  904seegm     MCW  0&X1,prefix
  911          BCE  format,prefix-4,F  Format statement?
  919          MCW  branch,switch
  926next      MN   0&X1     Decrease X1
  930          SBR  x1         to next statement
  934          B    loop
  938format    MCW  nop,switch
  945          B    next
     *
     * Clear from top core down to top of statements & X00
     *
  949done      MCW  topcor,x2
  956          MZ   83,k999  Compute top
  963          MZ              of statements
  964          MCW               & x00
  965clear     CS   0&X2
  969          SBR  x2
  973          C    x2,k999
  980          BU   clear
     *
     * Clear from top of statements & X00 to top of statements
     *
  985clear2    C    83,x2
  992          BE   done2
  997          MCW  blank,0&X2
 1004          CW   0&X2
 1008          SBR  x2
 1012          B    clear2
 1016done2     SW   imod-1
 1020          A    blank,mantis
 1027          C    imod,kz2   Integer modulus equal zero?
 1034          BU   notzi      No
 1039          MCW  k05,imod   Yes, use 05
 1046notzi     C    mantis,kz2   Mantissa digits equal zero?
 1053          BU   notzf        No
 1058          MCW  k08,mantis   Yes, use 08
     *
     * Load next overlay
     *
 1065notzf     BSS  snapsh,C
 1070          SBR  clearl&3,gmwm  Load clear-down-to address
 1077          LCA  squoze,phasid  Load next phase ID
 1084          B    loadnx     Load it
 1090k999      DCW  999
 1091gm        dc   @}@
 1096prefix    DCW  #5
 1097branch    B
 1098nop       NOP
 1099blank     DCW  #1
 1101kz2       DCW  00
 1103k05       DCW  05
 1105k08       DCW  08
 1111squoze    DCW  @SQUOZE@
 1112gmwm      DCW  @}@
               org  201
  203          dsa  loaddd    load address for card-to-tape program
               ex   beginn
               END
