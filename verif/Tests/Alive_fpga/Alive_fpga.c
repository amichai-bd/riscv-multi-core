/*MultiThread.c
calculate 4 different arithmatic calculations one on each thread
test owner: Saar Kadosh
Created : 22/08/2021
*/
// 4KB of D_MEM
// 0x400800 - 0x400fff - Shared
//
// 0x400600 - 0x400800 - Thread 3
// 0x400400 - 0x400600 - Thread 2
// 0x400200 - 0x400400 - Thread 1
// 0x400000 - 0x400200 - Thread 0

// REGION == 2'b01;
#include "LOTR_defines.h"

int main() {
    int ThreadId = CR_THREAD[0];
    int UniqeId = CR_WHO_AM_I[0];
    int counter = 0 ;
    switch (UniqeId) //the CR Address
    {
        case 0x4 : // parameterize 
         
            while (1){
                LED_FGPA[0] = counter;
                counter ++;
              //  if (counter == 1024) counter = 0;               //Writing to fpga
            }
                // while(counter++ < 10){};          // busy wait until data arrived from Core1

                // SHARED_SPACE[0] = SEG0_FGPA[0];    //Reading from fpga 
                //while(1);    
        break;
        default :
                while(1); 
                break;
       
    }   
    
    return 0;

}

