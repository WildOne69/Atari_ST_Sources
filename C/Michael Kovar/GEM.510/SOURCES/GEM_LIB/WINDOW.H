/* ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: */
/* ::::::::::::::::::::      w i n d o w     :::::::::::::::::::: */
/* ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: */
/* 
 * Headerdatei f�r den Windowmanager aus der ST-Computer 05/89 - 10/89
 * 
 * Autor f�r die ST Computer   :   Andreas L�tscher
 * �bertragen auf Mark Williams C: Michael Kovar
 * �berarbeitet und erweitert  :   Volker Nawrath
 *
 * Version 3.20 vom 29.11.1992
 */


#include "gemsys.h"


/* Makro zur Pr�fung, ob mindestens ein Fenster offen
 * -------------------------------------------------- */
#define ANZWIND() ((aktuell.anzahl >0)?1:0)


/* Parameter und aktuelle Werte eines Fensters
 * ------------------------------------------- */
typedef struct wind_data
{
     int  handle;        /* Fenster-ID                           */
     int  fenster;       /* = TRUE, wenn Fenster, ansonsten FALSE*/
     int  offen;         /* = TRUE / FALSE = Fenster offen / zu  */
     int  delclose;      /* = TRUE => Fenster l�schen,wenn close */
     char name[80];      /* Text f�r Fenstername                 */
     char info[80];      /* Text f�r Infozeile                   */
     int  wmin;          /* min. Breite des Fensters in Pixel    */
     int  hmin;          /* min. H�he des Fensters in Pixel      */
     RECT max;           /* max. Gr��e des Fensters in Pixel     */
     RECT work;          /* Arbeitsbereich des Fensters:
                          * x/y-Koordinate in Pixel;
                          * w/h = Spalte / Zeile                 */
     RECT allpix;        /* Rahmenbereich des Fensters (also
                          * incl. Fensterelemente) in Pixel      */
     RECT workpix;       /* Arbeitsbereich des Fensters in Pixel */
     int  elements;      /* Elemente des Fensters                */
     int  align;         /* Align-Wert                           */
     int  snap;          /* Snap-Wert                            */
     int  full;          /* TRUE / FALSE  Fenster volle Gr��e?   */
     int  scroll_x;      /* Scroll-Wert in Pixel f�r Horizontale */
     int  scroll_y;      /* Scroll-Wert in Pixel f�r Vertikale   */
     long doc_x;         /* Dokumentenposition Spalte            */
     long doc_y;         /* Dokumentenposition Zeile             */
     long doc_length;    /* Dokumentenl�nge in Zeilen            */
     long doc_width;     /* Dokumentenl�nge in Spalten           */
     void (*w_redraw)(); /* Zeiger auf Redraw-Funktion           */
     IMAGE     wsave;    /* Struktur f�r Window-Speicher         */
     int  fl_wsave;      /* = TRUE  ==> automatischer Redraw
                          * = FALSE ==> Programmredraw           */
     void (*userfkt)();  /* Zeiger auf Funktion, die vom Window-
                          * Manager nach Fensterereignis aufge-
                          * rufen wird                           */
     int  fl_userfkt;    /* Flag, ob userfkt() aufgerufen werden
                            soll                                 */
     RSCDATA rsc;		/* F�r Behandlung von Dialogboxen in Fenstern */
} WIND_DATA;


/* Konstantendefinitionen
 * ---------------------- */

#define MAXWIND     7    /* max. Anzahl der Fenster          */

#define W_UPPAGE    0    /* Arten der Fensterereignisse           */
#define W_DNPAGE    1
#define W_UPLINE    2
#define W_DNLINE    3
#define W_LFPAGE    4
#define W_RTPAGE    5
#define W_LFLINE    6
#define W_RTLINE    7

#define WM_OPEN     50   /* Konstanten f�r die programmgesteuerte     */
#define WM_CLOSE    51   /* Fenstermanipulation                       */
#define WM_DEL      52
#define WM_POS      53
#define WM_SIZE     54
#define WM_FULL     55
#define WM_TOP      56
#define WM_SDOWN    57
#define WM_SUP      58
#define WM_SLEFT    59
#define WM_SRIGHT   60
#define WM_LDOWN    61
#define WM_LUP      62
#define WM_LLEFT    63
#define WM_LRIGHT   64
#define WM_TEXT     65
#define WM_MAX_V    66
#define WM_MAX_H    67
#define WM_FREDRAW  68
#define WM_CLEAR    69
#define MSG_DIALOG 100

/* Strukturinformationen f�r Dialogboxen in Fenstern */

typedef struct
{
	void (*keybd)();	/* Funktionszeiger f�r Keyboard-handling */
	void (*button)();	/* Funktionszeiger f�r Mausclick-handling */
	void (*mesag)();	/* Funktionszeiger f�r Message-handling */
	void (*menu)();		/* Funktionszeiger f�r Men�-Behandlung */
	void (*m1)();		/* Funktionszeiger f�r Maus1-event */
	void (*m2)();		/* Funktionszeiger f�r Maus2-event */
	void (*timer)();	/* Funktionszeiger f�r Timer-Event */
	int ok;			/* Flag f�r g�ltige Werte */
	int name[12];		/* Fenster-Name f�r Dialogboxen */
} DIALTYPE;

/* ENDE window.h */
