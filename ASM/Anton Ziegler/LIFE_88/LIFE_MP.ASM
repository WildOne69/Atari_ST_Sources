* =========================================
*
* PROGRAMM ZUR BERECHNUNG UND ANZEIGE DES
* N�CHSTEN ZUSTANDES DES SPIELES LIFE IN
* EINEM 50*50 SPIELFELD.
* INCL. UNTERPROGRAMME ZUR VERSCHIEBUNG
* DES GESAMTEN SPIELFELDES NACH LINKS,
* RECHTS, OBEN UND UNTEN.
*
* F�R S/W- UND FARBMONITOR (MITTL. AUFL.)
*
* ========================================

* ========================================
*
* BELEGUNG DER CPU-REGISTER IN DER ROUTINE
*
* d0: tempor�r
* d1: tempor�r
* d2: tempor�r
* d3: Wert f�r die Verz�gerungsschleife (Langwort)
* d4: Wert f�r die Spielfeldtopologie bzw. Verschiebeoperation (Wort):
*     0=Torus, 1=offen;
*     256=nach oben, 257=nach unten, 258=nach links, 259=nach rechts
* d5: Wert f�r die Bildschirmaufl�sung (Wort): 1=640*200, 2=640*400
* d6:
* d7:

* a0: tempor�r
* a1: tempor�r
* a2: tempor�r
* a3: Startadresse des Quellfeldes
* a4: Startadresse des Zielfeldes
* a5: Startadresse des Auswertefeldes
* a6: Bildschirm-Basisadresse
* a7: Stackpointer
*
* ========================================

* ========================================
*
* �bergabeparameter:
*
* start-28(pc): Startadresse des Quellfeldes (Langwort)
* start-24(pc): Startadresse des Zielfeldes (Langwort)
* start-20(pc): Startadresse des Auswertefeldes (Langwort)
* start-16(pc): Wert f�r Verz�gerungsschleife (Langwort)
* start-12(pc): Anzahl der zu berechnenden Generationen (Langwort)
* start-8(pc) : Flag f�r Spielfeldtopologie: 0=Torus, 1=offen (Wort)
*
* R�ckgabeparameter:
*
* start-12(pc): Anzahl der noch nicht berechneten Generationen
*               (bei Abbruch, sonst 0)
*
* ========================================
*
* --------------------
* PARAMETER �BERNEHMEN

start:      movea.l start-28(pc),a3       ;Startadresse des Quellfeldes
            movea.l start-24(pc),a4       ;Startadresse des Zielfeldes
            movea.l start-20(pc),a5       ;Startadresse des Auswertefeldes
            move.l  start-16(pc),d3       ;Wert f�r Verz�gerungsschleife
            move.w  start-8(pc),d4        ;Flag f�r Spielfeldtopologie

* -------------------------
* BILDSCHIRMAUFL�SUNG HOLEN

            move.w  #4,-(sp)              ;Funktionsnummer f. GETREZ
            trap    #14                   ;XBIOS-Aufruf
            addq.l  #2,sp                 ;Stackpointer korrigieren
            move.w  d0,d5                 ;Ergebnis nach d5 bringen

* ----------------------------------
* BASISADRESSE DES BILDSCHIRMS HOLEN

            move.w  #3,-(sp)              ;Funktionsnummer f�r LOGBASE
            trap    #14                   ;XBIOS aufrufen
            addq.l  #2,sp                 ;Stackpointer korrigieren

            movea.l d0,a6                 ;Ergebnis nach a6 bringen

* ------------------------------------------------------------
* ZU DEN ELEMENTNUMMERN GEH�RENDE BILDSCHIRMADRESSEN BERECHNEN

            lea     zuord(pc),a0          ;Adresse der Zuordnungstabelle

            cmpi.w  #2,d5                 ;hohe Aufl�sung ?
            bne     midres                ;nein, f�r mittlere Aufl. ber.

            move.w  #49,d1                ;Zeilenz�hler
nzeile:     move.w  #49,d2                ;Spaltenz�hler

nspalte:    move.l  d0,(a0)+              ;zugeordnete Adresse ablegen
            addq.l  #1,d0                 ;n�chste Adresse
            dbf     d2,nspalte            ;n�chste Spalte i. d. BS-Zeile

            addi.l  #590,d0               ;Beginnadr. n�chste BS-Zeile

            dbf     d1,nzeile             ;n�chste Zeile
            bra     setg_00000            ;und fertig

