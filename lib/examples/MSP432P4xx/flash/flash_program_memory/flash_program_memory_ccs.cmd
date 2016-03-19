--retain=g_pfnVectors
--retain=flashMailbox

MEMORY
{
    FLASH                 (RX) : origin = 0x00000000, length = 0x0003F000
    FLASH_CALIBRATION     (RX) : origin = 0x0003F000, length = 0x00001000
    FLASH_OTP             (RX) : origin = 0x00200000, length = 0x00004000
    SRAM                  (RWX): origin = 0x20000000, length = 0x00010000
}

/* The following command line options are set as part of the CCS project.    */
/* If you are building using the command line, or for some reason want to    */
/* define them here, you can uncomment and modify these lines as needed.     */
/* If you are using CCS for building, it is probably better to make any such */
/* modifications in your CCS project and leave this file alone.              */
/*                                                                           */
/* --heap_size=0                                                             */
/* --stack_size=512                                                          */
/* --library=rtsv7M4_T_le_eabi.lib                                           */

/* Section allocation in memory */

SECTIONS
{
    .intvecs:   > 0x00000000
    .text   :   > FLASH
    .const  :   > FLASH
    .cinit  :   > FLASH
    .pinit  :   > FLASH

    .flashMailbox : > 0x00202000

    .vtable :   > 0x20000000
    .data   :   > SRAM
    .bss    :   > SRAM
    .sysmem :   > SRAM
    .stack  :   > SRAM (HIGH)
}


