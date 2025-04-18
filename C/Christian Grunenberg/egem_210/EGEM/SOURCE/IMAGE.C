
#define NULL	((void *) 0l)

typedef struct
{
	int		*hi_on,*hi_off,*lo_on,*lo_off;
} IMAGE;

typedef struct
{
	int		count;
	IMAGE	*image;
} IMAGES;

static int radio_hi_on[] =
{
#ifdef SMALL_EGEM
0x0000, 0x03C0, 0x0C30, 0x1008, 0x23C4, 0x27E4, 0x4FF2, 0x4FF2, 
0x4FF2, 0x4FF2, 0x27E4, 0x23C4, 0x1008, 0x0C30, 0x03C0, 0x0000
#else
0x0000, 0x03C0, 0x0C30, 0x1008, 0x23C4, 0x27E4, 0x4FF2, 0x4FF2, 
0x4FF2, 0x4FF2, 0x27E4, 0x23C4, 0x1008, 0x0C30, 0x03C0, 0x0000,
0x0000, 0x03E0, 0x0FF8, 0x1C0C, 0x3942, 0x32A2, 0x6551, 0x6AA9, 
0x6551, 0x6AA9, 0x6551, 0x22A2, 0x3142, 0x1004, 0x0C18, 0x03E0,
0x07C0, 0x1830, 0x2008, 0x47C4, 0x4FE4, 0x9FF2, 0x9FF2, 0x9FF2, 
0x9FF2, 0x9FF2, 0x4FE4, 0x47C4, 0x2008, 0x1830, 0x07C0, 0x0000,
0x0000, 0x03C0, 0x0C30, 0x1188, 0x27E4, 0x2FF4, 0x4FF2, 0x5FFA,
0x5FFA, 0x4FF2, 0x2FF4, 0x27E4, 0x1188, 0x0C30, 0x03C0, 0x0000,
0x0000, 0x0000, 0x03C0, 0x0C30, 0x1008, 0x13C8, 0x27E4, 0x27E4, 
0x27E4, 0x27E4, 0x13C8, 0x1008, 0x0C30, 0x03C0, 0x0000, 0x0000,
0x0000, 0x43C2, 0x2C34, 0x1008, 0x2814, 0x2424, 0x4242, 0x4182, 
0x4182, 0x4242, 0x2424, 0x2814, 0x1008, 0x2C34, 0x43C2, 0x0000,
0x0000, 0x03C0, 0x0C30, 0x1008, 0x23C4, 0x2624, 0x4F92, 0x4FD2, 
0x4FF2, 0x4FF2, 0x27E4, 0x23C4, 0x1008, 0x0C30, 0x03C0, 0x0000,
0x0000, 0x03C0, 0x0C30, 0x1008, 0x23C4, 0x27E4, 0x4FF2, 0x4FF2, 
0x4FF2, 0x4FF2, 0x27E4, 0x23C4, 0x1008, 0x0C30, 0x03C0, 0x0000
#endif
};
	
static int radio_hi_off[] =
{
#ifdef SMALL_EGEM
0x0000, 0x03C0, 0x0C30, 0x1008, 0x2004, 0x2004, 0x4002, 0x4002,
0x4002, 0x4002, 0x2004, 0x2004, 0x1008, 0x0C30, 0x03C0, 0x0000
#else
0x0000, 0x03C0, 0x0C30, 0x1008, 0x2004, 0x2004, 0x4002, 0x4002,
0x4002, 0x4002, 0x2004, 0x2004, 0x1008, 0x0C30, 0x03C0, 0x0000,
0x0000, 0x03e0, 0x0c18, 0x1004, 0x2006, 0x2002, 0x4003, 0x4003,
0x4003, 0x4003, 0x4003, 0x2006, 0x200e, 0x181c, 0x0ff8, 0x03e0,
0x07C0, 0x1830, 0x2008, 0x4004, 0x4004, 0x8002, 0x8002, 0x8002,
0x8002, 0x8002, 0x4004, 0x4004, 0x2008, 0x1830, 0x07C0, 0x0000,
0x0000, 0x03C0, 0x0C30, 0x1008, 0x2004, 0x2004, 0x4002, 0x4002,
0x4002, 0x4002, 0x2004, 0x2004, 0x1008, 0x0C30, 0x03C0, 0x0000,
0x0000, 0x03C0, 0x0C30, 0x1008, 0x2004, 0x2004, 0x4002, 0x4002,
0x4002, 0x4002, 0x2004, 0x2004, 0x1008, 0x0C30, 0x03C0, 0x0000,
0x0000, 0x0000, 0x03C0, 0x0C30, 0x1008, 0x1008, 0x2004, 0x2004,
0x2004, 0x2004, 0x1008, 0x1008, 0x0C30, 0x03C0, 0x0000, 0x0000,
0x0000, 0x03C0, 0x0C30, 0x1008, 0x23C4, 0x2424, 0x4812, 0x4812, 
0x4812, 0x4812, 0x2424, 0x23C4, 0x1008, 0x0C30, 0x03C0, 0x0000,
0x0000, 0x03C0, 0x0C30, 0x1008, 0x23C4, 0x2424, 0x4812, 0x4812, 
0x4812, 0x4812, 0x2424, 0x23C4, 0x1008, 0x0C30, 0x03C0, 0x0000
#endif
};