midres:     move.w  #49,d1                ;Z�hler 1
cm1:        move.w  #11,d2                ;Z�hler 2

cm2:        move.l  d0,(a0)+              ;BS-Adresse ablegen
            addq.l  #1,d0                 ;n�chste Adresse
            move.l  d0,(a0)+              ;ablegen
            addq.l  #3,d0                 ;n�chste Adresse (Bitplane 0)
            move.l  d0,(a0)+              ;ablegen
            addq.l  #1,d0                 ;n�chste Adresse
            move.l  d0,(a0)+              ;ablegen
            addq.l  #3,d0                 ;n�chste Adresse
            dbf     d2,cm2                ;d1=d1-1, if d1>-1 goto cm2

            move.l  d0,(a0)+              ;noch 2 Adressen ...
            addq.l  #1,d0                 ;
            move.l  d0,(a0)+              ;
            addi.l  #543,d0               ;Beginnadresse n�chste BS-Zeile
            dbf     d1,cm1                ;d1=d1-1, if d1>-1 goto cm1

* -------------------------------------------
* GENERATIONENZ�HLERSTRING AUF "00000" SETZEN

setg_00000: lea     counter(pc),a0        ;Startadresse der Zeichenkette
            move.b  #$30,(a0)+            ;5*Ziffer 0 schreiben
            move.b  #$30,(a0)+            ;
            move.b  #$30,(a0)+            ;
            move.b  #$30,(a0)+            ;
            move.b  #$30,(a0)             ;

* -------------------------------------------
* ABFRAGE AUF VERSCHIEBEOPERATION (SCROLLING)

nextgen:    cmpi.w  #256,d4               ;Topologie-Wort abfragen
            bcs     lifecalc              ;normale LIFE-Berechnung

            bne     askdown               ;
            bsr     scrollup              ;Feld nach oben scrollen
            bsr     showpic               ;anzeigen
            bra     cdown                 ;

askdown:    cmpi.w  #257,d4               ;
            bne     askleft               ;
            bsr     scrolldown            ;Feld nach unten scrollen
            bsr     showpic               ;anzeigen
            bra     cdown                 ;

askleft:    cmpi.w  #258,d4               ;
            bne     thenright             ;
            bsr     scrolleft             ;Feld nach links scrollen
            bsr     showpic               ;anzeigen
            bra     cdown                 ;

thenright:  bsr     scrollright           ;Feld nach rechts scrollen
            bsr     showpic               ;anzeigen
            bra     cdown                 ;

* --------------
* ZENTRALBEREICH

lifecalc:   clr.l   d1                    ;
            lea     51(a3),a0             ;Quelladresse nach a0
            lea     51(a4),a1             ;Zieladresse nach a1
            move.l  #2397,d0              ;d0 als Z�hler laden

center:     move.b  (a0)+,d1              ;Zelle selbst
            beq     neighbrsc             ;Zelle tot
            addq.b  #8,d1                 ;sonst 8 hinzuaddieren

neighbrsc:  add.b   -52(a0),d1            ;links oben
            add.b   -51(a0),d1            ;oben
            add.b   -50(a0),d1            ;rechts oben
            add.b   -2(a0),d1             ;links
            add.b   (a0),d1               ;rechts
            add.b   48(a0),d1             ;links unten
            add.b   49(a0),d1             ;unten
            add.b   50(a0),d1             ;rechts unten

            move.b  0(a5,d1.l),(a1)+      ;n�chster Zellzustand

            dbf     d0,center             ;d0=d0-1, if d0>-1 goto center

* ---------------------------------------------------------------
* FLAG F�R SPIELFELDTOPOLOGIE ABFRAGEN (=> RANDZEILENBEARBEITUNG)

            tst.w   d4                    ;0, dann Torus
            bne     flat                  ;sonst offenes Spielfeld

* ----------------------------------
* OBERE UND UNTERE RANDZEILE (TORUS)

            moveq   #47,d0                ;d0 als Z�hler laden

aboben:     lea     1(a3,d0.l),a0         ;Zelladresse nach a0
            move.b  (a0),d1               ;Zelle selbst
            beq     neighbrsa             ;Zelle tot
            addq.b  #8,d1                 ;sonst 8 hinzuaddieren

