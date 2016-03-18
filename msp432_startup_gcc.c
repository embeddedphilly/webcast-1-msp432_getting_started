//*****************************************************************************
// startup_gcc.c - Startup code for use with GNU tools.
//*****************************************************************************

#include <stdint.h>
#include "msp432p401r.h"

//*****************************************************************************
//
// Forward declaration of the default fault handlers.
//
//*****************************************************************************
void ResetISR(void);
static void NmiSR(void);
static void FaultISR(void);
static void IntDefaultHandler(void);

//*****************************************************************************
// External declaration for the interrupt handler used by the application.
//*****************************************************************************

//*****************************************************************************
// The entry point for the application.
//*****************************************************************************
extern int main(void);


//*****************************************************************************
// Reserve space for the system stack.
//*****************************************************************************
static uint32_t systemStack[512];

//*****************************************************************************
// The vector table.  Note that the proper constructs must be placed on this to
// ensure that it ends up at physical address 0x0000.0000.
//*****************************************************************************
__attribute__ ((section(".isr_vector")))
void (* const g_pfnVectors[])(void) =
{
    (void (*)(void))((uint32_t)systemStack + sizeof(systemStack)),
                                            // The initial stack pointer
    ResetISR,                               // The reset handler
    NmiSR,                                  // The NMI handler
    FaultISR,                               // The hard fault handler
    IntDefaultHandler,                      // The MPU fault handler
    IntDefaultHandler,                      // The bus fault handler
    IntDefaultHandler,                      // The usage fault handler
    0,                                      // Reserved
    0,                                      // Reserved
    0,                                      // Reserved
    0,                                      // Reserved
    IntDefaultHandler,                      // SVCall handler
    IntDefaultHandler,                      // Debug monitor handler
    0,                                      // Reserved
    IntDefaultHandler,                      // The PendSV handler
    IntDefaultHandler,                      // The SysTick handler
    IntDefaultHandler,                      // PSS ISR
    IntDefaultHandler,                      // CS ISR 
    IntDefaultHandler,                      // PCM ISR
    IntDefaultHandler,                      // WDT ISR
    IntDefaultHandler,                      // FPU ISR
    IntDefaultHandler,                      // FLCTL ISR
    IntDefaultHandler,                      // COMP_E0_MODULE ISR
    IntDefaultHandler,                      // COMP_E1_MODULE ISR
    IntDefaultHandler,                      // TA0_0 ISR
    IntDefaultHandler,                      // TA0_N ISR
    IntDefaultHandler,                      // TA1_0 ISR
    IntDefaultHandler,                      // TA1_N ISR
    IntDefaultHandler,                      // TA2_0 ISR
    IntDefaultHandler,                      // TA2_N ISR
    IntDefaultHandler,                      // TA3_0 ISR
    IntDefaultHandler,                      // TA3_N ISR
    IntDefaultHandler,                      // EUSCIA0 ISR
    IntDefaultHandler,                      // EUSCIA1 ISR
    IntDefaultHandler,                      // EUSCIA2 ISR
    IntDefaultHandler,                      // EUSCIA3 ISR
    IntDefaultHandler,                      // EUSCIB0 ISR
    IntDefaultHandler,                      // EUSCIB1 ISR
    IntDefaultHandler,                      // EUSCIB2 ISR
    IntDefaultHandler,                      // EUSCIB3 ISR
    IntDefaultHandler,                      // ADC12 ISR
    IntDefaultHandler,                      // T32_INT1 ISR
    IntDefaultHandler,                      // T32_INT2 ISR
    IntDefaultHandler,                      // T32_INTC ISR
    IntDefaultHandler,                      // AES ISR
    IntDefaultHandler,                      // RTC ISR
    IntDefaultHandler,                      // DMA_ERR ISR
    IntDefaultHandler,                      // DMA_INT3 ISR
    IntDefaultHandler,                      // DMA_INT2 ISR
    IntDefaultHandler,                       // DMA_INT1 ISR
    IntDefaultHandler,                      // DMA_INT0 ISR
    IntDefaultHandler,                      // PORT1 ISR
    IntDefaultHandler,                      // PORT2 ISR
    IntDefaultHandler,                      // PORT3 ISR
    IntDefaultHandler,                      // PORT4 ISR
    IntDefaultHandler,                      // PORT5 ISR
    IntDefaultHandler,                      // PORT6 ISR
    IntDefaultHandler,                      // Reserved 41
    IntDefaultHandler,                      // Reserved 42
    IntDefaultHandler,                      // Reserved 43
    IntDefaultHandler,                      // Reserved 44
    IntDefaultHandler,                      // Reserved 45
    IntDefaultHandler,                      // Reserved 46
    IntDefaultHandler,                      // Reserved 47
    IntDefaultHandler,                      // Reserved 48
    IntDefaultHandler,                      // Reserved 49
    IntDefaultHandler,                      // Reserved 50
    IntDefaultHandler,                      // Reserved 51
    IntDefaultHandler,                      // Reserved 52
    IntDefaultHandler,                      // Reserved 53
    IntDefaultHandler,                      // Reserved 54
    IntDefaultHandler,                      // Reserved 55
    IntDefaultHandler,                      // Reserved 56
    IntDefaultHandler,                      // Reserved 57
    IntDefaultHandler,                      // Reserved 58
    IntDefaultHandler,                      // Reserved 59
    IntDefaultHandler,                      // Reserved 60
    IntDefaultHandler,                      // Reserved 61
    IntDefaultHandler,                      // Reserved 62
    IntDefaultHandler,                      // Reserved 63
    IntDefaultHandler                       // Reserved 64
};