static int radio_lo_on[] = {
0x0FF0, 0x781E, 0xE3C7, 0xCFF3, 0xCFF3, 0xE3C7, 0x781E, 0x0FF0 };

static int radio_lo_off[] = { 
0x0FF0, 0x781E, 0xE007, 0xC003, 0xC003, 0xE007, 0x781E, 0x0FF0 };

static int check_hi_on[] =
{
#ifdef SMALL_EGEM
0x0000, 0x7FFE, 0x6006, 0x500A, 0x4812, 0x4422, 0x4242, 0x4182, 
0x4182, 0x4242, 0x4422, 0x4812, 0x500A, 0x6006, 0x7FFE, 0x0000
#else
0x0000, 0x7FFE, 0x6006, 0x500A, 0x4812, 0x4422, 0x4242, 0x4182, 
0x4182, 0x4242, 0x4422, 0x4812, 0x500A, 0x6006, 0x7FFE, 0x0000,
0x0000, 0x7FFF, 0x4001, 0x580D, 0x5C1D, 0x4E39, 0x4771, 0x43E1, 
0x41C1, 0x43E1, 0x4771, 0x4E39, 0x5C1D, 0x580D, 0x4001, 0x7FFF,
0x0000, 0x7FFE, 0x4002, 0x500A, 0x4812, 0x4422, 0x4242, 0x4182,
0x4182, 0x4242, 0x4422, 0x4812, 0x500A, 0x4002, 0x7FFE, 0x0000,
0x0000, 0x7FFE, 0x4002, 0x500A, 0x4812, 0x4422, 0x4242, 0x4182,
0x4182, 0x4242, 0x4422, 0x4812, 0x500A, 0x4002, 0x7FFE, 0x0000,
0x0000, 0x4002, 0x3FFC, 0x300C, 0x2814, 0x2424, 0x2244, 0x2184, 
0x2184, 0x2244, 0x2424, 0x2814, 0x300C, 0x3FFC, 0x4002, 0x0000,
0x0000, 0x7FFE, 0x7FFE, 0x6002, 0x6002, 0x6002, 0x601A, 0x6032, 
0x6262, 0x66C2, 0x6782, 0x6702, 0x6602, 0x6002, 0x7FFE, 0x0000
#endif
};

static int check_hi_off[] =
{
#ifdef SMALL_EGEM
0x0000, 0x7FFE, 0x4002, 0x4002, 0x4002, 0x4002, 0x4002, 0x4002,
0x4002, 0x4002, 0x4002, 0x4002, 0x4002, 0x4002, 0x7FFE, 0x0000
#else
0x0000, 0x7FFE, 0x4002, 0x4002, 0x4002, 0x4002, 0x4002, 0x4002,
0x4002, 0x4002, 0x4002, 0x4002, 0x4002, 0x4002, 0x7FFE, 0x0000,
0x0000, 0x7FFF, 0x4001, 0x4001, 0x4001, 0x4001, 0x4001, 0x4001,
0x4001, 0x4001, 0x4001, 0x4001, 0x4001, 0x4001, 0x4001, 0x7FFF,
0x0000, 0x7FFE, 0x4002, 0x4002, 0x4002, 0x4002, 0x4002, 0x4002,
0x4002, 0x4002, 0x4002, 0x4002, 0x4002, 0x4002, 0x7FFE, 0x0000,
0x0000, 0x0000, 0x3FFC, 0x2004, 0x2004, 0x2004, 0x2004, 0x2004, 
0x2004, 0x2004, 0x2004, 0x2004, 0x2004, 0x3FFC, 0x0000, 0x0000,
0x0000, 0x0000, 0x3FFC, 0x2004, 0x2004, 0x2004, 0x2004, 0x2004, 
0x2004, 0x2004, 0x2004, 0x2004, 0x2004, 0x3FFC, 0x0000, 0x0000,
0xFFFC, 0x8006, 0x8006, 0x8006, 0x8006, 0x8006, 0x8006, 0x8006, 
0x8006, 0x8006, 0x8006, 0x8006, 0x8006, 0xFFFE, 0x7FFE, 0x0000
#endif
};