neighbrsa:  add.b   2449(a0),d1           ;links oben  *
            add.b   2450(a0),d1           ;oben        *
            add.b   2451(a0),d1           ;rechts oben *
            add.b   -1(a0),d1             ;links
            add.b   1(a0),d1              ;rechts
            add.b   49(a0),d1             ;links unten
            add.b   50(a0),d1             ;unten
            add.b   51(a0),d1             ;rechts unten

            move.b  0(a5,d1.l),1(a4,d0.l) ;n�chster Zellzustand

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

            lea     0(a3,d0.l),a0         ;Zelladresse
            adda.l  #2451,a0              ;nach a0
            move.b  (a0),d1               ;Zelle selbst
            beq     neighbrsb             ;Zelle tot
            addq.b  #8,d1                 ;sonst 8 hinzuaddieren

neighbrsb:  add.b   -51(a0),d1            ;links oben
            add.b   -50(a0),d1            ;oben
            add.b   -49(a0),d1            ;rechts oben
            add.b   -1(a0),d1             ;links
            add.b   1(a0),d1              ;rechts
            add.b   -2451(a0),d1          ;links unten  *
            add.b   -2450(a0),d1          ;unten        *
            add.b   -2449(a0),d1          ;rechts unten *

            lea     0(a4,d0.l),a0         ;Basisadresse im Zielfeld
            move.b  0(a5,d1.l),2451(a0)   ;n�chster Zellzustand

            dbf     d0,aboben             ;d0=d0-1, if d0>-1 goto aboben

* ----------------------------------
* LINKE UND RECHTE RANDZEILE (TORUS)

            clr.l   d2                    ;d2 als Hilfsz�hler (wird pro
                                          ;Durchlauf um 50 erh�ht)
            moveq   #47,d0                ;d0 als Z�hler laden

lefrig:     lea     50(a3,d2.l),a0        ;Zelladresse nach a0
            move.b  (a0),d1               ;Zelle selbst
            beq     neighbrsl             ;Zelle tot
            addq.b  #8,d1                 ;sonst 8 hinzuaddieren

neighbrsl:  add.b   -1(a0),d1             ;links oben  *
            add.b   -50(a0),d1            ;oben
            add.b   -49(a0),d1            ;rechts oben
            add.b   49(a0),d1             ;links       *
            add.b   1(a0),d1              ;rechts
            add.b   99(a0),d1             ;links unten *
            add.b   50(a0),d1             ;unten
            add.b   51(a0),d1             ;rechts unten

            move.b  0(a5,d1.l),50(a4,d2.l) ;n�chster Zellzustand

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

            lea     99(a3,d2.l),a0        ;Zelladresse nach a0
            move.b  (a0),d1               ;Zelle selbst
            beq     neighbrsr             ;Zelle tot
            addq.b  #8,d1                 ;sonst 8 hinzuaddieren

neighbrsr:  add.b   -51(a0),d1            ;links oben
            add.b   -50(a0),d1            ;oben
            add.b   -99(a0),d1            ;rechts oben  *
            add.b   -1(a0),d1             ;links
            add.b   -49(a0),d1            ;rechts       *
            add.b   49(a0),d1             ;links unten
            add.b   50(a0),d1             ;unten
            add.b   1(a0),d1              ;rechts unten *

            move.b  0(a5,d1.l),99(a4,d2.l) ;n�chster Zellzustand

            addi.w  #50,d2                ;Hilfsz�hler um 50 erh�hen
            dbf     d0,lefrig             ;d0=d0-1, if d0>-1 goto lefrig

* ---------------------------
* ECKPUNKT OBEN LINKS (TORUS)

            move.b  (a3),d1               ;Zelle selbst
            beq     neighbrsal            ;Zelle tot
            addq.b  #8,d1                 ;sonst 8 hinzuaddieren

neighbrsal: add.b   2499(a3),d1           ;links oben  *
            add.b   2450(a3),d1           ;oben        *
            add.b   2451(a3),d1           ;rechts oben *
            add.b   49(a3),d1             ;links       *
            add.b   1(a3),d1              ;rechts
            add.b   99(a3),d1             ;links unten *
            add.b   50(a3),d1             ;unten
            add.b   51(a3),d1             ;rechts unten

            move.b  0(a5,d1.l),(a4)       ;n�chster Zellzustand

* ----------------------------
* ECKPUNKT OBEN RECHTS (TORUS)

            move.b  49(a3),d1             ;Zelle selbst
            beq     neighbrsar            ;Zelle tot
            addq.b  #8,d1                 ;sonst 8 hinzuaddieren

