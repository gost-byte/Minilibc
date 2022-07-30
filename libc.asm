BITS 64
GLOBAL strchr
GLOBAL strrchr
GLOBAL strlen
GLOBAL memset
GLOBAL memcpy
GLOBAL memmove
GLOBAL strcmp
GLOBAL strncmp
GLOBAL strcasecmp
GLOBAL strstr
GLOBAL strpbrk
GLOBAL strcspn
GLOBAL index
GLOBAL rindex
GLOBAL ffs
GLOBAL memfrob
GLOBAL syscall
SECTION .text

strlen:
    mov rcx, 0

loop_strlen:
    cmp rdi, 0
    je end_strlen
    cmp BYTE [rdi], 0
    je end_strlen
    add rdi, 1
    add rcx, 1
    jmp loop_strlen

end_strlen:
    mov rax, rcx
    ret


index:
strchr:
    xor rax,rax
    xor r8, r8
    mov r8, rdi

strchr_loop:
    cmp BYTE [r8], sil
    je strchr_find
    cmp BYTE [r8], 0
    je strchr_end
    add r8, 1
    jmp strchr_loop

strchr_find:
    mov rax, r8

strchr_end:
    ret


rindex:
strrchr:
    xor rcx, rcx
    mov rax, 0
    cmp rdi, 0
    je strrchr_null

strrchr_loop_strlen:
    cmp BYTE [rdi + rcx], 0
    je strrchr_loop
    add rcx, 1
    jmp strrchr_loop_strlen

strrchr_loop:
    cmp rcx, 0
    jl strrchr_null
    cmp BYTE [rdi + rcx], sil
    je strrchr_end
    dec rcx
    jmp strrchr_loop

strrchr_null:
    ret

strrchr_end:
    add rdi, rcx
    mov rax, rdi
    ret



memset:
    xor RCX,RCX
    cmp RDI, 0
    je memset_end

memset_loop:
    cmp RDX, RCX
    je memset_end
    mov BYTE [RDI + RCX], SIL
    inc RCX
    jmp memset_loop

memset_end:
    mov RAX, RDI
    ret



memcpy:
    xor RCX,RCX
    xor r8, r8
    xor rax, rax
    cmp RSI, 0
    je memset_end

memcpy_loop:
    cmp RDX, RCX
    je memset_end
    mov r8b, [RSI]
    mov BYTE [RDI + RCX], r8b
    inc RSI
    inc RCX
    jmp memcpy_loop

memcpy_end:
    mov RAX, RDI
    ret



memmove:
    xor RCX,RCX
    mov rax, rdi
    cmp RDI, RSI
    je memcpy_end
    cmp rdi, 0
    je memmove_end
    cmp rsi, 0
    je memmove_end
    cmp rdx, 0
    je memcpy_end

memmove_check:
    cmp rdi, rsi
    jb memmove_loop
    ja memmove_overlap

memmove_loop:
    cmp rdx, 0
    je memmove_end
    mov r8b, BYTE [rsi]
    mov BYTE [rdi], r8b
    inc rdi
    inc rsi
    dec rdx
    jmp memmove_loop

memmove_overlap:
    dec rdx
    add rdi, rdx
    add rsi, rdx
    inc rdx

memmove_overlap_loop:
    cmp rdx, 0
    je memmove_end
    mov r8b, BYTE [rsi]
    mov BYTE [rdi], r8b
    dec rdx
    dec rdi
    dec rsi
    jmp memmove_overlap_loop

memmove_end:
    ret


strcmp:
    xor rax,rax
    xor r8, r8
    xor r9, r9

strcmp_loop:
    mov r8, [RDI]
    mov r9, [RSI]
    cmp r8b, 0
    je strcmp_end
    cmp r9b, 0
    je strcmp_end
    cmp r8b, r9b
    jne strcmp_end
    inc rdi
    inc rsi
    jmp strcmp_loop

strcmp_end:
    movzx rax, r8b
    movzx r10, r9b
    sub rax, r10
    ret



strncmp:
    xor rax,rax
    xor r8, r8
    xor r9, r9
    cmp rdx, 0
    je strncmp_0_size

strncmp_loop:
    mov r8, [RDI]
    mov r9, [RSI]
    cmp r8b, 0
    je strncmp_end
    cmp r9b, 0
    je strncmp_end
    cmp r8b, r9b
    jne strncmp_end
    dec rdx
    cmp rdx, 0
    je strncmp_end
    inc rdi
    inc rsi
    jmp strncmp_loop

strncmp_end:
    movzx rax, r8b
    movzx r10, r9b
    sub rax, r10
    ret

strncmp_0_size:
    ret



