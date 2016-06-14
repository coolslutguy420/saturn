@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@                                                                           @@
@@    %%    %% %%%%%%%% %%%%%%%%  %%    %%   %%%%%%   %%%%%%%%     %%%       @@
@@    %%   %%  %%       %%     %% %%%   %%  %%    %%  %%     %%   %% %%      @@
@@    %%  %%   %%       %%     %% %%%%  %%  %%        %%     %%  %%   %%     @@
@@    %%%%%    %%%%%%   %%%%%%%%  %% %% %%  %%   %%%% %%%%%%%%  %%     %%    @@
@@    %%  %%   %%       %%   %%   %%  %%%%  %%    %%  %%     %% %%%%%%%%%    @@
@@    %%   %%  %%       %%    %%  %%   %%%  %%    %%  %%     %% %%     %%    @@
@@    %%    %% %%%%%%%% %%     %% %%    %%   %%%%%%   %%%%%%%%  %%     %%    @@
@@                                                                           @@
@@                                  KernGBA                                  @@
@@                 A minimal kernel for the Game Boy Advance                 @@
@@                                                                           @@
@@                       Copyright © 2016  Nicholatian                       @@
@@                                                                           @@
@@  Licensed under the Apache License, Version 2.0 (the “License”); you may  @@
@@ not use this file except in compliance with the License. You may obtain a @@
@@                          copy of the  License at                          @@
@@                                                                           @@
@@                http://www.apache.org/licenses/LICENSE-2.0                 @@
@@                                                                           @@
@@    Unless required by applicable law or agreed to in writing, software    @@
@@ distributed under the License is distributed on an “AS IS” BASIS, WITHOUT @@
@@ WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the  @@
@@  License for the specific language governing permissions and limitations  @@
@@                            under the  License.                            @@
@@                                                                           @@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.file "src/init/boot.s"
.ident "AS: (devkitARM release 45) 2.25.1"

@@
@@ ROM jump opcode
@@

.globl j_rom_start
.balign 4
.arm

j_rom_start:
    
    B       rom_start

@@
@@ ROM header information
@@ - This is MANDATORY for all ROMs on hardware!
@@

@ Nintendo logo/character data (8000004h)
.byte 0x24, 0xFF, 0xAE, 0x51, 0x69, 0x9A, 0xA2, 0x21, 0x3D, 0x84
.byte 0x82, 0x0A, 0x84, 0xE4, 0x09, 0xAD, 0x11, 0x24, 0x8B, 0x98
.byte 0xC0, 0x81, 0x7F, 0x21, 0xA3, 0x52, 0xBE, 0x19, 0x93, 0x09
.byte 0xCE, 0x20, 0x10, 0x46, 0x4A, 0x4A, 0xF8, 0x27, 0x31, 0xEC
.byte 0x58, 0xC7, 0xE8, 0x33, 0x82, 0xE3, 0xCE, 0xBF, 0x85, 0xF4
.byte 0xDF, 0x94, 0xCE, 0x4B, 0x09, 0xC1, 0x94, 0x56, 0x8A, 0xC0
.byte 0x13, 0x72, 0xA7, 0xFC, 0x9F, 0x84, 0x4D, 0x73, 0xA3, 0xCA
.byte 0x9A, 0x61, 0x58, 0x97, 0xA3, 0x27, 0xFC, 0x03, 0x98, 0x76
.byte 0x23, 0x1D, 0xC7, 0x61, 0x03, 0x04, 0xAE, 0x56, 0xBF, 0x38
.byte 0x84, 0x00, 0x40, 0xA7, 0x0E, 0xFD, 0xFF, 0x52, 0xFE, 0x03
.byte 0x6F, 0x95, 0x30, 0xF1, 0x97, 0xFB, 0xC0, 0x85, 0x60, 0xD6
.byte 0x80, 0x25, 0xA9, 0x63, 0xBE, 0x03, 0x01, 0x4E, 0x38, 0xE2
.byte 0xF9, 0xA2, 0x34, 0xFF, 0xBB, 0x3E, 0x03, 0x44, 0x78, 0x00
.byte 0x90, 0xCB, 0x88, 0x11, 0x3A, 0x94, 0x65, 0xC0, 0x7C, 0x63
.byte 0x87, 0xF0, 0x3C, 0xAF, 0xD6, 0x25, 0xE4, 0x8B, 0x38, 0x0A
.byte 0xAC, 0x72, 0x21, 0xD4, 0xF8, 0x07

@ Game Title (80000A0h)
.ascii "KERNEL GBA\0"

@ Game code (80000ACh)
.ascii "CKGE"

@ Maker code (80000B0h)
.ascii "8J"

@ Fixed value (80000B2h)
.byte 0x96

@ Main unit code (80000B3h)
.byte 0x00

@ Device type (80000B4h)
.byte 0x00

@ Reserved area (0 Fixed | 7Byte) (80000B5h)
.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

@ Software version No (80000BCh)
.byte 0x00

@ Complement check (80000BDh)
.byte 0xA6

@ Reserved area (0 Fixed | 2Byte) (80000BEh)
.byte 0x00, 0x00

@@
@@ ROM startup routine
@@

.globl rom_start
.balign 4
.arm

rom_start:
    
    MOV     R0, #0x12               @ Switch to IRQ Mode
    MSR     CPSR, R0
    MOV     R0, #0x1F               @ Switch to System Mode
    MSR     CPSR, R0
    LDR     R1, =0x3007FFC          @ Set IRQ Handler Address (32-bit ARM mode)
    ADR     R0, irq_handler
    STR     R0, [R1]
    LDR     R1, =main               @ Start & Switch to 16bit Code
    MOV     LR, PC
    BX      R1
    B       rom_start               @ Reset

@@
@@ Interrupt Branch Process (Table Lookup) 32Bit        25-60c-
@@

.globl irq_handler
.align
.arm

irq_handler:
    
    BX      LR