neighbrsar: add.b   2498(a3),d1           ;links oben   *
            add.b   2499(a3),d1           ;oben         *
            add.b   2450(a3),d1           ;rechts oben  *
            add.b   48(a3),d1             ;links
            add.b   (a3),d1               ;rechts       *
            add.b   98(a3),d1             ;links unten
            add.b   99(a3),d1             ;unten
            add.b   50(a3),d1             ;rechts unten *

            move.b  0(a5,d1.l),49(a4)     ;n�chster Zellzustand

* ----------------------------
* ECKPUNKT UNTEN LINKS (TORUS)

            move.b  2450(a3),d1           ;Zelle selbst
            beq     neighbrsbl            ;Zelle tot
            addq.b  #8,d1                 ;sonst 8 hinzuaddieren

neighbrsbl: add.b   2449(a3),d1           ;links oben   *
            add.b   2400(a3),d1           ;oben
            add.b   2401(a3),d1           ;rechts oben
            add.b   2499(a3),d1           ;links        *
            add.b   2451(a3),d1           ;rechts
            add.b   49(a3),d1             ;links unten  *
            add.b   (a3),d1               ;unten        *
            add.b   1(a3),d1              ;rechts unten *

            move.b  0(a5,d1.l),2450(a4)   ;n�chster Zellzustand

* -----------------------------
* ECKPUNKT UNTEN RECHTS (TORUS)

            move.b  2499(a3),d1           ;Zelle selbst
            beq     neighbrsbr            ;Zelle tot
            addq.b  #8,d1                 ;sonst 8 hinzuaddieren

neighbrsbr: add.b   2448(a3),d1           ;links oben
            add.b   2449(a3),d1           ;oben
            add.b   2400(a3),d1           ;rechts oben  *
            add.b   2498(a3),d1           ;links
            add.b   2450(a3),d1           ;rechts       *
            add.b   48(a3),d1             ;links unten  *
            add.b   49(a3),d1             ;unten        *
            add.b   (a3),d1               ;rechts unten *

            move.b  0(a5,d1.l),2499(a4)   ;n�chster Zellzustand

            bra     nexpic                ;n�chstes Bild anzeigen

* ----------------------------------
* OBERE UND UNTERE RANDZEILE (OFFEN)

flat:       moveq   #47,d0                ;d0 als Z�hler laden

faboben:    lea     1(a3,d0.l),a0         ;Zelladresse nach a0
            move.b  (a0),d1               ;Zelle selbst
            beq     fneighbrsa            ;Zelle tot
            addq.b  #8,d1                 ;sonst 8 hinzuaddieren

fneighbrsa: add.b   -1(a0),d1             ;links
            add.b   1(a0),d1              ;rechts
            add.b   49(a0),d1             ;links unten
            add.b   50(a0),d1             ;unten
            add.b   51(a0),d1             ;rechts unten

            move.b  0(a5,d1.l),1(a4,d0.l) ;n�chster Zellzustand

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

            lea     0(a3,d0.l),a0         ;Zelladresse
            adda.l  #2451,a0              ;nach a0
            move.b  (a0),d1               ;Zelle selbst
            beq     fneighbrsb            ;Zelle tot
            addq.b  #8,d1                 ;sonst 8 hinzuaddieren

fneighbrsb: add.b   -51(a0),d1            ;links oben
            add.b   -50(a0),d1            ;oben
            add.b   -49(a0),d1            ;rechts oben
            add.b   -1(a0),d1             ;links
            add.b   1(a0),d1              ;rechts

            lea     0(a4,d0.l),a0         ;Basisadresse im Zielfeld
            move.b  0(a5,d1.l),2451(a0)   ;n�chster Zellzustand

            dbf     d0,faboben            ;d0=d0-1, if d0>-1 goto faboben

* ----------------------------------
* LINKE UND RECHTE RANDZEILE (OFFEN)

            clr.l   d2                    ;d2 als Hilfsz�hler (wird pro
                                          ;Durchlauf um 50 erh�ht)
            moveq   #47,d0                ;d0 als Z�hler laden

flefrig:    lea     50(a3,d2.l),a0        ;Zelladresse nach a0
            move.b  (a0),d1               ;Zelle selbst
            beq     fneighbrsl            ;Zelle tot
            addq.b  #8,d1                 ;sonst 8 hinzuaddieren

