#include <stdint.h>   /* Declarations of uint_32 and the like */
#include <pic32mx.h>  /* Declarations of system-specific addresses etc */
#include "mipslab.h"  /* Declatations for these labs */
#include <stdlib.h>		/* rand and srand */

unsigned int flash_unlock(unsigned int nvmop);
unsigned int flash_Write_Word(void* score_location, unsigned int data);
void flash_Write();

// Flash memory 2 Program Flash KSEG1
//Highest Address (virtual) 0xBD007FFF
//Lowest Address (virtual) 0xBD000000
/*
	Translate virtual address into physcial address
	Physical Address = Virtual Address & 0x1FFFFFFF
	Translate physical address into virtual address 
	KSEG1 Virtual Address = Physical Address | 0xA0000000
*/


void flash_Write(){
	int* score_virtual_location = 0xBD000000;
	int score_virtual_location_address = score_virtual_location;
	display_debug(score_virtual_location_address);
	int* score_physical_location = (score_virtual_location_address  & 0x1FFFFFFF);
	unsigned int score = 0; 
	flash_Write_Word(score_physical_location, score); 
	
	quicksleep(80000000);
	display_debug(score_virtual_location);

} 




unsigned int flash_Write_Word(void* score_location, unsigned int data) //Physical address 
{
	unsigned int result; 
	//Load data that is to be writtten 
	NVMDATA = data; 
	//Load address
	NVMADDR = (unsigned int) score_location;

	//Unlock flash and write 
	result = flash_unlock (0x4001);
	//Return if write was succesful 
	return result;


}


unsigned int flash_unlock(unsigned int nvmop){
	unsigned int status;
	//Suspend/disable all interrupts 
	asm volatile ("di %0" : "=r" (status));

	
	NVMCON = nvmop;
	quicksleep(8000);
	//Write to enable programming/erase sequence 
	NVMKEY = 0xAA996655;
	NVMKEY = 0x556699AA;
	//Begin operation 
	NVMCONSET = 0x8000;
	//Wait for write control bit to be cleared = operation is complete 
	while (NVMCON & 0x8000); 

	// Restore interrupts 
	if (status & 0x00000001)
	{
	asm volatile ("ei");
	}
	else{
	asm volatile ("di");
	}
	
	// Disable write enable 
	NVMCONCLR = 0x4000;

	// Return bits to show if there was an write or low voltage error 
	return (NVMCON & 0x3000);


}


