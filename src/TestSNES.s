.include "libSFX.i"
.export _MainASM

;VRAM destination addresses
VRAM_MAP_LOC     = $0000
VRAM_TILES_LOC   = $8000
OAM_SHADOW_LOC	 = $0050

X_COORD			 = $00
Y_COORD			 = $01
X_DIR			 = $02
Y_DIR			 = $03

; 170x80
WIDTH			 = 170
HEIGHT			 = 176;80

Main:
	jmp _MainC

_MainASM:

        ;libSFX calls Main after CPU/PPU registers, memory and interrupt handlers are initialized.

        ;Set color 0
        CGRAM_setcolor_rgb 0, 255,0,0

	;	OAM_init OAM_SHADOW_LOC, 0, 0, 0

		;OAM_memcpy OAM_SHADOW_LOC

		;Decompress graphics and upload to VRAM
		LZ4_decompress INTechMap, EXRAM, y
		VRAM_memcpy VRAM_MAP_LOC, EXRAM, y

		LZ4_decompress INTechTiles, EXRAM, y
		VRAM_memcpy VRAM_TILES_LOC, EXRAM, y
        CGRAM_memcpy 0, INTechPalette, sizeof_INTechPalette

        ;Set up screen mode
	  	lda     #bgmode(BG_MODE_1, BG3_PRIO_NORMAL, BG_SIZE_8X8, BG_SIZE_8X8, BG_SIZE_8X8, BG_SIZE_8X8)
		sta     BGMODE
		lda     #bgsc(VRAM_MAP_LOC, SC_SIZE_32X32)
		sta     BG1SC
		ldx     #bgnba(VRAM_TILES_LOC, 0, 0, 0)
		stx     BG12NBA
		lda     #tm(ON, OFF, OFF, OFF, OFF)
		sta     TM

		;Turn on screen
		lda     #inidisp(ON, DISP_BRIGHTNESS_MAX)
       	sta SFX_inidisp

        ;Turn on vblank interrupt
        VBL_on

; X of logo
		lda 	#250
		sta 	X_COORD
; Y of logo
		lda 	#210
		sta 	Y_COORD
Loop:
		jsr 	Move

		; Set scrolling
		lda		X_COORD
		adc		#38
		sta		BG1HOFS
		lda		#00
		sta		BG1HOFS

		lda		Y_COORD
		adc		#83
		sta		BG1VOFS
		lda		#00
		sta		BG1VOFS

		wai
		wai
        bra 	Loop

Move:
		lda		Y_COORD
		cmp		#255
		bpl 	GoUpY
		lda		Y_COORD
		cmp		#00
		bpl 	GoDownY

		jmp		MoveY

GoUpY:
		lda		#00
		sta		Y_DIR
		jmp 	MoveY
GoDownY:
		lda		#01
		sta		Y_DIR
		jmp 	MoveY

MoveY:
		lda 	Y_DIR
		cmp		#01 ; go up
		bpl 	up
		dec		Y_COORD
		jmp 	MoveX
up:
		inc		Y_COORD

MoveX:
		lda		X_COORD
		cmp		#250
		bpl 	GoUpX
		lda		X_COORD
		cmp		#50
		bpl 	GoDownX

		jmp		ActualMoveX

GoUpX:
		lda		#00
		sta		X_DIR
		jmp 	ActualMoveX
GoDownX:
		lda		#01
		sta		X_DIR

ActualMoveX:
		lda 	X_DIR
		cmp		#01 ; go up
		bpl 	right
		dec		X_COORD
		rts
right:
		inc		X_COORD


		rts

; Import graphics
.segment "RODATA"
		incbin  INTechPalette, "src/assets/intech.png.palette"
		incbin  INTechTiles, "src/assets/intech.png.tiles.lz4"
		incbin 	INTechMap, "src/assets/intech.png.map.lz4"