static int check_lo_on[] = 
{ 0x7FFC, 0x701C, 0x4C64, 0x4384, 0x4C64, 0x701C, 0x7FFC ,0x0000 };

static int check_lo_off[] = 
{ 0x7FFC, 0x4004, 0x4004, 0x4004, 0x4004, 0x4004, 0x7FFC ,0x0000 };

static int cycle_hi[] =
{
#ifdef SMALL_EGEM 
0x0000, 0x1000, 0x19C0, 0x1C30, 0x1E08, 0x0008, 0x2004, 0x2004,
0x2004, 0x2004, 0x1000, 0x1078, 0x0C38, 0x0398, 0x0008, 0x0000
#else
0x0000, 0x1000, 0x19C0, 0x1C30, 0x1E08, 0x0008, 0x2004, 0x2004,
0x2004, 0x2004, 0x1000, 0x1078, 0x0C38, 0x0398, 0x0008, 0x0000,
0x0000, 0x0180, 0x03C0, 0x07E0, 0x0FF0, 0x1FF8, 0x3FFC, 0x0000,
0x0000, 0x3FFC, 0x1FF8, 0x0FF0, 0x07E0, 0x03C0, 0x0180, 0x0000
#endif
};

static int cycle_lo[] = {
0x0800, 0x0FE0, 0x0F18, 0x2004, 0x2004, 0x18F0, 0x07F0, 0x0010 };

static int arrow_up_lo_sel[] = {
0x0000, 0x0180, 0x0180, 0x03C0, 0x03C0, 0x07E0, 0x07E0, 0x0000 };
static int arrow_up_lo[] = {
0x0000, 0x0180, 0x0180, 0x0240, 0x0240, 0x0420, 0x07E0, 0x0000};

static int arrow_dn_lo_sel[] = {
0x0000, 0x07E0, 0x07E0, 0x03E0, 0x03C0, 0x0180, 0x0180, 0x0000};
static int arrow_dn_lo[] = {
0x0000, 0x07E0, 0x0420, 0x0240, 0x0240, 0x0180, 0x0180, 0x0000};

static int arrow_right_lo_sel[] = {
0x0000, 0x3C00, 0x3FC0, 0x3FFC, 0x3FC0, 0x3C00, 0x0000 , 0x0000};
static int arrow_right_lo[] = {
0x0000, 0x3C00, 0x23C0, 0x203C, 0x23C0, 0x3C00, 0x0000 , 0x0000};

static int arrow_left_lo_sel[] = {
0x0000, 0x001E, 0x01FE, 0x1FFE, 0x01FE, 0x001E, 0x0000, 0x0000 };
static int arrow_left_lo[] = {
0x0000, 0x001E, 0x01E2, 0x1E02, 0x01E2, 0x001E, 0x0000, 0x0000 };

static int arrow_up_hi_sel[] =
{
#ifdef SMALL_EGEM
0x0000, 0x0000, 0x0080, 0x00C0, 0x01C0, 0x01E0, 0x03E0, 0x03F0, 
0x07F0, 0x07F8, 0x0FF8, 0x0FFC, 0x1FFC, 0x1FFE, 0x0FFE, 0x0000
#else
0x0000, 0x0000, 0x0080, 0x00C0, 0x01C0, 0x01E0, 0x03E0, 0x03F0, 
0x07F0, 0x07F8, 0x0FF8, 0x0FFC, 0x1FFC, 0x1FFE, 0x0FFE, 0x0000,
0x0000, 0x0000, 0x0180, 0x0180, 0x03C0, 0x03C0, 0x07E0, 0x07E0, 
0x0FF0, 0x0FF0, 0x1FF8, 0x1FF8, 0x3FFC, 0x3FFC, 0x0000, 0x0000,
0x0000, 0x0180, 0x03C0, 0x07E0, 0x0FF0, 0x1FF8, 0x3FFC, 0x7FFE, 
0x7FFE, 0x7FFE, 0x0FF0, 0x0FF0, 0x0FF0, 0x0FF0, 0x0000, 0x0000
#endif
};

