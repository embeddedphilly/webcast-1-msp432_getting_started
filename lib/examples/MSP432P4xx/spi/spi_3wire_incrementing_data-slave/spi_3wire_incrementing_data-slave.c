/*
 * -------------------------------------------
 *    MSP432 DriverLib - v2_20_00_08 
 * -------------------------------------------
 *
 * --COPYRIGHT--,BSD,BSD
 * Copyright (c) 2014, Texas Instruments Incorporated
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * *  Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * *  Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * *  Neither the name of Texas Instruments Incorporated nor the names of
 *    its contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 * EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * --/COPYRIGHT--*/
/*******************************************************************************
 * MSP432 SPI - 3-wire Slave Incremented Data
 *
 * SPI slave talks to SPI master using 3-wire mode. Data is received
 * from master and data from slave is then transmitted back to master.
 * USCI RX ISR is used to handle communication, CPU normally in LPM4.
 * Prior to initial data exchange, master pulses slaves RST for complete
 * reset.
 *
 * Note that in this example, EUSCIA0 is used for the SPI port. If the user
 * wants to use EUSCIB for SPI operation, they are able to with the same APIs
 * with the EUSCI_BX parameters.
 *
 * Use with the master version of the code example
 *
 *                MSP432P401
 *              -----------------
 *             |                 |
 *             |                 |
 *             |                 |
 *             |             P1.3|<- Data In (UCA0SIMO)
 *             |                 |
 *             |             P1.2|-> Data Out (UCA0SOMI)
 *             |                 |
 *             |             P1.1|<- Serial Clock In (UCA0CLK)
 *
*******************************************************************************/
/* DriverLib Includes */
#include "driverlib.h"

/* Statics */
static volatile uint8_t transmitData = 0x01, receiveData = 0x00;

/* SPI Slave Configuration Parameter */
const eUSCI_SPI_SlaveConfig spiSlaveConfig =
{
        EUSCI_A_SPI_MSB_FIRST,                          // MSB First
        EUSCI_A_SPI_PHASE_DATA_CHANGED_ONFIRST_CAPTURED_ON_NEXT,  // Phase
        EUSCI_A_SPI_CLOCKPOLARITY_INACTIVITY_HIGH,     // Normal Polarity
        EUSCI_A_SPI_3PIN                               // 3wire mode
};

int main(void)
{
    /* Stop watchdog timer */
    WDT_A_holdTimer();

     /* Starting and enabling LFXT (32kHz) */
    GPIO_setAsPeripheralModuleFunctionOutputPin(GPIO_PORT_PJ,
            GPIO_PIN0 | GPIO_PIN1, GPIO_PRIMARY_MODULE_FUNCTION);
    CS_setExternalClockSourceFrequency(32768, 0);
    CS_initClockSignal(CS_ACLK, CS_LFXTCLK_SELECT, CS_CLOCK_DIVIDER_1);
    CS_startLFXT(CS_LFXT_DRIVE0);

    /* Selecting P1.1 P1.2 and P1.3 in SPI mode */
    GPIO_setAsPeripheralModuleFunctionInputPin(GPIO_PORT_P1,
            GPIO_PIN1 | GPIO_PIN2 | GPIO_PIN3, GPIO_PRIMARY_MODULE_FUNCTION);

    /* Initialize slave to MSB first, inactive high clock polarity and
     * 3 wire SPI */
    SPI_initSlave(EUSCI_A0_MODULE, &spiSlaveConfig);

    /* Enable the SPI module */
    SPI_enableModule(EUSCI_A0_MODULE);

    /* Enable Receive interrupt */
    SPI_enableInterrupt(EUSCI_A0_MODULE, EUSCI_A_SPI_RECEIVE_INTERRUPT);
    Interrupt_enableSleepOnIsrExit();
    Interrupt_enableInterrupt(INT_EUSCIA0);

    Interrupt_enableMaster();
    PCM_gotoLPM0();

}

//******************************************************************************
//
//This is the USCI_A0 interrupt vector service routine.
//
//******************************************************************************
void euscia0_isr(void)
{
    uint32_t status;

    status = SPI_getEnabledInterruptStatus(EUSCI_A0_MODULE);
    SPI_clearInterruptFlag(EUSCI_A0_MODULE, status);

    if(status & EUSCI_A_SPI_RECEIVE_INTERRUPT)
    {
        /* USCI_A0 TX buffer ready? */
        while (!(SPI_getInterruptStatus(EUSCI_A0_MODULE, EUSCI_A_SPI_TRANSMIT_INTERRUPT)));

        /* Transmit data to master */
        SPI_transmitData(EUSCI_A0_MODULE, transmitData++);

        //Receive data from master
        receiveData = SPI_receiveData(EUSCI_A0_MODULE);
    }
}

