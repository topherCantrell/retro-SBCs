
# 6809 Board

I am using the basics from here: [https://easyeda.com/tranter/6809-Single-Board-Computer](https://easyeda.com/tranter/6809-Single-Board-Computer)

## 68B09CP Processor

I bought a chip on ebay.

The 68B09 does not require an external clock driver -- just a crystal.

CP seems to mean "plastic" and "industrial temp range".

MOTOS07600-1.pdf says "The crystal or external frequency is four times the bus frequency. 8MHz crystal would be 2MHz. I am
using 7.3728MHz resulting in 1.8432Mhz. 

Note that 7372800 / 4 / 16 = 115200. This lets us use the same clock for the UART chip.

## Datasheets and Pinouts

  - [MC6809.pdf](MC6809.pdf)
  - [MC6850.pdf](MC6850.pdf)
  - [MC6821.pdf](MC6821.pdf)
  - [datasheet_27C256.pdf](datasheet_27C256.pdf)
  - [62256_Samsungsemiconductor.pdf](62256_Samsungsemiconductor.pdf)

![](media/pinouts.jpg)

## Circuit

![](media/CPU.jpg)

![](media/ROMRAM.jpg)

![](media/IO.jpg)

## Wire Warp IDs

![](media/wirewrap.jpg)