static int arrow_up_hi[] =
{
#ifdef SMALL_EGEM
0x0000, 0x0000, 0x0080, 0x00C0, 0x0140, 0x0160, 0x0220, 0x0230, 
0x0410, 0x0418, 0x0808, 0x080C, 0x1004, 0x1FFE, 0x0FFE, 0x0000
#else
0x0000, 0x0000, 0x0080, 0x00C0, 0x0140, 0x0160, 0x0220, 0x0230, 
0x0410, 0x0418, 0x0808, 0x080C, 0x1004, 0x1FFE, 0x0FFE, 0x0000,
0x0000, 0x0000, 0x0180, 0x0180, 0x0240, 0x0240, 0x0420, 0x0420, 
0x0810, 0x0810, 0x1008, 0x1008, 0x2004, 0x3FFC, 0x0000, 0x0000,
0x0000, 0x0180, 0x03C0, 0x0660, 0x0C30, 0x1818, 0x300C, 0x6006, 
0x4002, 0x781E, 0x0810, 0x0810, 0x0810, 0x0FF0, 0x0000, 0x0000
#endif
};

static int arrow_dn_hi_sel[] =
{
#ifdef SMALL_EGEM
0x0000, 0x0000, 0x1FFC, 0x1FFC, 0x1FFC, 0x0FF8, 0x0FF8, 0x07F0, 
0x07F0, 0x03E0, 0x03E0, 0x01C0, 0x01C0, 0x0080, 0x0000, 0x0000
#else
0x0000, 0x0000, 0x1FFC, 0x1FFC, 0x1FFC, 0x0FF8, 0x0FF8, 0x07F0, 
0x07F0, 0x03E0, 0x03E0, 0x01C0, 0x01C0, 0x0080, 0x0000, 0x0000,
0x0000, 0x0000, 0x3FFC, 0x3FFC, 0x1FF8, 0x1FF8, 0x0FF0, 0x0FF0, 
0x07E0, 0x07E0, 0x03C0, 0x03C0, 0x0180, 0x0180, 0x0000, 0x0000,
0x0000, 0x0000, 0x0FF0, 0x0FF0, 0x0FF0, 0x0FF0, 0x7FFE, 0x7FFE, 
0x7FFE, 0x3FFC, 0x1FF8, 0x0FF0, 0x07E0, 0x03C0, 0x0180, 0x0000
#endif
};

static int arrow_dn_hi[] =
{
#ifdef SMALL_EGEM
0x0000, 0x0000, 0x1FFC, 0x100C, 0x180C, 0x0818, 0x0C18, 0x0430, 
0x0630, 0x0260, 0x0360, 0x01C0, 0x01C0, 0x0080, 0x0000, 0x0000
#else
0x0000, 0x0000, 0x1FFC, 0x100C, 0x180C, 0x0818, 0x0C18, 0x0430, 
0x0630, 0x0260, 0x0360, 0x01C0, 0x01C0, 0x0080, 0x0000, 0x0000,
0x0000, 0x0000, 0x3FFC, 0x2004, 0x1008, 0x1008, 0x0810, 0x0810, 
0x0420, 0x0420, 0x0240, 0x0240, 0x0180, 0x0180, 0x0000, 0x0000,
0x0000, 0x0000, 0x0FF0, 0x0810, 0x0810, 0x0810, 0x781E, 0x4002, 
0x6006, 0x300C, 0x1818, 0x0C30, 0x0660, 0x03C0, 0x0180, 0x0000
#endif
};