strcasecmp:
    xor rax,rax
    xor rcx,rcx
    xor r8, r8
    xor r9, r9
    xor r10, r10
    xor r11, r11

strcasecmp_isupper_rdi:
    mov r8b, BYTE [rdi + rcx]
    cmp r8b, 0
    je strcasecmp_isupper_rsi2
    cmp r8b, 91
    jb strcasecmp_lower_rdi
    jmp strcasecmp_isupper_rsi2

strcasecmp_lower_rdi:
    cmp r8b, 65
    jb strcasecmp_isupper_rsi2
    add r8b, 32
    jmp strcasecmp_isupper_rsi2

strcasecmp_isupper_rsi2:
    mov r9b, BYTE [rsi + r11]
    cmp r9b, 0
    je strcasecmp_end
    cmp r9b, 91
    jb strcasecmp_lower_rsi
    jmp strcasecmp_check

strcasecmp_lower_rsi:
    cmp r9b, 65
    jb strcasecmp_check
    add r9b, 32

strcasecmp_check:
    cmp r8b, r9b
    jne strcasecmp_end
    inc rcx
    inc r11
    jmp strcasecmp_isupper_rdi

strcasecmp_end:
    movsx rax, r8b
    sub rax, r9
    ret



strstr:
    xor rax,rax
    xor rcx,rcx
    xor r8, r8
    xor r9, r9
    xor r10, r10
    xor r11, r11

strstr_len:
    mov rcx, 0

strstr_loop_strlen:
    cmp BYTE [rsi + rcx], 0
    je strstr_end_strlen
    add rcx, 1
    jmp strstr_loop_strlen

strstr_end_strlen:
    mov r10, rcx
    mov r8, RDI
    xor rcx, rcx

strstr_strchr_loop:
    xor rcx, rcx
    mov r11b, [rsi]
    cmp r11b, 0
    je strstr_strncmp_end
    cmp BYTE [r8], r11b
    je strstr_strncmp_loop
    cmp BYTE [r8], 0
    je strstr_end
    add r8, 1
    jmp strstr_strchr_loop

strstr_strncmp_loop:
    mov r9b, BYTE [RSI + rcx]
    cmp r9b, 0
    je strstr_strncmp_end
    cmp BYTE [r8], 0
    je strstr_end
    cmp rcx, r10
    je strstr_strncmp_end
    cmp [r8], r9b
    jne strstr_strchr_loop
    inc rcx
    inc R8
    jmp strstr_strncmp_loop

strstr_strncmp_end:
    sub r8, r10
    mov rax, r8
    ret

strstr_end:
    ret



strpbrk:
    mov r8, RDI
    mov r9, RSI
    xor rax,rax
    jmp strpbrk_loop

strpbrk_reset_r9:
    mov r9, rsi
    inc r8

strpbrk_loop:
    cmp BYTE [r8], 0
    je strpbrk_end
    mov r10b, [r9]
    cmp BYTE [r8], r10b
    je strpbrk_end
    jne strpbrk_check

strpbrk_check:
    cmp BYTE [r9], 0
    je strpbrk_reset_r9
    mov r10b, [r8]
    cmp BYTE [r9], r10b
    je strpbrk_end
    inc r9
    jmp strpbrk_check

strpbrk_null:
    mov rax, 0
    ret

strpbrk_end:
    cmp BYTE [r8], 0
    je strpbrk_null
    mov rax, r8
    ret



strcspn:
    mov r8, RDI
    mov r9, RSI
    xor rax,rax
    xor rcx, rcx
    jmp strcspn_loop

strcspn_reset_r9:
    mov r9, rsi
    inc r8
    inc rcx

strcspn_loop:
    cmp BYTE [r8], 0
    je strcspn_end
    mov r10b, [r9]
    cmp BYTE [r8], r10b
    je strcspn_end
    jne strcspn_check

strcspn_check:
    cmp BYTE [r9], 0
    je strcspn_reset_r9
    mov r10b, [r8]
    cmp BYTE [r9], r10b
    je strcspn_end
    inc r9
    jmp strcspn_check

strcspn_end:
    mov rax, rcx
    ret



ffs:
    xor rax,rax
    cmp rdi, 0
    je ffs_end
    bsf rax, rdi
    inc rax

ffs_end:
    ret



memfrob:
    mov rax, rdi

memfrob_loop:
    cmp rsi, 0
    je memfrob_end
    xor BYTE [rdi], 42
    inc rdi
    dec rsi
    jmp memfrob_loop

memfrob_end:
    ret



syscall:
    mov rax, rdi
    mov rdi, rsi
    mov rsi, rdx
    mov rdx, rcx
    mov r10, r8
    mov r8, r9
    mov r9, [rsp + 8]
    syscall
    ret