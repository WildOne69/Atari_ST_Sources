/************************************************************************/
/*      MAGX.H      #defines for MagiC Extensions                       */
/*              started 01/11/91 Andreas Kromke                         */
/*                                                                      */
/*     f�r TURBO C                                                      */
/*     Couple of additions R.Evans 1994	    												    */
/*     You will have to change a few things before you can use this     */
/*		 header file with Lattice C.																			*/
/************************************************************************/

/* ProgramHeader, Programmkopf f�r ausf�hrbare Dateien                  */
/************************************************************************/

typedef struct {
   int  ph_branch;        /* 0x00: mu� 0x601a sein!! */
   long ph_tlen;          /* 0x02: L�nge  des TEXT - Segments */
   long ph_dlen;          /* 0x06: L�nge  des DATA - Segments */
   long ph_blen;          /* 0x0a: L�nge  des BSS  - Segments */
   long ph_slen;          /* 0x0e: L�nge  der Symboltabelle   */
   long ph_res1;          /* 0x12: */
   long ph_res2;          /* 0x16: */
   int  ph_flag;          /* 0x1a: */
} PH;

/* new GEMDOS- Calls */

#define Sconfig(a,b)    gemdos(0x33, (int) (a), (long) (b)) /* KAOS 1.2 */
/* extern long Sconfig(int mode, long value); */
#define Fshrink(a)      Fwrite(a, 0L, (void *) -1L)         /* KAOS 1.2 */
#define Mgrow(a,b)      Mshrink(a,b)                        /* KAOS 1.2 */
#define Mblavail(a)     Mshrink(a,-1L)                      /* KAOS 1.2 */

/* Sconfig - Modes */

#define SC_GET   0                                          /* KAOS 1.2 */
#define SC_SET   1                                          /* KAOS 1.2 */
#define SC_VARS  2                                          /* KAOS 1.4 */

/* Sconfig Bits */

#define SCB_PTHCK   0x001                                   /* KAOS 1.2 */
#define SCB_DSKCH   0x002                                   /* KAOS 1.2 */
#define SCB_BREAK   0x004                                   /* KAOS 1.2 */
#define SCB_NCTLC   0x008                                   /* KAOS 1.2 */
#define SCB_NFAST   0x010                                   /* KAOS 1.2 */
#define SCB_CMPTB   0x020                                   /* KAOS 1.4 */
#define SCB_NSMRT   0x040                                   /* KAOS 1.4 */
#define SCB_NGRSH   0x080                                   /* KAOS 1.4 */
#define SCB_NHALT   0x100                                   /* KAOS 1.4 */
#define SCB_RESVD   0x200                                   /* KAOS 1.4 */
#define SCB_PULLM   0x400                                   /* KAOS 1.4 */

/* Sconfig(2) -> */


typedef struct
   {
   char      *in_dos;                 /* Adresse der DOS- Semaphore */
   int       *dos_time;               /* Adresse der DOS- Zeit      */
   int       *dos_date;               /* Adresse des DOS- Datums    */
   long      res1;                    /*                            */
   long      res2;                    /*                            */
   long      res3;                    /* ist 0L                     */
   void      *act_pd;                 /* Laufendes Programm         */
   long      res4;                    /*                            */
   int       res5;                    /*                            */
   void      res6;                    /*                            */
   void      res7;                    /* interne DOS- Speicherliste */
   void      (*resv_intmem)();        /* DOS- Speicher erweitern    */
   long      (*etv_critic)();         /* etv_critic des GEMDOS      */
   char *    ((*err_to_str)(char e)); /* Umrechnung Code->Klartext  */
   long      res8;                    /*                            */
   long      res9;                    /*                            */
   long      res10;                   /*                            */
   } DOSVARS;

/* Memory Control Block */

typedef struct
     {
     long mcb_magic;                    /* 'ANDR' oder 'KROM' (letzter)    */
     long mcb_len;                      /* Nettol�nge                      */
     long mcb_owner;                    /* PD *                            */
     long mcb_prev;                     /* vorh. Block oder NULL           */
     char mcb_data[0];
     } MCB;

/* GEMDOS- Device- Handles */

#define HDL_CON -1                                          /* TOS */
#define HDL_AUX -2                                          /* TOS */
#define HDL_PRN -3                                          /* TOS */
#define HDL_NUL -4                                          /* KAOS 1.2 */

/* GEMDOS- Standard- Handles */

#define STDIN   0                                           /* TOS */
#define STDOUT  1                                           /* TOS */
#define STDAUX  2                                           /* TOS */
#define STDPRN  3                                           /* TOS */
#define STDERR  4                                           /* TOS */
#define STDXTRA 5                                           /* TOS */

/* GEMDOS Error Codes */

#define EBREAK -68L /* user break (^C)                         KAOS 1.2 */
#define EXCPT  -69L /* 68000- exception ("bombs")              KAOS 1.2 */
#define EPTHOV -70L /* path overflow                           MagiC    */

/* GEMDOS Pexec Modes */

#define EXE_LDEX    0                                       /* TOS */
#define EXE_LD      3                                       /* TOS */
#define EXE_EX      4                                       /* TOS */
#define EXE_BASE    5                                       /* TOS */
#define EXE_EXFR    6                                       /* TOS 1.4 */

/* GEMDOS Fseek Modes */

#define SEEK_SET    0                                       /* TOS */
#define SEEK_CUR    1                                       /* TOS */
#define SEEK_END    2                                       /* TOS */

/* os_magic -> */

