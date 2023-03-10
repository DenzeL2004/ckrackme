.286
model tiny 
.code 

org 100h
locals @@

TRUE equ byte ptr trueVal

include src/genmac.asm

Start:

    call Initialization

    call EnterPassword

    call PrintVerdict

    Exit 0

    ;------------------------------------------------------------------
    ;Initialization
    ;------------------------------------------------------------------
    ;Entry:   none
    ;Exit:    none
    ;Destroy: ax, cx, dh
    ;------------------------------------------------------------------
    Initialization proc

        mov ah, 02h                 ;---------------
        int 1ah                     ;get system time

        or  cl, 1h                  ;can't be zero
        mov byte ptr trueVal, cl    ;def 'TRUE'

        mov byte ptr dubTrueVal, cl ;make dublicate 'TRUE' value

        call EncryptPassword

        ret
    Initialization endp 

    ;------------------------------------------------------------------
    ;password input
    ;------------------------------------------------------------------
    ;Entry:   none
    ;Exit:    flagWrongPassword
    ;Destroy: ax, di, si, es, df
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
                mov al, TRUE
                mov flagWrongPassword, al
            @@isEqual:

        jmp @@next

        @@break:

        sub di, offset Password     ;get corret length read password
        
        cmp di, word ptr [bp - 2]   ;check curren length password
        je @@curLenIscorrect
            mov al, TRUE
            mov flagWrongPassword, al
        @@curLenIscorrect:

        mov sp, bp
        pop bp
        ret
    EnterPassword endp 

    ;------------------------------------------------------------------
    ;password input
    ;------------------------------------------------------------------
    ;Entry:   none
    ;Exit:    flagWrongPassword
    ;Destroy: ax, di, si, es, df
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
                mov al, TRUE
                mov flagWrongPassword, al
            @@isEqual:

        jmp @@next

        @@break:

        sub di, offset Password     ;get corret length read password
        
        cmp di, word ptr [bp - 2]   ;check curren length password
        je @@curLenIscorrect
            mov al, TRUE
            mov flagWrongPassword, al
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
    ;Destroy: ah, di, si, es
    ;------------------------------------------------------------------
    PrintVerdict proc

        mov ah, dubTrueVal
        cmp ah, TRUE        ;checking that no changes 'TRUE' have taken place
        jne @@wrongPassword

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

trueVal     db 0
dubTrueVal  db 0

Password db "Good luck!", TERM_SYM

.const
MessageSuccess db "SUCCESS", TERM_SYM
MessageFailure db "FAILURE", TERM_SYM

end Start

