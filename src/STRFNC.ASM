;.model tiny
;.code
;org 100h

;locals @@

public StrPrintToVidmem
public Strchr, Strcpy, Strcmp, Strlen
public Memchr, Memcpy, Memcmp, Memset

;include genmac.asm

;-----------------------------------------------------------------
;prints a string to V
;-----------------------------------------------------------------
;Assumes: String must end with a terminating character
;Assumes: ds - source segment
;Entry: ah - string's colour  di - destination address, si - source address 
;Exit: none
;Destroy: al dx, si, di, es - vidmem segment, df
;-----------------------------------------------------------------
StrPrintToVidmem proc
    
    mov dx, VIDMEM_SEGMENT  ;-----------------
    mov es, dx              ;set vidmem segment
    
    cld      ;setting the df flag to zero 
    
    @@next:
        
        lodsb       ;get al
        stosw       ;print to vidmem symbol

    cmp byte ptr ds:[si], TERM_SYM   ;if cur symbol is TERM_SYM
    jne @@next

    ret
StrPrintToVidmem endp

;-----------------------------------------------------------------
;calculate the length of a string
;-----------------------------------------------------------------
;Assumes: es - corect segment
;Entry: di (input string address)
;Exit: bx (len)
;Destroy: di, al, df
;-----------------------------------------------------------------
Strlen proc
    cld      ;setting the df flag to zero 
    
    mov al, TERM_SYM ;set al terminate symbol
    
    @@next:
        inc bx  ;length++
        scasb   ;check current symbol
    jne @@next
    
    dec bx      ;terminate symbol not included in string length

    ret
Strlen endp

;-----------------------------------------------------------------
;find addres first given symbol in n sumbols
;-----------------------------------------------------------------
;Param: [bp + 4] - counter
;Entry: al (input symbol)
;Exit: di (FFFFh - if there is no symbol, another address symbol)
;Destroy: di, cx, df
;-----------------------------------------------------------------
Memchr proc
    push bp    ;save bp value to stack
    mov bp, sp ;save bp value to bp

    cld ;setting the df flag to zero 

    mov cx, word ptr [bp + 4] ;counter coppy

    repne scasb     ;compare string's symbol with given symbol
    je @@goToRet
    
    xor di, di ;don't find symbol

@@goToRet:
    dec di      ;decrease address

    pop bp      ;recover bp value
    ret 2d * 1d ;free stack
Memchr endp

;-----------------------------------------------------------------
;copy n symbols from src to dst string
;----------------------------------------------------------------- 
;Param: [bp+4] - counter
;Entry: di, si
;Exit: di
;Destroy: di, si, cx, df
;-----------------------------------------------------------------
Memcpy proc
    push bp    ;save bp value to stack
    mov bp, sp ;save bp value to bp

    cld ;setting the df flag to zero 

    mov cx, word ptr [bp + 4] ;counter coppy
    rep movsb                 ;coppy


@@goToRet:
    sub di, [bp + 4]            ;return value

    pop bp      ;recover bp value
    ret 2d * 1d ;free stack
Memcpy endp

;-----------------------------------------------------------------
;string comparison by first n symbols
;----------------------------------------------------------------- 
;Param: [bp+4] - counter
;Entry: di, si
;Exit: cl
;Destroy: di, si, cx, df
;-----------------------------------------------------------------
Memcmp proc
    push bp    ;save bp value to stack
    mov bp, sp ;save bp value to bp

    cld ;setting the df flag to zero 

    mov cx, word ptr [bp + 4] ;counter coppy

    repe cmpsb ;compare strings
    
    dec si 
    dec di     

    mov cl, byte ptr ds:[si] ;------------------
    sub cl, byte ptr es:[di] ;compare last symbol

    pop bp      ;recover bp value
    ret 2d * 1d
Memcmp endp

;-----------------------------------------------------------------
;set n symbols to dst 
;----------------------------------------------------------------- 
;Param: [bp + 4] - counter
;Entry: al (input char), di
;Exit: di 
;Destroy: di
;-----------------------------------------------------------------
Memset proc
    push bp    ;save bp value to stack
    mov bp, sp ;save bp value to bp

    cld ;setting the df flag to zero 

    mov cx, word ptr [bp + 4] ;counter coppy

    rep stosb

    sub di, word ptr [bp + 4] ;return start addres

    pop bp  ;recover bp value
    ret 2d * 1d
Memset endp

;-----------------------------------------------------------------
;find addres first symbol
;-----------------------------------------------------------------
;Assumes: line ends with a terminate symbol
;Entry: al (input symbol)
;Exit: di 
;Destroy: di, df
;-----------------------------------------------------------------
Strchr proc
    
    cld      ;setting the df flag to zero 
    
    @@next:
        scasb       ;check current symbol
        je @@break  ;if find given symbol

        cmp byte ptr es:[di], TERM_SYM ;check is terminate symbol
    jne @@next
    
    xor di, di ;don't find symbol

@@break:
    dec di  ;decrease address

    ret 
Strchr endp

;-----------------------------------------------------------------
;string comparison
;----------------------------------------------------------------- 
;Assumes: line ends with a terminate symbol
;Entry: di, si
;Exit: cl
;Destroy: di, si, df
;-----------------------------------------------------------------
Strcmp proc

    cld ;setting the df flag to zero 

    @@next:
        cmpsb ;compare strings
        jne @@break

    cmp byte ptr es:[di], TERM_SYM ;check is terminate symbol
    jne @@next

@@break:
    dec si 
    dec di     

    mov cl, byte ptr ds:[si] ;------------------
    sub cl, byte ptr es:[di] ;compare last symbol

    ret
Strcmp endp


;-----------------------------------------------------------------
;copy from src to dst string
;-----------------------------------------------------------------
;Assumes: line ends with a terminate symbol
;Entry: di, si
;Exit: di
;Destroy: di, si, cx, df
;-----------------------------------------------------------------
Strcpy proc

    cld ;setting the df flag to zero 

    push di     ;save to stack start string addres

    @@next:
        movsb  ;coppy to dst from src

        cmp byte ptr ds:[si], TERM_SYM ;check is terminate symbol
    jne @@next 

    mov byte ptr es:[di], TERM_SYM

    pop di ;recover di from stack
    
    ret 
Strcpy endp