fneighbrsl: add.b   -50(a0),d1            ;oben
            add.b   -49(a0),d1            ;rechts oben
            add.b   1(a0),d1              ;rechts
            add.b   50(a0),d1             ;unten
            add.b   51(a0),d1             ;rechts unten

            move.b  0(a5,d1.l),50(a4,d2.l) ;n�chster Zellzustand

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

            lea     99(a3,d2.l),a0        ;Zelladresse nach a0
            move.b  (a0),d1               ;Zelle selbst
            beq     fneighbrsr            ;Zelle tot
            addq.b  #8,d1                 ;sonst 8 hinzuaddieren

fneighbrsr: add.b   -51(a0),d1            ;links oben
            add.b   -50(a0),d1            ;oben
            add.b   -1(a0),d1             ;links
            add.b   49(a0),d1             ;links unten
            add.b   50(a0),d1             ;unten

            move.b  0(a5,d1.l),99(a4,d2.l) ;n�chster Zellzustand

            addi.w  #50,d2                ;Hilfsz�hler um 50 erh�hen
            dbf     d0,flefrig            ;d0=d0-1, if d0>-1 goto flefrig

* ---------------------------
* ECKPUNKT OBEN LINKS (OFFEN)

            move.b  (a3),d1               ;Zelle selbst
            beq     fneighbsal            ;Zelle tot
            addq.b  #8,d1                 ;sonst 8 hinzuaddieren

fneighbsal: add.b   1(a3),d1              ;rechts
            add.b   50(a3),d1             ;unten
            add.b   51(a3),d1             ;rechts unten

            move.b  0(a5,d1.l),(a4)       ;n�chster Zellzustand

* ----------------------------
* ECKPUNKT OBEN RECHTS (OFFEN)

            move.b  49(a3),d1             ;Zelle selbst
            beq     fneighbsar            ;Zelle tot
            addq.b  #8,d1                 ;sonst 8 hinzuaddieren

fneighbsar: add.b   48(a3),d1             ;links
            add.b   98(a3),d1             ;links unten
            add.b   99(a3),d1             ;unten

            move.b  0(a5,d1.l),49(a4)     ;n�chster Zellzustand

* ----------------------------
* ECKPUNKT UNTEN LINKS (OFFEN)

            move.b  2450(a3),d1           ;Zelle selbst
            beq     fneighbsbl            ;Zelle tot
            addq.b  #8,d1                 ;sonst 8 hinzuaddieren

fneighbsbl: add.b   2400(a3),d1           ;oben
            add.b   2401(a3),d1           ;rechts oben
            add.b   2451(a3),d1           ;rechts

            move.b  0(a5,d1.l),2450(a4)   ;n�chster Zellzustand

* -----------------------------
* ECKPUNKT UNTEN RECHTS (OFFEN)

            move.b  2499(a3),d1           ;Zelle selbst
            beq     fneighbsbr            ;Zelle tot
            addq.b  #8,d1                 ;sonst 8 hinzuaddieren

fneighbsbr: add.b   2448(a3),d1           ;links oben
            add.b   2449(a3),d1           ;oben
            add.b   2498(a3),d1           ;links

            move.b  0(a5,d1.l),2499(a4)   ;n�chster Zellzustand

* ------------------------------------
* NEUEN ZUSTAND AM BILDSCHIRM ANZEIGEN

nexpic:     bsr     showpic               ;

* -----------------------------------------------
* GENERATIONENZ�HLERSTRING DEZIMAL INKREMENTIEREN

            lea     counter(pc),a0        ;Startadresse der Zeichenkette

            addq.b  #1,4(a0)              ;Stelle 0 inkrementieren
            cmpi.b  #$3a,4(a0)            ;�berlauf ?
            bne     print                 ;nein, dann Ausgabe

            move.b  #$30,4(a0)            ;ja, dann Stelle 0=Ziffer 0
            addq.b  #1,3(a0)              ;und Stelle 1 inkrementieren
            cmpi.b  #$3a,3(a0)            ;�berlauf ?
            bne     print                 ;nein, dann Ausgabe

            move.b  #$30,3(a0)            ;ja, dann Stelle 1=Ziffer 0
            addq.b  #1,2(a0)              ;und Stelle 2 inkrementieren
            cmpi.b  #$3a,2(a0)            ;�berlauf ?
            bne     print                 ;nein, dann Ausgabe

            move.b  #$30,2(a0)            ;ja, dann Stelle 2=Ziffer 0
            addq.b  #1,1(a0)              ;und Stelle 3 inkrementieren
            cmpi.b  #$3a,1(a0)            ;�berlauf ?
            bne     print                 ;nein, dann Ausgabe

            move.b  #$30,1(a0)            ;ja, dann Stelle 3=Ziffer 0
            addq.b  #1,(a0)               ;und Stelle 4 inkrementieren
            cmpi.b  #$3a,(a0)             ;�berlauf ?
            bne     print                 ;nein, dann Ausgabe

            move.b  #$30,(a0)             ;ja, dann Stelle 4=Ziffer 0

