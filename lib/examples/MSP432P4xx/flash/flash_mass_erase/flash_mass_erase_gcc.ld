/******************************************************************************
 *
 * Linker configuration file for MSP432.
 *
 *****************************************************************************/

MEMORY
{
    FLASH                 (RX) : ORIGIN = 0x00000000, LENGTH = 0x0003E000
    FLASH_FILLER          (RX) : ORIGIN = 0x0003E000, LENGTH = 0x00002000
    FLASH_OTP             (RX) : ORIGIN = 0x00200000, LENGTH = 0x00004000
    SRAM                  (RWX): ORIGIN = 0x20000000, LENGTH = 0x00010000
}

SECTIONS
{
    .text :
    {
        _text = .;
        KEEP(*(.isr_vector))
        *(.text*)
        *(.rodata*)
        _etext = .;
    } > FLASH

    .data : AT(ADDR(.text) + SIZEOF(.text))
    {
        _data = .;
        *(vtable)
        *(.data*)
        _edata = .;
    } > SRAM

    .bss :
    {
        _bss = .;
        *(.bss*)
        *(COMMON)
        _ebss = .;
    } > SRAM
}
