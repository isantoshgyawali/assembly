    section .data
    arr dd 20, 30, 67, 86, 52, 94, 55, 82, 34, 33
    len_arr equ ($ - arr) / 4

    ; this is for printing things on demand.
    ; in c, we write printf("%d\n", value), but in assembly
    ; we do this manually, so we need to explicitly store the format string in memory
    ; and pass it address
    fmt db "%d", 10, 0

    section .bss
    ; Temporary storage variable for swapping purposes
    ; resb 128 : reserves 128 bytes
    ; resw 128 : reserves 128 words (256 bytes, 1 word = 2 bytes)
    ; resd 128 : reserves 128 doublewords (512 bytes, since 1 dword = 4 bytes)

    ; resd 1 will reserve only 4 bytes which is enough to store a single integer 
    ; if we did resd 128 we would reserve 128x4=512 bytes which is unnecessary here
    ;
    ; and though resb 4, resw 2 would reserve same byte size but they are for working with
    ; resb : byte size value (strings, flags ...)
    ; resw : 16 bit values which are rarely used in modern architecture
    ; and there is resq which is for 64bit

    ; since upto 2^32 - 1 are 32 bit integers (unsigned)
    ; and we are only storing values like 20, 94, 55..., so we are using resd 1
    ; and if I wish to use the elements in array with larger value than that I would need resq in action
    temp resd 1

    section .text
    global _start
    ; extern is directive used in assembly, that let's you use to declare external functions that are defined outside
    ; of the current file, like for this we are telling assembler that printf exists somewhere else, usually like
    ; the C standard library(libc), that it should link during the assembly process
    ; 
    ; Languages that are close to bare metal or are used for system-level programming, 
    ; like C, C++, Rust, and Zig, can be directly called from assembly.
    ; unlike languages like go, java, that have more heavier blueprints like  garbage collector and runtime things
    extern printf

_start:
    ; setting the value of the ecx reg to length of array[] 
    mov ecx, len_arr
outer_loop:
    ; Creating a loop conditional block 
    dec ecx ; ecx = ecx - 1
    jz done ; if ecx is 0, jump to 'done'

    ; setting edi for inner_loop 
    mov edi, len_arr
    dec edi ; edi = len_arr - 1

    ; "mov edi, len_arr - 1" is not allowed because it's arithmetic done at assembly time
    ; and mov operations can't perform operations on constants
    ; but,
    ; mov eax, [arr, edi * 4 - 4] is allowed because CPU supports memomory addressing modes
    ; allowing calculations like: 
    ; Base_Register + (Index_Register * Scale) + offset
    ; For this to understand take this:
    ; Direct addressing : mov eax, [arr] : instruction directly refers to fixed memory location
    ; Register Inderect addressing : mov eax, [edi] : memory location comes from edi which holds an address
    ; Scaled index addressing : mov eax, [arr, edi * 4 - 4] : Cpu calculates address using Base + (Index * Scale) + Offset
    ; so,
    ; conclusion is that is not arithmetic but an effective address computation
inner_loop:
    ; If edi == 0, then arr + edi * 4 - 4 would attempt to access memory before the start of the array,
    ; causing undefined behavior or a crash.
    cmp edi, 0 ; checks if edi is 0 (first element)
    je no_swap ; if 0, skip swap to avoid out-of-bound access
    ; Since we are working with 32-bit (4-byte) integers, we set scale = 4 to move along addresses effectively.
    ; We are accessing the previous element in the array for comparison, so we set offset = -4.
    mov eax, [arr + edi * 4 - 4] ; (previous element)
    mov ebx, [arr + edi * 4]     ; (current element)  

    cmp eax, ebx ; comparing eax and ebx
    jge no_swap  ; jump if greater or equal

    ; moving things here and there
    ; as they should be
    mov [temp], eax
    mov [arr + edi * 4 - 4], ebx
    mov eax, [temp]
    mov [arr + edi * 4], eax

no_swap:
    dec edi         ; edi = edi - 1
    jnz inner_loop  ; if edi != 0, go to inner_loop
    jmp outer_loop  ; else go to outer_loop

done:
    mov esi, 0
print_loop:
    mov eax, [arr + esi * 4]
    ; The stack pointer (ESP) is a register that points to the current top of the stack.
    ; push eax decreases ESP by 4 (since EAX is 32 bits, i.e., 4 bytes).
    ; this stores the value of arr[esi] (the current element) on stack
    push eax
    ; pushes the address of the fmt string(format specifier) to the stack. 
    ; This will be passed as an argument to printf
    push fmt
    ; saves return address on the stack and jumps to printf function
    call printf

    ; Adjusting the stack pointer by 8 bytes
    ; printf function expects its argument to be passed on the stack. 
    ; Since we pushed two items (eax and fmt) total size is 8 bytes (4 for eax and 4 for fmt)
    ; After calling, we cleanup the esp back, removing those two arguments from the stack
    add esp, 8

    inc esi ; Indexing to traverse to next element in the array
    cmp esi, len_arr ; checking if we have reached the end or not
    jne print_loop ; jump if not equal, to  print_loop

    ; exit statement
    mov eax, 1
    xor ebx, ebx
    int 0x80
