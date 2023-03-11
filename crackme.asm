.286
model tiny 
.code 

locals @@

org 100h


ENCRYPT_KEY equ 23d

ENCRYPT_MOD equ 123d

SYSTEM_CHAR equ 1Fh

include src/genmac.asm

Start:


    call EnterPassword

    call Initialization

    call CheckPassword

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

        cmp changeTrue, 0h
        je @@uncorrupted
            mov byte ptr fictionTrue, cl ;def 'TRUE'
            jmp @@endif
        @@uncorrupted:
            mov byte ptr fictionTrue, TRUE
        @@endif:

        ret
    Initialization endp 
    
    ;------------------------------------------------------------------
    ;encrypts the symbol
    ;------------------------------------------------------------------
    ;Entry:   cl - encryption key, al - input symbol
    ;Exit:    al - encrypt symbol
    ;Destroy: ax, dh, si, es, df
    ;------------------------------------------------------------------
    EncryptSymbol proc

        add al, cl  ;encrypt symbol
            
        xor ah, ah  ;---------------

        mov dh, ENCRYPT_MOD
        div dh              ;get al mod ENCRYPT_MOD      
        
        add ah, SYSTEM_CHAR ;skip omission of non-printable characters
        mov al, ah          ;new symbol

        ret
    EncryptSymbol endp 

    ;------------------------------------------------------------------
    ;enter password
    ;------------------------------------------------------------------
    ;Entry:   none
    ;Exit:    curPassword
    ;Destroy: ah, al, di
    ;------------------------------------------------------------------
    EnterPassword proc

        mov di, ds
        mov es, di ;xchange ds, es

        mov di, offset curPassword

        mov ah, 01h  ;set 21 interrupts to read keystrokes
        @@next:
            
            int 21h    ;read keyboard button
            stosb
        
        cmp al, ASCII_CODE_ENTER 
        jne @@next

        dec di
        mov byte ptr ds:[di], TERM_SYM

        ret
    EnterPassword endp

    ;------------------------------------------------------------------
    ;get string's hash
    ;------------------------------------------------------------------
    ;Assumes: string ends with a terminate symbol, ds - desired segment
    ;Entry:   si - string addres
    ;Exit:    ax - string's hash
    ;Destroy: ah, al, di
    ;------------------------------------------------------------------
    GetHash proc

        xor bx, bx  ;free bx
        xor ax, ax  ;free ax
        @@next:
            
            mov bx, HASH_PW
            mul bx              ;mul cur hash by HASH_PW

            mov bl, byte ptr ds:[si]    ;get cur symbol
            add al, bl

            inc si ;si++
        
        cmp byte ptr ds:[si + 1h], ASCII_CODE_ENTER 
        jne @@next


        ret
    GetHash endp

    ;------------------------------------------------------------------
    ;check input password
    ;------------------------------------------------------------------
    ;Entry:   none
    ;Exit:    flagWrongPassword
    ;Destroy: ax, di, si, es, df
    ;Local var: [bp - 2] - original password length
    ;------------------------------------------------------------------
    CheckPassword proc
        push bp             
        mov  bp, sp         
        sub  sp, 2d * 1d    ;1 local variable
    
        mov di, offset Password  ;set addres
        call Strlen

        mov word ptr [bp - 2], bx   ;save original password length

        mov flagWrongPassword, FALSE

        cld                         ;df = 0
        mov si, offset CurPassword  ;di = addres curPasswi=ord
        xor di, di                  ;free counter

        mov cl, ENCRYPT_KEY

        @@next:
            lodsb

            cmp al, TERM_SYM 
            je @@break

            call EncryptSymbol

            cmp al, byte ptr Password[di] ;check curPassword symbol with original Password symbol 
            je @@isEqual
                mov al, byte ptr fictionTrue
                mov flagWrongPassword, al
            @@isEqual:

            inc di  ;di++

        jmp @@next

        @@break:

        sub si, offset curPassword + 1h  ;get corret length read password
        
        
        cmp si, word ptr [bp - 2]   ;check curren length password
        je @@curLenIscorrect
            mov al, byte ptr fictionTrue
            mov flagWrongPassword, al
        @@curLenIscorrect:

        mov sp, bp
        pop bp
        ret
    CheckPassword endp 

    ;------------------------------------------------------------------
    ;print verdict afrter read pasword
    ;------------------------------------------------------------------
    ;Entry:   none
    ;Exit:    none
    ;Destroy: ah, di, si, es
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

pspJump dw 00h

fictionTrue db 0

Password db 7dh, 2ah, 2ah, 1fh, 56h, 27h, 30h, 99h, 26h, 57h, 71h, 5fh, 6eh, TERM_SYM

MessageSuccess db "SUCCESS", TERM_SYM
MessageFailure db "FAILURE", TERM_SYM

CurPassword db 20 dup (?)

changeTrue db 0

end Start

