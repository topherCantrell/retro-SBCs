# Old Engineers

Old engineers love telling you stories about their first computers and how limited technology was back in "the old days". 

If you've never heard one reliving the glory days, I'll give you an example -- my own.

I cut
my electronics teeth in the early 80s with kits like the 100-in-1 spring board kit from Radio Shack. These kits featured a couple dozen
components like resistors, capacitors, switches, and transistors. These were mounted to a board (often cardboard) with their
leads connected to springs on the board. The manual showed you how to connect wires between the springs to make amazing little
analog circuits to blink a light or make a tone. Inevitably, the kits came with a button to control play the tone and a Morse code table. 
Remember, Radio Shack began as a supply store for ham radio enthusiasts -- thus the name of the company.

For digital electronics, Radio Shack offered the Forrest Mimms Engineer's Notebooks. Each books was chock-full of IC circuits you
could build on a solderless breadboard by pressing in chips, components, and wires. It was here somewhere around 10th grade that I 
learned the ANDs and ORs of IC logic gates. It was here that I learned binary counters and 7-segment display drivers.

Radio Shack was filled with eye candy in those days. Breadboard, resistors, capacitors, and switches. LEDs and wires. All the
electronics supplies you would ever need. We spent hours browsing racks of 7400 series chips in clear blister packs. There is the 74138 3-to-8 
line decoder -- what does it do? Look at that fat datasheet folded up in the package. Oh, readers; that's where we spent our allowances. And 
don't forget to use your battery-of-the-month-club card to get a free 9V battery on the way out.

Not surprisingly, the Radio Shack TRS80 Color Computer was my first computer. It used a TV for a monitor, and I saved my BASIC programs on
cassette tape (you've heard all those horror stories). The right side of the computer had a huge slot for expansion cartridges. Nearly
all these cartridges were ROM packs with games, and there were some fun games. But I was not much of a player. For me making the game
was the real game. I was a programmer.

From 1983 to 1986, there was a monthly magazine called Hot CoCo filled with information, projects, and programs you could type in from
the glossy pages. In July of 1984, a five-part series began in the magazine that would pave the way to my future. The series was call 
"ROM Hacker", and it began with building a "master interface" that plugged into the Color Computer's expansion port and allowed a program 
to control digital input/outputs. Suddenly my love of electronics and my love of programming merged into a single hobby and a life long career.

>> PCB kit, etching, stains
>> No scanners or printers. transfered the circuit with a pen
>> Ordered the parts with a check or money order and waited
>> TRS80 Technical Reference. Saw the PIAs at work
>> AY38910 -- cartridge and a chip in blister pack. more on this with the 8051 board


# The CoCo days

  - [July 1984](https://colorcomputerarchive.com/repo/Documents/Magazines/Hot%20CoCo%20(Searchable%20image)/Hot%20Coco%20Vol.%202%20No.%202%20-%20July%201984.pdf) #1 Building the PIA
  - [August 1984](https://colorcomputerarchive.com/repo/Documents/Magazines/Hot%20CoCo%20(Searchable%20image)/Hot%20Coco%20Vol.%202%20No.%203%20-%20August%201984.pdf) #2 IC Tester
  - [October 1984](https://colorcomputerarchive.com/repo/Documents/Magazines/Hot%20CoCo%20(Searchable%20image)/Hot%20Coco%20Vol.%202%20No.%205%20-%20October%201984.pdf) #3 Logo turtle
  - [January 1985](https://colorcomputerarchive.com/repo/Documents/Magazines/Hot%20CoCo%20(Searchable%20image)/Hot%20Coco%20Vol.%202%20No.%208%20-%20January%201985.pdf) #4 Armatron
  - [February 1985](https://colorcomputerarchive.com/repo/Documents/Magazines/Hot%20CoCo%20(Searchable%20image)/Hot%20Coco%20Vol.%202%20No.%209%20-%20February%201985.pdf) #5 Armatron 

This is when I really got into hardware/software. The AY38910 hooked up to the PIA. I think. It was so long ago.

March of 1986 is when Hot CoCo joined 80 Micro magazine and my article "Coco Zoo" appeared. In June of 86 80 Micro purchased my article/code "DOS Commander", but the magazine dropped Hot Coco before the article published.

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