typedef struct
     {
     long magic;                   /* mu� $87654321 sein         */
     void *membot;                 /* Ende der AES- Variablen    */
     void *aes_start;              /* Startadresse               */
     long magic2;                  /* ist 'MAGX'                 */
     long date;                    /* Erstelldatum               */
     void (*chgres)(int res, int txt);  /* Aufl�sung �ndern      */
     long (**shel_vector)(void);   /* residentes Desktop         */
     char *aes_bootdrv;            /* von hieraus wurde gebootet */
     int  *vdi_device;             /* vom AES benutzter Treiber  */
     /* MagiC 2.0 extensions */
     void	*reserved1;
     void *reserved2;
     void *reserved3;
     int	version;
     int	release;
     } AESVARS;

/* Cookie MagX --> */

typedef struct
     {
     long    config_status;
     DOSVARS *dosvars;
     AESVARS *aesvars;
     } MAGX_COOKIE;

/* tail for default shell */

typedef struct
     {
     int  dummy;                   /* ein Nullwort               */
     long magic;                   /* 'SHEL', wenn ist Shell     */
     int  isfirst;                 /* erster Aufruf der Shell    */
     long lasterr;                 /* letzter Fehler             */
     int  wasgr;                   /* Programm war Grafikapp.    */
     } SHELTAIL;

/* shel_write modes */

#define SHW_IMMED        0                                  /* PC-GEM 2.x  */
#define SHW_CHAIN        1                                  /* TOS         */
#define SHW_DOS          2                                  /* PC-GEM 2.x  */
#define SHW_PARALLEL     100                                /* MagiC       */
#define SHW_SINGLE       101                                /* MagiC       */

/* menu_bar modes */

#define MENU_HIDE        0                                  /* TOS         */
#define MENU_SHOW        1                                  /* TOS         */
#define MENU_INSTL       100                                /* MagiC       */

/* objc_edit definition */

#define ED_CRSR          100                                /* MagiC       */
#define ED_DRAW          103                                /* MagiC 2.00  */

/* Event definition */

#define WM_UNTOPPED      30                                 /* GEM  2.x    */
#define SH_WDRAW         72                                 /* MultiTOS    */
#define WM_M_BDROPPED    100                                /* KAOS 1.4    */
#define SM_M_RES1        101                                /* MagiC       */
#define SM_M_RES2        102                                /* MagiC       */
#define SM_M_RES3        103                                /* MagiC       */
#define SM_M_RES4        104                                /* MagiC       */
#define SM_M_RES5        105                                /* MagiC       */
#define SM_M_RES6        106                                /* MagiC       */
#define SM_M_RES7        107                                /* MagiC       */
#define SM_M_RES8        108                                /* MagiC       */
#define SM_M_RES9        109                                /* MagiC       */

/* AES wind_get()- Modes */

#define WF_M_OWNER       101                                /* KAOS 1.4    */
#define WF_M_WINDLIST    102                                /* KAOS 1.4    */

/* AES wind_set()- Mode */

#define WF_M_BACKDROP    100                                /* KAOS 1.4    */

/* Window definition */

#define HOTCLOSEBOX      0x1000                             /* GEM 2.x     */
#define BACKDROP         0x2000                             /* KAOS 1.4    */

/* MagiC Object types  */

#define G_SWBUTTON       34                                 /* MagiC       */
#define G_POPUP          35                                 /* MagiC       */

typedef struct {
     char *string;                 /* etwa "TOS|KAOS|MagiC"                */
     int  num;                     /* Nr. der aktuellen Zeichenkette       */
     int  maxnum;                  /* maximal erlaubtes <num>              */
     } SWINFO;

typedef struct {
     OBJECT *tree;                 /* Popup- Men�                          */
     int  obnum;                   /* aktuelles Objekt von <tree>          */
     } POPINFO;

/* Object states */

#define WHITEBAK         0x40                               /* TOS         */
#define DRAW3D           0x80                               /* GEM 2.x     */

/* form_xdo definitions */

typedef struct {
     char scancode;
     char nclicks;
     int  objnr;
     } SCANX;

typedef struct {
     SCANX *unsh;
     SCANX *shift;
     SCANX *ctrl;
     SCANX *alt;
     void  *resvd;
     } XDO_INF;

/* AES function prototypes */

void _appl_yield    ( void );                               /* TOS         */
int  vq_aes         ( void );                               /* TOS         */
void appl_yield     ( void );                               /* GEM 2.x     */
void appl_bvset     ( int  disks,  int harddisks );         /* GEM 2.x     */
void shel_rdef      ( char *cmd, char *dir );               /* GEM 2.x     */
void shel_wdef      ( char *cmd, char *dir );               /* GEM 2.x     */
int  menu_unregister( int menu_id );                        /* GEM 2.x     */
int  scrp_clear     ( void );                               /* GEM 2.x     */
int  xgrf_stepcalc  (                                       /* GEM 2.x     */
                      int orgw, int orgh,
                      int xc, int yc, int w, int h,
                      int *cx, int *cy,
                      int *stepcnt, int *xstep, int *ystep
                    );
int  xgrf_2box      (                                       /* GEM 2.x     */
                      int xc, int yc, int w, int h,
                      int corners, int stepcnt,
                      int xstep, int ystep, int doubled
                    );
int  menu_click     ( int val, int setit );                 /* GEM 3.x     */
int  form_popup     ( OBJECT *tree, int x, int y );         /* MagiC       */
int  form_xerr      ( long errcode, char *errfile );        /* MagiC       */
int  form_xdo       (                                       /* MagiC       */
                      OBJECT *tree, int startob,
                      int *lastcrsr, XDO_INF *tabs,
                      void *flydial
                    );
int  form_xdial     (                                       /* MagiC       */
                      int flag,
                      int ltx, int lty, int ltw, int lth,
                      int bgx, int bgy, int bgw, int bgh,
                      void **flydial
                    );

