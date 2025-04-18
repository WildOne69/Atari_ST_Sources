IMPLEMENTATION MODULE Debug; (* V#050, Stand: 21.8.91 *)
(*$B+,R-,F-*)

(*
 * Version f�r MOS 1.x erstellt Mai '87 von Thomas Tempelmann
 * Version f�r MOS 2.x erstellt M�rz '90 von Thomas Tempelmann
 *)

(*
 *   G E M - V e r s i o n
 *  =======================
 *
 * Gibt Modula-Zeilen aus, die erzeugt werden, wenn im Quelltext die
 * Compiler-Option "(*$D+*)" verwendet wird.
 *
 * Eine "Debug"-Ausgabeanweisung, die der Compiler erzeugt, hat folg. Format:
 *
 *   ... normaler Maschinencode ...
 *   TRAP #5       -  Assembler-Anweisung, l�st TRAP-5 Exception aus.
 *   DC.W cmd      -  Kennung, die bestimmt, ob Zeile oder eine Zahl angezeigt
 *                    werden soll (siehe unten, Funktion 'dispLine').
 * [ ASC  '...' ]  -  Modula-Text, falls eine Zeile angezeigt werden soll;
 *                    sonst steht die bestimmte Zahl auf dem Parameterstack.
 *)

FROM SYSTEM IMPORT ADR, ADDRESS, BYTE, WORD, LONGWORD;

FROM Excepts IMPORT InstallPreExc;

FROM PrgCtrl IMPORT TermProcess, CatchProcessTerm, TermCarrier;

FROM Strings IMPORT Length, String, Empty;

FROM MOSGlobals IMPORT UserBreak, MemArea;

FROM SysTypes IMPORT ExcSet, TRAP5, ExcDesc;

FROM TextWindows IMPORT Read, CondRead, ReadString, ForceMode,
        FlushKbd, WQualitySet, WindowQuality, Window, ShowMode;

IMPORT TextWindows;

FROM ModCtrl IMPORT GetModName;

FROM SysUtil1 IMPORT Peek;

IMPORT StrConv;

IMPORT SYSTEM, FPUSupport;

FROM GEMShare IMPORT error;


TYPE Mode = (m2Line, asmLine, procEntry, procExit);

VAR WaitNext, WaitKey: BOOLEAN;

    io: Window;


PROCEDURE WriteString (REF s:ARRAY OF CHAR);
  BEGIN
    TextWindows.WriteString (io,s)
  END WriteString;

PROCEDURE Write (s: CHAR);
  BEGIN
    TextWindows.Write (io,s)
  END Write;

PROCEDURE WriteLn;
  BEGIN
    TextWindows.WriteLn (io)
  END WriteLn;

PROCEDURE WriteLHex (v:LONGWORD; n: CARDINAL);
  BEGIN
    WriteString (StrConv.LHexToStr (v, n))
  END WriteLHex;

PROCEDURE dispRegs (VAR info: ExcDesc);
  BEGIN
    WriteLn;
    WITH info DO
      WriteString ('D0:');  WriteLHex (regD0,9);
      WriteString (' D1:'); WriteLHex (regD1,9);
      WriteString (' D2:'); WriteLHex (regD2,9);
      WriteString (' D3:'); WriteLHex (regD3,9);
      WriteLn;
      WriteString ('D4:');  WriteLHex (regD4,9);
      WriteString (' D5:'); WriteLHex (regD5,9);
      WriteString (' D6:'); WriteLHex (regD6,9);
      WriteString (' D7:'); WriteLHex (regD7,9);
      WriteLn;
      WriteString ('A0:');  WriteLHex (regA0,9);
      WriteString (' A1:'); WriteLHex (regA1,9);
      WriteString (' A2:'); WriteLHex (regA2,9);
      WriteString (' A3:'); WriteLHex (regA3,9);
      WriteLn;
      WriteString ('A4:');  WriteLHex (regA4,9);
      WriteString (' A5:'); WriteLHex (regA5,9);
      WriteString (' A6:'); WriteLHex (regA6,9);
      WriteString (' A7:'); WriteLHex (regUSP,9);
    END
  END dispRegs;


PROCEDURE dispLine (mode: Mode; VAR info: ExcDesc);
  
  VAR buffered: BOOLEAN; bufCh: CHAR;
  
  PROCEDURE KeyPress():BOOLEAN;
    BEGIN
      CondRead (bufCh,buffered);
      RETURN buffered
    END KeyPress;
  
  PROCEDURE GetKey (VAR ch:CHAR);
    BEGIN
      IF buffered THEN
        buffered:= FALSE;
        ch:= bufCh
      ELSE
        TextWindows.BusyRead (ch)
      END
    END GetKey;
  
  VAR ch:CHAR; s:ARRAY [0..9] OF CHAR; p:CARDINAL; done,ok:BOOLEAN;
      ps: POINTER TO ARRAY [0..160] OF CHAR;
      proc,name: ARRAY [0..39] OF CHAR; rel: LONGCARD;
  
  BEGIN (* dispLine *)
    IF WaitKey THEN
      buffered:= FALSE;
      IF ~Continuous OR KeyPress() THEN
        IF Active THEN TextWindows.Show (io) END;
        REPEAT
          GetKey (ch);
          IF TextWindows.WasClosed (io) THEN
            TextWindows.Hide (io);
            Active:= FALSE
          END;
          ok:= TRUE;
          CASE CAP (ch) OF
            15C: Continuous:= TRUE|                             (* RETURN *)
            ' ': Continuous:= FALSE|                            (* SPACE *)
            3C : TermProcess (UserBreak)|                       (* CTRL-C *)
            'A': Step:= 0L; Active:= TRUE; Continuous:= FALSE|
            'S': WriteString ('Step? '); ReadString (io,s); p:=0;
                 Step:= StrConv.StrToLCard (s,p,done);
                 IF done THEN
                   Active:= FALSE; Continuous:= TRUE; TextWindows.Hide (io);
                 END|
            'L': LineAddr:= ~LineAddr; ok:= FALSE|
            'H': Hex:= TRUE; ok:= FALSE|
            'D': Hex:= FALSE; ok:= FALSE|
            'R': dispRegs (info); ok:= FALSE|
          ELSE
            ok:= FALSE
          END
        UNTIL ok
      END
    END;
    
    IF WaitNext THEN FlushKbd; WaitKey:= TRUE; WaitNext:= FALSE END;
    
    IF Active THEN Step:= 0L END;
    
    IF Step # 0L THEN
      DEC (Step);
      IF Step = 0L THEN Active:= TRUE; Continuous:= FALSE END;
    END;
    
    ps:= info.regPC;                    (* PC hinter Zeilentext setzen *)
    INC (info.regPC,Length (ps^)+1);
    IF ODD (info.regPC) THEN INC (info.regPC) END;
    
    IF Active THEN                      (* Zeile anzeigen *)
      WriteLn;
      IF (mode = m2Line) OR (mode = asmLine) THEN
        IF LineAddr THEN
          WriteLHex (info.regPC,9);
          WriteString (': ');
          GetModName (info.regPC,name,rel,proc);
          WriteString (name);
          WriteString (' / ');
          IF ~Empty (proc) THEN
            WriteString (proc)
          ELSE
            WriteLHex (rel,5)
          END;
          WriteLn;
        END;
        IF ps^[0]=12C (* LF *) THEN INC (ps) END;
        WriteString (ps^);
        WriteLn;
      ELSE
        IF mode = procEntry THEN
          WriteString ('Enter ')
        ELSE
          WriteString ('                                   Exit ')
        END;
        WriteString (ps^);
      END;
    END;
  END dispLine;


MODULE RealSupport;

  FROM SYSTEM IMPORT LONGWORD, ASSEMBLER;
  FROM FPUSupport IMPORT NewContext, SaveContext, RestoreContext, FPUContext;

  EXPORT SaveTempRealRegs, RestoreTempRealRegs;

  TYPE TempRealRegBuffer = ARRAY [1..6] OF LONGWORD;

  VAR buffer: TempRealRegBuffer;
  VAR fpu: FPUContext;

  PROCEDURE SaveTempRealRegs ();
    BEGIN
      ASSEMBLER
        ; die ersten 3 Pseudo-Regs aus dem Modul Runtime
        LEA buffer,A1
        LEA @FP0L,A0 MOVEQ #5,D0 l1 MOVE.L (A0)+,(A1)+ DBRA D0,l1
      END;
      SaveContext (fpu);
    END SaveTempRealRegs;

  PROCEDURE RestoreTempRealRegs ();
    BEGIN
      ASSEMBLER
        LEA buffer,A1
        LEA @FP0L,A0 MOVEQ #5,D0 l1 MOVE.L (A1)+,(A0)+ DBRA D0,l1
      END;
      RestoreContext (fpu);
    END RestoreTempRealRegs;

  BEGIN
    NewContext (fpu)
  END (* MODULE *) RealSupport;


PROCEDURE HdlExc ( VAR info: ExcDesc ): BOOLEAN;

  PROCEDURE loadValue (VAR v: ARRAY OF BYTE);
    (* holt Wert vom A3-Stack und korrigiert A3 dabei auch *)
    VAR n: CARDINAL;
    BEGIN
      n:= HIGH (v);
      IF n = 0 THEN INC (n) END;
      DEC (info.regA3.p, n+1);
      Peek (info.regA3.p, v);
    END loadValue;

  PROCEDURE dispNum (size: CARDINAL; signed: BOOLEAN);
    VAR by: BYTE; wd: WORD; lw: LONGWORD;
    BEGIN
      IF size = 4 THEN
        loadValue (lw);
      ELSE
        IF size = 2 THEN
          loadValue (wd);
        ELSE
          loadValue (by);
          IF signed THEN
            wd:= WORD (INT (by))
          ELSE
            wd:= WORD (ORD (by))
          END
        END;
        IF signed THEN
          lw:= LONGWORD (LONG (INTEGER (wd)))
        ELSE
          lw:= LONGWORD (LONG (CARDINAL (wd)))
        END
      END;
      IF Active THEN
        IF Hex THEN
          WriteLHex (lw,0);
        ELSIF signed THEN
          WriteString (StrConv.IntToStr (LONGINT (lw),0));
        ELSE
          WriteString (StrConv.CardToStr (LONGCARD (lw),0));
        END
      END;
    END dispNum;

  PROCEDURE dispChar ();
    VAR ch: CHAR;
    BEGIN
      loadValue (ch);
      IF Active THEN
        IF ch < ' ' THEN       (* Steuerzeichen als Oktalkonstante anzeigen *)
          WriteString (StrConv.NumToStr (ORD (ch),8,0,' '));
          Write ('C')
        ELSE
          Write ("'");
          Write (ch);
          Write ("'");
        END
      END;
    END dispChar;

  PROCEDURE dispReal (long: BOOLEAN);
    VAR sr: REAL; lr: LONGREAL;
    BEGIN
      IF long THEN
        loadValue (lr)
      ELSE
        loadValue (sr);
        lr:= LONG (sr)
      END;
      IF Active THEN
        (* retten der temp. Real-Regs, da dies
         * nicht vom Excepts-Modul erledigt wird: *)
        SaveTempRealRegs;
        WriteString (StrConv.RealToStr (lr,0,6));
        RestoreTempRealRegs;
      END;
    END dispReal;

  PROCEDURE dispBool ();
    VAR b: BOOLEAN;
    BEGIN
      loadValue (b);
      IF Active THEN
        IF b THEN
          WriteString ('TRUE ')
        ELSE
          WriteString ('FALSE')
        END
      END;
    END dispBool;

  PROCEDURE dispString ();
    (* F�r Strings werden Adresse und HIGH-Wert auf dem A3-Stack abgelegt *)
    VAR high: CARDINAL; ptr: POINTER TO CHAR;
    BEGIN
      loadValue (high);
      loadValue (ptr);
      IF Active THEN
        Write ('"');
        LOOP
          IF ptr^ = 0C THEN EXIT END;
          Write (ptr^);
          INC (ptr);
          IF high = 0 THEN EXIT END;
          DEC (high)
        END;
        Write ('"')
      END;
    END dispString;

  VAR no:CARDINAL; gemError, old: BOOLEAN;

  BEGIN
    gemError:= (*GEMShare.*)error; (*GEMShare.*)error:= FALSE;
    no:= CARDINAL (info.regPC^);
    INC (info.regPC,2);
    CASE no OF
      0 : dispLine (m2Line, info)|
      64: dispLine (asmLine, info)|
      66: dispLine (procEntry, info)|
      67: dispLine (procExit, info)|
    ELSE
      CASE no OF
            1,4: dispNum (4, TRUE)|
              2: dispReal (TRUE)|
             40: dispReal (FALSE)|
              3: dispChar ()|
        35,34,9: dispNum (2, FALSE)|
  8,20,23,25,26: old:= Hex; Hex:= TRUE; dispNum (4, FALSE); Hex:= old|
          21,41: old:= Hex; Hex:= TRUE; dispNum (2, FALSE); Hex:= old|
          30,22: dispNum (4, FALSE)|
             24: dispBool ()|
             27: dispString ()|
             33: dispNum (2, TRUE)|
          38,39: old:= Hex; Hex:= TRUE; dispNum (1, FALSE); Hex:= old|
      ELSE
          (* Tja - da haben wir einen Code nicht ausgewertet! *)
          WriteLn;
          WriteLn;
          WriteString ('*** Fehler in Debug-Modul - unbekannter Code:');
          WriteLn;
          WriteString (StrConv.CardToStr (no,0));
          HALT
      END;
      IF Active THEN
        WriteString ('   ')
      END
    END;
    (*GEMShare.*)error:= gemError;
    RETURN FALSE
  END HdlExc;


VAR stk: ARRAY [1..2000] OF CARDINAL;
    wsp: MemArea;
    hdl: ADDRESS;
    tHdl: TermCarrier;
    ok: BOOLEAN;

PROCEDURE Terminate;
  VAR ch:CHAR;
  BEGIN
    TextWindows.Show (io);
    WriteLn;
    WriteString ('Programmende: Bitte Taste...');
    Read (io,ch)
  END Terminate;

BEGIN
  Active:= TRUE;
  Step:= 0L;
  Continuous:= FALSE;
  Hex := FALSE;
  LineAddr:= FALSE;
  
  (* damit erste Zeile sofort erscheint: *)
  WaitKey:= FALSE;
  WaitNext:= TRUE;
  
  TextWindows.Open (io, 70,100, WQualitySet{movable,closable,dynamic,titled},
                    hideWdw, forceLine, ' Debugger ', -1,-1,-1,-1, ok);
  
  wsp.bottom:= ADR (stk);
  wsp.length:= SIZE (stk);
  InstallPreExc (ExcSet{TRAP5}, HdlExc, TRUE, wsp, hdl);
  IF hdl=NIL THEN HALT END;
  CatchProcessTerm (tHdl,Terminate,wsp);
END Debug.