* ----------------------------------
* Z�HLERSTAND AM BILDSCHIRM AUSGEBEN

print:      lea     scursor(pc),a0        ;Adresse der Zeichenkette
            move.l  a0,-(sp)              ;auf den Stack
            move.w  #9,-(sp)              ;Funktionsnummer
            trap    #1                    ;GEMDOS-Aufruf PRINT LINE
            addq.l  #6,sp                 ;Stackpointer in Ordnung bringen

* -----------------------------------
* GENERATIONENZ�HLER UM 1 ERNIEDRIGEN

cdown:      lea     start-12(pc),a0       ;Adresse des Z�hlers
            subq.l  #1,(a0)               ;Inhalt um 1 erniedrigen
            beq     exit                  ;R�cksprung, falls Ende

* ----------------------------------------
* VERZ�GERUNGSSCHLEIFE MIT TASTATURABFRAGE

            move.l  d3,d1                 ;Verz�gerungswert nach d1
            addq.l  #1,d1                 ;(falls 0 angegeben wurde)

wait:       move.w  #$ff,-(sp)            ;Funktionsw. "Tastatur pr�fen"
            move.w  #6,-(sp)              ;Funktionsnummer
            trap    #1                    ;GEMDOS-Aufruf RAWCONIO
            addq.l  #4,sp                 ;Stackpointer korrigieren
            swap    d0                    ;Scan-Code in d. unt. H�lfte
            cmpi.b  #$44,d0               ;wurde F10 gedr�ckt ?
            beq     exit                  ;ja, dann R�cksprung

            subq.l  #1,d1                 ;Register um 1 erniedrigen
            tst.l   d1                    ;0 schon erreicht ?
            bne     wait                  ;nein, dann weitermachen

* --------------------------------------------
* ADRESSEN VON QUELL- UND ZIELFELD VERTAUSCHEN

            exg     a3,a4                 ;
            bra     nextgen               ;n�chste Generation berechnen

* ----------------------
* R�CKKEHR INS GFA-BASIC

exit:       rts                           ;


* ------------------------------------------------------
* UNTERPROGRAMM: N�CHSTEN ZUSTAND AM BILDSCHIRM ANZEIGEN

showpic:    lea     zuord(pc),a0          ;Adresse der BS-Adresstabelle
            clr.b   d0                    ;zum L�schen
            move.b  #%01111110,d1         ;auszugebendes Muster
            move.w  #2499,d2              ;d2 als Z�hler laden

            cmpi.w  #2,d5                 ;hohe Aufl�sung ?
            bne     askdiffc              ;nein, dann mittlere Aufl.

askdiffm:   cmpm.b  (a3)+,(a4)+           ;Zustand ver�ndert ?
            beq     conttm                ;nein, dann keine Aktion

            movea.l (a0),a1               ;BS-Adresse laden

            bcs     eracellm              ;1->0, dann l�schen

            move.b  d1,80(a1)             ;Rechteck
            move.b  d1,160(a1)            ;mit 
            move.b  d1,240(a1)            ;6*6
            move.b  d1,320(a1)            ;Punkten
            move.b  d1,400(a1)            ;setzen
            move.b  d1,480(a1)            ;

            bra     conttm                ;

eracellm:   move.b  d0,80(a1)             ;Rechteck
            move.b  d0,160(a1)            ;
            move.b  d0,240(a1)            ;
            move.b  d0,320(a1)            ;
            move.b  d0,400(a1)            ;
            move.b  d0,480(a1)            ;l�schen

conttm:     addq.l  #4,a0                 ;Zeiger: n�chste BS-Adresse
            dbf     d2,askdiffm           ;d2=d2-1, if d2>-1 goto askdiffm
            bra     rest_point            ;und fertig