//*****************************************************************************
// The following are constructs created by the linker, indicating where the
// the "data" and "bss" segments reside in memory.  The initializers for the
// for the "data" segment resides immediately following the "text" segment.
//*****************************************************************************
extern uint32_t _etext;
extern uint32_t _data;
extern uint32_t _edata;
extern uint32_t _bss;
extern uint32_t _ebss;

//*****************************************************************************
// This is the code that gets called when the processor first starts execution
// following a reset event.  Only the absolutely necessary set is performed,
// after which the application supplied entry() routine is called.  Any fancy
// actions (such as making decisions based on the reset cause register, and
// resetting the bits in that register) are left solely in the hands of the
// application.
//*****************************************************************************
void
ResetISR(void)
{
    uint32_t *src, *dest;

    //
    // Copy the data segment initializers from flash to SRAM.
    //
    src = &_etext;
    for(dest = &_data; dest < &_edata; )
    {
        *dest++ = *src++;
    }

    //
    // Zero fill the bss segment.
    //
    __asm("    ldr     r0, =_bss\n"
          "    ldr     r1, =_ebss\n"
          "    mov     r2, #0\n"
          "    .thumb_func\n"
          "zero_loop:\n"
          "        cmp     r0, r1\n"
          "        it      lt\n"
          "        strlt   r2, [r0], #4\n"
          "        blt     zero_loop");

    //
    // Enable the floating-point unit.  This must be done here to handle the
    // case where main() uses floating-point and the function prologue saves
    // floating-point registers (which will fault if floating-point is not
    // enabled).  Any configuration of the floating-point unit using DriverLib
    // APIs must be done here prior to the floating-point unit being enabled.
    //
    // Note that this does not use DriverLib since it might not be included in
    // this project.
    //
    HWREG32(SCS_BASE + OFS_SCB_CPACR) =
            ((HWREG32(SCS_BASE + OFS_SCB_CPACR)
                    & ~(SCB_CPACR_CP11_M | SCB_CPACR_CP10_M))
                    | SCB_CPACR_CP11_M | SCB_CPACR_CP10_M);

    //
    // Call the application's entry point.
    //
    main();
}

//*****************************************************************************
//
// This is the code that gets called when the processor receives a NMI.  This
// simply enters an infinite loop, preserving the system state for examination
// by a debugger.
//
//*****************************************************************************
static void
NmiSR(void)
{
    //
    // Enter an infinite loop.
    //
    while(1)
    {
    }
}

//*****************************************************************************
//
// This is the code that gets called when the processor receives a fault
// interrupt.  This simply enters an infinite loop, preserving the system state
// for examination by a debugger.
//
//*****************************************************************************
static void
FaultISR(void)
{
    //
    // Enter an infinite loop.
    //
    while(1)
    {
    }
}

//*****************************************************************************
//
// This is the code that gets called when the processor receives an unexpected
// interrupt.  This simply enters an infinite loop, preserving the system state
// for examination by a debugger.
//
//*****************************************************************************
static void
IntDefaultHandler(void)
{
    //
    // Go into an infinite loop.
    //
    while(1)
    {
    }
}
