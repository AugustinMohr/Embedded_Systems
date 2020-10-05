/*****************************************************************************
*
* Copyright (C) 2013 - 2017 Texas Instruments Incorporated - http://www.ti.com/
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions
* are met:
*
* * Redistributions of source code must retain the above copyright
*   notice, this list of conditions and the following disclaimer.
*
* * Redistributions in binary form must reproduce the above copyright
*   notice, this list of conditions and the following disclaimer in the
*   documentation and/or other materials provided with the
*   distribution.
*
* * Neither the name of Texas Instruments Incorporated nor the names of
*   its contributors may be used to endorse or promote products derived
*   from this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
* "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
* LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
* A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
* OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
* SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
* LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
* DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
* THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
* OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*
******************************************************************************
*
* MSP432 empty main.c template
*
******************************************************************************/

#include "msp.h"

#define PWM_PER (20 * 64)

void delay(int time); // in ms

void initClock(void);

void initTimerA(void);

void initPWM(int duty);

int main(void)
{
    //init
    // Stop the watchdog timer
    WDT_A->CTL = WDT_A_CTL_PW | WDT_A_CTL_HOLD;

    initClock();
    initTimerA();
    initPWM(10);

    //int period, duty, i;

    P2->DIR = 0xFF;
    P2->OUT = 0x00;


    while(1)
    {

    }
    return 0;
}

void initPWM(int duty) {
    TIMER_A0->CCR[0] = PWM_PER; // 20 ms period
    TIMER_A0->CCR[1] = duty * 64; // duty cycle
    TIMER_A0->CCTL[OUTMOD] |= TIMER_A_CCTLN_OUTMOD_4;

    // output PWM to
}

void initClock(void) {
    CS->KEY = CS_KEY_VAL;
    CS->CLKEN |= CS_CLKEN_ACLK_EN;   // ENABLE DE ACKL
    //CS->CTL1 |= CS_CTL1_SELA__REFOCLK | CS_CTL1_DIVA__64; // SOURCE = REFO, DIV = 64
    CS->CLKEN |= CS_CLKEN_REFOFSEL; // FREQUENCY = 128 kHz
}

void initTimerA(void) {
    TIMER_A0->CTL &= ~(TIMER_A_CTL_MC__UPDOWN | TIMER_A_CTL_SSEL__INCLK);
    TIMER_A0->CTL |= TIMER_A_CTL_MC__UPDOWN | TIMER_A_CTL_SSEL__ACLK;// CONFIG DE TIMER A; SOURCE = ACKL, MODE = UP/DOWN,
    TIMER_A0->CCTL[0] &= ~TIMER_A_CCTLN_CAP; // compare mode
}

void delay(int time) {

    TIMER_A0->CTL &= ~TIMER_A_CTL_IFG; //reset interrupt flag
    TIMER_A0->CTL |= TIMER_A_CTL_CLR; // clear timer A
    TIMER_A0->CCR[0] = 64 * time; // fill compare register

    while((TIMER_A0->CTL & TIMER_A_CTL_IFG) == 0) ;
    TIMER_A0->CCR[0] = 0;// stop timer
}
