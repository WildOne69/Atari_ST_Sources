MODULE Intx2Pd ; (* F�r das PD-Modula der TU M�nchen *)

FROM SYSTEM IMPORT ADR, INLINE, SETREG, REG ;
FROM RealInOut IMPORT ReadReal, WriteReal ;
FROM InOut IMPORT Read, ReadInt, WriteInt, WriteString, WriteLn ;

VAR a, b, integral : REAL ;
    N, k, wdhl : INTEGER ;
    ch : CHAR ;
    fpustatus : INTEGER ;
BEGIN
  WriteString("Dies ist ein Programm zur Berechnung von    ") ; WriteLn ;
  WriteString("Integralen nach der 3/8-Formel.             ") ; WriteLn ;
                                                                WriteLn ;
  WriteString("N�heres z.B. bei G.Engeln-M�llges/F.Reutter:") ; WriteLn ; 
  WriteString("Formelsammlung zur Numerischen Mathematik   ") ; WriteLn ;
  WriteString("Mit C-Programmen, BI Wissenschaftsverlag,   ") ; WriteLn ;
  WriteString("Mannheim, 1987                              ") ; WriteLn ;
                                                                WriteLn ;
  WriteString("Es wird die Funktion                        ") ; WriteLn ;
                                                                WriteLn ;
  WriteString("x*x                                         ") ; WriteLn ;
                                                                WriteLn ;
  WriteString("integriert. Bitte geben Sie die Interval-   ") ; WriteLn ;
  WriteString("grenzen und die N/3, ein Drittel der        ") ; WriteLn ;
  WriteString("effektiven St�tzpunkte ein:                 ") ; WriteLn ;
  WriteString("[a,b] a:") ;
  ReadReal(a) ; WriteLn ;
  WriteString("[a,b] b:") ;
  ReadReal(b) ; WriteLn ;
  WriteString("Die Berechnung l�uft zur Zeitnahme 10 mal   ") ; WriteLn ;
  WriteString("N/3 :") ;
  ReadInt(N) ; WriteLn ;
  (*Freset ;*)
  INLINE(04278H,0FA42H);
  
  
  FOR wdhl := 1 TO 10 DO
    (*FmoveS(a, fp6) ;*)
    SETREG(0,a);
    INLINE(031FCH,04700H,0FA4AH);
    INLINE(04A38H,0FA41H);
    INLINE(021C0H,0FA50H);
    INLINE(04A38H,0FA41H);
    (* a nach fp6 *) (* NUR EINFACH GENAU !!! *)
    (*FmoveS(b, fp7) ;*)
    SETREG(0,b);
    INLINE(031FCH,04780H,0FA4AH);
    INLINE(04A38H,0FA41H);
    INLINE(021C0H,0FA50H);
    INLINE(04A38H,0FA41H);
    (* b nach fp7 *)
  
    (*FmoveW(N, fp4) ;*)
    SETREG(8,ADR(N));
    INLINE(031FCH,05200H,0FA4AH);
    INLINE(04A38H,0FA41H);
    INLINE(031D0H,0FA50H);
    INLINE(04A38H,0FA41H);
    (* NUR WORD, NICHT LONGWORD WEGEN PD-MODULA !!! *)
    (*FmulB(3, fp4) ;*)
    INLINE(031FCH,05A23H,0FA4AH);
    INLINE(04A38H,0FA41H);
    INLINE(011FCH,00003H,0FA50H);
    INLINE(04A38H,0FA41H);
    
    (*Fmove(fp7, fp5) ;*)
    INLINE(031FCH,01E80H,0FA4AH);
    INLINE(04A38H,0FA41H);
    
    (*Fsub(fp6, fp5) ;*)
    INLINE(031FCH,01AA8H,0FA4AH);
    INLINE(04A38H,0FA41H);
    
    (*FdivL(fp4, fp5) ;*)
    INLINE(031FCH,012A0H,0FA4AH);
    INLINE(04A38H,0FA41H);
    INLINE(04E71H,04E71H,04E71H,04E71H,04E71H,04E71H);
    (* h := b-a/3N nach fp5 *)
  
    (*Fmovecr(15, fp4) ;*)
    INLINE(031FCH,05E0FH,0FA4AH);
    INLINE(04A38H,0FA41H);
    (* dreifach gewichtete Summen in fp4 auf 0.0 *)
    (*Fmovecr(15, fp3) ;*)
    INLINE(031FCH,05D8FH,0FA4AH);
    INLINE(04A38H,0FA41H);
    (* doppelt gewichtete Summen in fp3 auf 0.0 *)
  
    (*Fmove(fp6, fp1) ;*)
    INLINE(031FCH,01880H,0FA4AH);
    INLINE(04A38H,0FA41H);
    (* in fp1 soll immer x an f(x) �bergeben werden *) 
    
    FOR k := 1 TO N-1 DO
      (*Fadd(fp5, fp1) ;*)
      INLINE(031FCH,014A2H,0FA4AH);
      INLINE(04A38H,0FA41H);
      (* h zu a addieren *)    
      (*Fmove(fp1, fp0) ;*)
      INLINE(031FCH,00400H,0FA4AH);
      INLINE(04A38H,0FA41H);
      
      (*Fmul(fp0, fp0) ;*)
      INLINE(031FCH,00023H,0FA4AH);
      INLINE(04A38H,0FA41H);
      INLINE(04E71H);
      (* f(x) = x^2 *)
      (*Fadd(fp0, fp4) ;*)
      INLINE(031FCH,00222H,0FA4AH);
      INLINE(04A38H,0FA41H);
      (* f(a+(3k-2)h) *)
   
      (*Fadd(fp5, fp1) ;*)
      INLINE(031FCH,014A2H,0FA4AH);
      INLINE(04A38H,0FA41H);
      (* h zu a addieren *)
      (*Fmove(fp1, fp0) ;*)
      INLINE(031FCH,00400H,0FA4AH);
      INLINE(04A38H,0FA41H);
      
      (*Fmul(fp0, fp0) ;*)
      INLINE(031FCH,00023H,0FA4AH);
      INLINE(04A38H,0FA41H);
      INLINE(04E71H);
      (* f(x) = x^2 *)
      (*Fadd(fp0, fp4) ;*)
      INLINE(031FCH,00222H,0FA4AH);
      INLINE(04A38H,0FA41H);
      (* f(a+(3k-1)h) *)
  
      (*Fadd(fp5, fp1) ;*)
      INLINE(031FCH,014A2H,0FA4AH);
      INLINE(04A38H,0FA41H);
      (* h zu a addieren *)
      (*Fmove(fp1, fp0) ;*)
      INLINE(031FCH,00400H,0FA4AH);
      INLINE(04A38H,0FA41H);
      
      (*Fmul(fp0, fp0) ;*)
      INLINE(031FCH,00023H,0FA4AH);
      INLINE(04A38H,0FA41H);
      INLINE(04E71H);
      (* f(x) = x^2 *)
      (*Fadd(fp0, fp3) ;*)
      INLINE(031FCH,001A2H,0FA4AH);
      INLINE(04A38H,0FA41H);
      (* f(a+3kh) *)
    END ;
    (*Fadd(fp5, fp1) ;*)
    INLINE(031FCH,014A2H,0FA4AH);
    INLINE(04A38H,0FA41H);
    (* h zu a addieren *)    
    (*Fmove(fp1, fp0) ;*)
    INLINE(031FCH,00400H,0FA4AH);
    INLINE(04A38H,0FA41H);
    
    (*Fmul(fp0, fp0) ;*)
    INLINE(031FCH,00023H,0FA4AH);
    INLINE(04A38H,0FA41H);
    INLINE(04E71H);
    (* f(x) = x^2 *)
    (*Fadd(fp0, fp4) ;*)
    INLINE(031FCH,00222H,0FA4AH);
    INLINE(04A38H,0FA41H);
    (* f(a+(3k-2)h) *)
   
    (*Fadd(fp5, fp1) ;*)
    INLINE(031FCH,014A2H,0FA4AH);
    INLINE(04A38H,0FA41H);
    (* h zu a addieren *)
    (*Fmove(fp1, fp0) ;*)
    INLINE(031FCH,00400H,0FA4AH);
    INLINE(04A38H,0FA41H);
    
    (*Fmul(fp0, fp0) ;*)
    INLINE(031FCH,00023H,0FA4AH);
    INLINE(04A38H,0FA41H);
    INLINE(04E71H);
    (* f(x) = x^2 *)
    (*Fadd(fp0, fp4) ;*)
    INLINE(031FCH,00222H,0FA4AH);
    INLINE(04A38H,0FA41H);
    (* f(a+(3k-1)h) *)
  
    (*FmulB(2, fp3) ;*)
    INLINE(031FCH,059A3H,0FA4AH);
    INLINE(04A38H,0FA41H);
    INLINE(011FCH,00002H,0FA50H);
    INLINE(04A38H,0FA41H);
    (* Summe zweifach gewichten *) 
    (*FmulB(3, fp4) ;*)
    INLINE(031FCH,05A23H,0FA4AH);
    INLINE(04A38H,0FA41H);
    INLINE(011FCH,00003H,0FA50H);
    INLINE(04A38H,0FA41H);
    (* Summe dreifach gewichten *)
    (*Fadd(fp3, fp4) ;*)
    INLINE(031FCH,00E22H,0FA4AH);
    INLINE(04A38H,0FA41H);
    (* Summen addieren *)
    (*Fmove(fp7, fp1) ;*)
    INLINE(031FCH,01C80H,0FA4AH);
    INLINE(04A38H,0FA41H);
    
    (*Fmove(fp1, fp0) ;*)
    INLINE(031FCH,00400H,0FA4AH);
    INLINE(04A38H,0FA41H);
    
    (*Fmul(fp0, fp0) ;*)
    INLINE(031FCH,00023H,0FA4AH);
    INLINE(04A38H,0FA41H);
    INLINE(04E71H);
    (* f(x) = x^2 *)
    (*Fadd(fp0, fp4) ;*)
    INLINE(031FCH,00222H,0FA4AH);
    INLINE(04A38H,0FA41H);
    (* f(b) zur Summe addieren *)
    (*Fmove(fp6, fp1) ;*)
    INLINE(031FCH,01880H,0FA4AH);
    INLINE(04A38H,0FA41H);
    
    (*Fmove(fp1, fp0) ;*)
    INLINE(031FCH,00400H,0FA4AH);
    INLINE(04A38H,0FA41H);
    
    (*Fmul(fp0, fp0) ;*)
    INLINE(031FCH,00023H,0FA4AH);
    INLINE(04A38H,0FA41H);
    INLINE(04E71H);
    (* f(x) = x^2 *)
    (*Fadd(fp0, fp4) ;*)
    INLINE(031FCH,00222H,0FA4AH);
    INLINE(04A38H,0FA41H);
    (* f(a) zur Summe addieren *)
    (*Fmul(fp5, fp4) ;*)
    INLINE(031FCH,01623H,0FA4AH);
    INLINE(04A38H,0FA41H);
    INLINE(04E71H);
    
    (*FmulD(0.375, fp4) ;*)
    INLINE(031FCH,05623H,0FA4AH);
    INLINE(04A38H,0FA41H);
    INLINE(021FCH,03FD8H,00000H,0FA50H);
    INLINE(021FCH,00000H,00000H,0FA50H);
    INLINE(04A38H,0FA41H);
    (* Integral = 3h/8 * Summe *)
    
    (*FmoveS(fp4, integral) ;*)
    SETREG(8,ADR(integral));
    INLINE(031FCH,06600H,0FA4AH);
    INLINE(04A38H,0FA41H);
    INLINE(04E71H,04E71H);
    INLINE(04A38H,0FA41H);
    INLINE(020B8H,0FA50H);
    INLINE(04A38H,0FA41H);
    (* NUR EINFACH GENAU WEGEN PD-MODULA !!! *)
  
    (*Fstatus ;*)
    SETREG(8,ADR(fpustatus));
    INLINE(030B8H,0FA40H);
    
  END ;   
  WriteReal(integral, 12) ; WriteLn ;
  WriteString("fpustatus: ") ; WriteInt(fpustatus, 6) ; WriteLn ;
  Read(ch) ;
END Intx2Pd.

 
  
  
  
  
 
  
  
  
  