static int arrow_left_hi_sel[] =
{
#ifdef SMALL_EGEM
0x0000, 0x0000, 0x000C, 0x003E, 0x00FE, 0x03FE, 0x0FFE, 0x3FFE, 
0x1FFE, 0x07FE, 0x01FE, 0x007E, 0x001E, 0x0006, 0x0000, 0x0000
#else
0x0000, 0x0000, 0x000C, 0x003E, 0x00FE, 0x03FE, 0x0FFE, 0x3FFE, 
0x1FFE, 0x07FE, 0x01FE, 0x007E, 0x001E, 0x0006, 0x0000, 0x0000,
0x0000, 0x0000, 0x000C, 0x003C, 0x00FC, 0x03FC, 0x0FFC, 0x3FFC, 
0x3FFC, 0x0FFC, 0x03FC, 0x00FC, 0x003C, 0x000C, 0x0000, 0x0000,
0x0000, 0x01C0, 0x03C0, 0x07C0, 0x0FFC, 0x1FFC, 0x3FFC, 0x7FFC, 
0x7FFC, 0x3FFC, 0x1FFC, 0x0FFC, 0x07C0, 0x03C0, 0x01C0, 0x0000
#endif
};

static int arrow_left_hi[] =
{
#ifdef SMALL_EGEM
0x0000, 0x0000, 0x000C, 0x0036, 0x00C6, 0x0306, 0x0C06, 0x3006, 
0x1C06, 0x0706, 0x01C6, 0x0076, 0x001E, 0x0006, 0x0000, 0x0000
#else
0x0000, 0x0000, 0x000C, 0x0036, 0x00C6, 0x0306, 0x0C06, 0x3006, 
0x1C06, 0x0706, 0x01C6, 0x0076, 0x001E, 0x0006, 0x0000, 0x0000,
0x0000, 0x0000, 0x000C, 0x0034, 0x00C4, 0x0304, 0x0C04, 0x3004, 
0x3004, 0x0C04, 0x0304, 0x00C4, 0x0034, 0x000C, 0x0000, 0x0000,
0x0000, 0x01C0, 0x0340, 0x0640, 0x0C7C, 0x1804, 0x3004, 0x6004, 
0x6004, 0x3004, 0x1804, 0x0C7C, 0x0640, 0x0340, 0x01C0, 0x0000
#endif
};

static int arrow_right_hi_sel[] =
{
#ifdef SMALL_EGEM
0x0000, 0x0000, 0x3000, 0x3C00, 0x3F00, 0x3FC0, 0x3FF0, 0x3FFC, 
0x3FFE, 0x3FF8, 0x3FE0, 0x3F80, 0x3E00, 0x1800, 0x0000, 0x0000
#else
0x0000, 0x0000, 0x3000, 0x3C00, 0x3F00, 0x3FC0, 0x3FF0, 0x3FFC, 
0x3FFE, 0x3FF8, 0x3FE0, 0x3F80, 0x3E00, 0x1800, 0x0000, 0x0000,
0x0000, 0x0000, 0x3000, 0x3C00, 0x3F00, 0x3FC0, 0x3FF0, 0x3FFC, 
0x3FFC, 0x3FF0, 0x3FC0, 0x3F00, 0x3C00, 0x3000, 0x0000, 0x0000,
0x0000, 0x0380, 0x03C0, 0x03E0, 0x3FF0, 0x3FF8, 0x3FFC, 0x3FFE, 
0x3FFE, 0x3FFC, 0x3FF8, 0x3FF0, 0x03E0, 0x03C0, 0x0380, 0x0000
#endif
};

static int arrow_right_hi[] =
{
#ifdef SMALL_EGEM
0x0000, 0x0000, 0x3000, 0x2C00, 0x2300, 0x20C0, 0x2030, 0x200C, 
0x203E, 0x20F8, 0x23E0, 0x2F80, 0x3E00, 0x1800, 0x0000, 0x0000
#else
0x0000, 0x0000, 0x3000, 0x2C00, 0x2300, 0x20C0, 0x2030, 0x200C,
0x203E, 0x20F8, 0x23E0, 0x2F80, 0x3E00, 0x1800, 0x0000, 0x0000,
0x0000, 0x0000, 0x3000, 0x2C00, 0x2300, 0x20C0, 0x2030, 0x200C, 
0x200C, 0x2030, 0x20C0, 0x2300, 0x2C00, 0x3000, 0x0000, 0x0000,
0x0000, 0x0380, 0x02C0, 0x0260, 0x3E30, 0x2018, 0x200C, 0x2006, 
0x2006, 0x200C, 0x2018, 0x3E30, 0x0260, 0x02C0, 0x0380, 0x0000
#endif
};

#ifdef SMALL_EGEM

static IMAGE radio_im[] = 
{{radio_hi_on,radio_hi_off,radio_lo_on,radio_lo_off}};

