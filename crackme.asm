.286
model tiny 
.code 

org 100h
locals @@

include src/genmac.asm

Start:

    call EnterPassword

    call PrintVerdict

    Exit 0

    ;------------------------------------------------------------------
    ;password input
    ;------------------------------------------------------------------
    ;Entry:   none
    ;Exit:    flagWrongPassword
    ;Destroy: ax, cx, dh, di, si, es, df
    ;Local var: [bp - 2] - original password length
    ;------------------------------------------------------------------
    EnterPassword proc

        push bp             
        mov  bp, sp         
        sub  sp, 2d * 1d    ;1 local variable

        mov di, ds 
        mov es, di          ;set correct segment    

        mov di, offset Password  ;set addres

        call Strlen
        mov word ptr [bp - 2], bx   ;save original password length

        mov ah, 02h     ;---------------
        int 1ah         ;get system time 
        TRUE equ cl     ;Define 'TRUE'

        mov flagWrongPassword, FALSE

        cld                      ;df = 0
        mov di, offset Password  ;free counter
        mov ah, 01h              ;set 21 interrupts to read keystrokes
        @@next:
            int 21h    ;read keyboard button

            cmp al, ASCII_CODE_ENTER 
            je @@break

            scasb ;byte ptr Password[si] ;check cur symbol with symbol 
            je @@isEqual
                mov flagWrongPassword, TRUE
            @@isEqual:

        jmp @@next

        @@break:

        sub di, offset Password     ;get corret length read password
        
        cmp di, word ptr [bp - 2]   ;check curren length password
        je @@curLenIscorrect
           mov flagWrongPassword, TRUE
        @@curLenIscorrect:


        mov sp, bp
        pop bp
        ret
    EnterPassword endp 

    ;------------------------------------------------------------------
    ;print verdict afrter read pasword
    ;------------------------------------------------------------------
    ;Entry:   none
    ;Exit:    none
    ;Destroy: di, si, es
    ;------------------------------------------------------------------
    PrintVerdict proc

        cmp flagWrongPassword, FALSE
        jne @@wrongPassword
            mov si, offset MessageSuccess
            mov ah, GREEN_ON_BLACK_COL

            jmp @@endIf
        @@wrongPassword:
            
            mov si, offset MessageFailure
            mov ah, RED_ON_BLACK_COL

        @@endIf:

        mov di, VIDMEM_MIDL_ADDRESS * 2d

        call StrPrintToVidmem

        ret
    PrintVerdict endp 

    include src/STRFNC.ASM

.data

flagWrongPassword db FALSE



.const
MessageSuccess db "SUCCESS", TERM_SYM
MessageFailure db "FAILURE", TERM_SYM

Password db "Good luck!", TERM_SYM

end Start

