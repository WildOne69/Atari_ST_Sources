DEFINITION MODULE FastDics;

FROM DicBase     IMPORT  CPtr, SPtr;

TYPE FastDic = RECORD
             STab     : CPtr;
             akt_STab : CPtr;
             max_STab : CPtr;
             PTab     : POINTER TO ARRAY [0..MaxCard] OF SPtr;
             akt_PTab : CARDINAL;
             max_PTab : CARDINAL;
           END;

PROCEDURE CreateFastDic (VAR fd: FastDic; every: CARDINAL;
                         words: LONGCARD): BOOLEAN;

(*  Legt eine FastDic an. Mit every und words wird der der
 *  Speicherverbrauch berechnet.
 *)

PROCEDURE CloseFastDic (VAR fd: FastDic);

(*  Der noch �briggebliebene Speicher wird zur�ckgegeben.
 *  Der Aufruf ist optional und mu� nach dem letzten Insert erfolgen.
 *)

PROCEDURE ReleaseFastDic (VAR fd: FastDic);

PROCEDURE Insert (VAR fd: FastDic; VAR zStr: ARRAY OF CHAR; pos: LONGCARD);
  
(*  F�gt [zstr,pos] in den Suchbaum ein. *)

PROCEDURE GetPos (fd: FastDic; VAR zStr: ARRAY OF CHAR; VAR pos: LONGCARD);
  
  (*  Sucht nach zStr (bzw. nach n�chstkleinerem Element) und liefert
   *  das gefundene Element und dessen Nachfolgerposition zur�ck.
   *)
END FastDics.
