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
#include <stdbool.h>

#define PWM_PER (20 * 16)

void delay(int time); // in ms

void initClock(void);

void initTimerA(void);

void initGPIO(void);

void initPWM(float duty);

void initInterrupts(void);

void initADC(void);

void TA0_N_IRQHandler(void);

void ADC14_IRQHandler(void);


uint16_t resultat;

int main(void)
{
    //init
    // Stop the watchdog timer
    WDT_A->CTL = WDT_A_CTL_PW | WDT_A_CTL_HOLD;

    initGPIO();
    initClock();
    initInterrupts();
    initADC();
    initTimerA();
    initPWM(1);


    //int period, duty, i;


    //P2->OUT = 0x00;


    while(1)
    {


    }
    //return 0;
}

void initPWM(float duty) {
    TIMER_A0->CCR[0] = PWM_PER; // 20 ms period
    TIMER_A0->CCR[1] = duty * 16; // duty cycle
    TIMER_A0->CCTL[1] |= TIMER_A_CCTLN_OUTMOD_2; // Toggle/reset, acts here as Toggle/set for some reason
    TIMER_A0->CCTL[1] |= TIMER_A_CCTLN_OUT;


}

void initClock(void) {
    CS->KEY = CS_KEY_VAL;
    CS->CLKEN |= CS_CLKEN_ACLK_EN;   // ENABLE DE ACKL
    //CS->CTL1 |= CS_CTL1_SELA__REFOCLK | CS_CTL1_DIVA__64; // SOURCE = REFO, DIV = 64
    CS->CLKEN |= CS_CLKEN_REFOFSEL; // FREQUENCY = 128 kHz
}

void initTimerA(void) {
    TIMER_A0->CTL |= TIMER_A_CTL_CLR;
    TIMER_A0->CTL &= ~(TIMER_A_CTL_MC__UPDOWN | TIMER_A_CTL_SSEL__INCLK);
    TIMER_A0->CTL |= TIMER_A_CTL_MC__UPDOWN | TIMER_A_CTL_SSEL__ACLK;// CONFIG DE TIMER A; SOURCE = ACKL, MODE = UP/DOWN,
    TIMER_A0->CCTL[0] &= ~TIMER_A_CCTLN_CAP; // compare mode
}

void initGPIO(void) {

    P2->DIR = 0xFF;
    P2->SEL0 |= (0b1 << 4);
    P2->SEL1 &= ~(0b1 << 4);
    P2->OUT = 0x00;
}

void initInterrupts(void){

    NVIC_EnableIRQ(TA0_N_IRQn);         // IRQ handler
    NVIC_SetPriority(TA0_N_IRQn,2);     // priority
    TIMER_A0->CTL |= TIMER_A_CTL_IE;    // Interrupt enable
    NVIC_EnableIRQ(ADC14_IRQn);         // IRQ handler
    NVIC_SetPriority(ADC14_IRQn,0);     // priority
    ADC14->IER0 |= ADC14_IER0_IE0;      //ADC register 0 Interrupt
}

void initADC(void){

    P4->SEL0 |= 0b1;
    P4->SEL1 |= 0b1; // sets p4.0 as A13


    ADC14->CTL0 |= ADC14_CTL0_SSEL_2;       //select ACLK
    ADC14->CTL0 |= ADC14_CTL0_SHP;          //sample and hold mode
    ADC14->CTL0 |= ADC14_CTL0_SHS_0;        //SC mode
    ADC14->CTL1 |= ADC14_CTL1_RES_3;        //16 clock conversion time
    ADC14->CTL1 |= ADC14_CTL1_RES__14BIT;   //14bit resolution
    ADC14->CTL0 |= ADC14_CTL0_ON;           //enables the ADC
    ADC14->MCTL[0] |= ADC14_MCTLN_INCH_13;
    ADC14->CTL0 |= ADC14_CTL0_ENC;
}

void delay(int time) {

    TIMER_A0->CTL &= ~TIMER_A_CTL_IFG;  //reset interrupt flag
    TIMER_A0->CTL |= TIMER_A_CTL_CLR;   // clear timer A
    TIMER_A0->CCR[0] = 64 * time;       // fill compare register

    while((TIMER_A0->CTL & TIMER_A_CTL_IFG) == 0) ;
    TIMER_A0->CCR[0] = 0;               // stop timer
}

void TA0_N_IRQHandler(void) {

    TIMER_A0->CTL &= ~TIMER_A_CTL_IFG;                  // reset interrupt flag

    ADC14->CTL0 |= ADC14_CTL0_SC | ADC14_CTL0_ENC;      //start and enable conversion


}

void ADC14_IRQHandler(void) {


    resultat = (uint16_t)ADC14->MEM[0];
    TIMER_A0->CCR[1] = 16 + (resultat >> 10) ; // 1ms + 0-1 ms depending on the adc


}