askdiffc:   cmpm.b  (a3)+,(a4)+           ;Zustand ver�ndert ?
            beq     conttc                ;nein, dann keine Aktion

            movea.l (a0),a1               ;BS-Adresse laden

            bcs     eracellc              ;1->0, dann l�schen

            move.b  d1,(a1)               ;Rechteck
            move.b  d1,160(a1)            ;mit 6*3 Punkten
            move.b  d1,320(a1)            ;setzen

            bra     conttc                ;

eracellc:   move.b  d0,(a1)               ;Rechteck
            move.b  d0,160(a1)            ;mit 6*3 Punkten
            move.b  d0,320(a1)            ;l�schen

conttc:     addq.l  #4,a0                 ;Zeiger: n�chste BS-Adresse
            dbf     d2,askdiffc           ;d2=d2-1, if d2>-1 goto askdiffc

rest_point: suba.l  #2500,a3              ;Quellfeldzeiger restaurieren
            suba.l  #2500,a4              ;Zielfeldzeiger restaurieren

            rts                           ;

* --------------------------------------
* UNTERPROGRAMM: FELD NACH OBEN SCROLLEN

scrollup:   lea     50(a3),a0             ;Quelle
            lea     (a4),a1               ;Ziel
            move.l  #1224,d0              ;Z�hler

scup:       move.w  (a0)+,(a1)+           ;Zeilen 1 - 49
            dbf     d0,scup               ;verschieben

            lea     (a3),a0               ;Quelle
            lea     2450(a4),a1           ;Ziel
            moveq   #24,d0                ;Z�hler

lup:        move.w  (a0)+,(a1)+           ;Zeile 0
            dbf     d0,lup                ;verschieben

            rts                           ;

* ---------------------------------------
* UNTERPROGRAMM: FELD NACH UNTEN SCROLLEN

scrolldown: lea     (a3),a0               ;Quelle
            lea     50(a4),a1             ;Ziel
            move.l  #1224,d0              ;Z�hler

scdown:     move.w  (a0)+,(a1)+           ;Zeilen 0 - 48
            dbf     d0,scdown             ;verschieben

            lea     2450(a3),a0           ;Quelle
            lea     (a4),a1               ;Ziel
            moveq   #24,d0                ;Z�hler

ldown:      move.w  (a0)+,(a1)+           ;Zeile 49
            dbf     d0,ldown              ;verschieben

            rts                           ;

* ---------------------------------------
* UNTERPROGRAMM: FELD NACH LINKS SCROLLEN

scrolleft:  lea     1(a3),a0              ;Quelle
            lea     (a4),a1               ;Ziel
            move.l  #2498,d0              ;Z�hler

scleft:     move.b  (a0)+,(a1)+           ;Spalten 1 - 49
            dbf     d0,scleft             ;verschieben

            lea     (a3),a0               ;Quelle
            lea     49(a4),a1             ;Ziel
            moveq   #49,d0                ;Z�hler
            clr.l   d1                    ;

lleft:      move.b  0(a0,d1.l),0(a1,d1.l) ;Spalte 0
            addi.w  #50,d1                ;
            dbf     d0,lleft              ;verschieben

            rts                           ;

* ----------------------------------------
* UNTERPROGRAMM: FELD NACH RECHTS SCROLLEN

scrollright: lea    (a3),a0               ;Quelle
            lea     1(a4),a1              ;Ziel
            move.l  #2498,d0              ;Z�hler

scright:    move.b  (a0)+,(a1)+           ;Spalten 0 - 48
            dbf     d0,scright            ;verschieben

            lea     49(a3),a0             ;Quelle
            lea     (a4),a1               ;Ziel
            moveq   #49,d0                ;Z�hler
            clr.l   d1                    ;

lright:     move.b  0(a0,d1.l),0(a1,d1.l) ;Spalte 49
            addi.w  #50,d1                ;
            dbf     d0,lright             ;verschieben

            rts                           ;

* --------------------
* DATENSPEICHERBEREICH

zuord:      ds.l    2500                  ;Tabelle f�r die Zuordnung
                                          ;Elementnummer-Bildschirmadr.
scursor:    dc.b    27,"j"                ;ESC j=Cursorposition
                                          ;speichern
counter:    ds.b    5                     ;5 Bytes f�r den 5-stelligen
                                          ;Dezimalz�hler
            dc.b    27,"k",0              ;ESC k=Cursor auf die ge-
                                          ;speicherte Pos. setzen

            end