static IMAGE check_im[] = 
{{check_hi_on,check_hi_off,check_lo_on,check_lo_off}};

static IMAGE cycle_im[] = 
{{cycle_hi,NULL,cycle_lo,NULL}};

static IMAGE arrow_up_im[] = 
{{arrow_up_hi_sel,arrow_up_hi,arrow_up_lo_sel,arrow_up_lo}};

static IMAGE arrow_dn_im[] = 
{{arrow_dn_hi_sel,arrow_dn_hi,arrow_dn_lo_sel,arrow_dn_lo}};

static IMAGE arrow_left_im[] =
{{arrow_left_hi_sel,arrow_left_hi,arrow_left_lo_sel,arrow_left_lo}};

static IMAGE arrow_right_im[] =
{{arrow_right_hi_sel,arrow_right_hi,arrow_right_lo_sel,arrow_right_lo}};

IMAGES _radios = { 1, radio_im };
IMAGES _checks = { 1, check_im };
IMAGES _cycles = { 1, cycle_im };
IMAGES _arrows_up	= { 1, arrow_up_im };
IMAGES _arrows_down	= { 1, arrow_dn_im };
IMAGES _arrows_right= { 1, arrow_right_im };
IMAGES _arrows_left	= { 1, arrow_left_im };

#else

static IMAGE radio_im[] = {
{radio_hi_on,radio_hi_off,radio_lo_on,radio_lo_off},
{radio_hi_on+16,radio_hi_off+16,NULL,NULL},
{radio_hi_on+32,radio_hi_off+32,NULL,NULL},
{radio_hi_on+48,radio_hi_off+48,NULL,NULL},
{radio_hi_on+64,radio_hi_off+80,NULL,NULL},
{radio_hi_on+80,radio_hi_off+64,NULL,NULL},
{radio_hi_on+96,radio_hi_off+96,NULL,NULL},
{radio_hi_on+112,radio_hi_off+112,NULL,NULL} };

static IMAGE check_im[] = {
{check_hi_on,check_hi_off,check_lo_on,check_lo_off},
{check_hi_on+16,check_hi_off+16,NULL,NULL},
{check_hi_on+32,check_hi_off+48,NULL,NULL},
{check_hi_on+48,check_hi_off+32,NULL,NULL},
{check_hi_on+64,check_hi_off+64,NULL,NULL},
{check_hi_on+80,check_hi_off+80,NULL,NULL} };

static IMAGE cycle_im[] = {
{cycle_hi,NULL,cycle_lo,NULL},
{cycle_hi+16,NULL,NULL,NULL} };

static IMAGE arrow_up_im[] = {
{arrow_up_hi_sel,arrow_up_hi,arrow_up_lo_sel,arrow_up_lo},
{arrow_up_hi_sel+16,arrow_up_hi+16,NULL,NULL},
{arrow_up_hi_sel+32,arrow_up_hi+32,NULL,NULL} };

static IMAGE arrow_dn_im[] = {
{arrow_dn_hi_sel,arrow_dn_hi,arrow_dn_lo_sel,arrow_dn_lo},
{arrow_dn_hi_sel+16,arrow_dn_hi+16,NULL,NULL},
{arrow_dn_hi_sel+32,arrow_dn_hi+32,NULL,NULL} };

static IMAGE arrow_left_im[] = {
{arrow_left_hi_sel,arrow_left_hi,arrow_left_lo_sel,arrow_left_lo},
{arrow_left_hi_sel+16,arrow_left_hi+16,NULL,NULL},
{arrow_left_hi_sel+32,arrow_left_hi+32,NULL,NULL} };

static IMAGE arrow_right_im[] = {
{arrow_right_hi_sel,arrow_right_hi,arrow_right_lo_sel,arrow_right_lo},
{arrow_right_hi_sel+16,arrow_right_hi+16,NULL,NULL},
{arrow_right_hi_sel+32,arrow_right_hi+32,NULL,NULL} };

IMAGES _radios = { 8, radio_im };
IMAGES _checks = { 6, check_im };
IMAGES _cycles = { 2, cycle_im };
IMAGES _arrows_up	= { 3, arrow_up_im };
IMAGES _arrows_down	= { 3, arrow_dn_im };
IMAGES _arrows_right= { 3, arrow_right_im };
IMAGES _arrows_left	= { 3, arrow_left_im };

#endif