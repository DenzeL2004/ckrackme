VIDMEM_SEGMENT equ 0b800h

;Vidmem colours

GREEN_ON_BLACK_COL equ 0ah ;green clour on black background 
RED_ON_BLACK_COL   equ 0ch ;red   clour on black background 

;-----------------------------------------------------------

TERM_SYM equ '$'


VIDMEM_MIDL_ADDRESS equ 80d * 12d + 40d


;Keyboard Scan Codes

SCAN_CODE_ENTER  equ 028d
ASCII_CODE_ENTER equ 0dh

;------------------------------------------------------------

;Bool val
;TRUE  equ 0FFh
FALSE equ 0h

;-----------------------------------------------------------------
;Exit
;-----------------------------------------------------------------
;Entrt: nope
;Exit: N/A
;Destroy: N/A
;-----------------------------------------------------------------

Exit	macro code

		mov ax, 4c00h or code
		int 21h		

		endm

;-----------------------------------------------------------------