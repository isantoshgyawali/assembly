; THINGS TO BE REMEMBERED: 
;   - Assembly codes are not Interchangeable accross machines 
;     as ISA (Instruction Set Architecture) differs with targetting processor
;   - Each different assembler have there own way of writing things : syntax and conventions
;   - Code is also Operating System dependent, especially for system calls
;   - Registers and Instructions are defined by Processor Architecture (eg: x86, arm, RISC-V)
;   - Each processor architecture has it's own way of handling data and memory

; MY MACHINE:
;   - processor architecture: x86 
;   - Operating System: Fedora Linux
;   - assembler: nasm

  ; SECTIONS : there are predefined sections to define schema, where what should go
  ; - section .data = stores initialized data like constants, global variables before program starts
  ; - section .text = main code goes here - [ EXECUTABLE CODE ]
  ; - section .bss = variable def'n for memory allocation for uninitialized data
  section .data
    ; db: Define Byte 
    ;   - used to allocate and Initialize memory with byte-sized data
    ;   - "message": label and "Hello, World!": value
    ; 0 defines null terminator : to mark end of string
    message db "Hello, world!", 0

    ; Calculating length of string
    ;   - $: current address of the program counter
    ;   - message: start address of the string here: "Hello, World!" 
    ; so, $ - message : no. of bytes from start of msg to currrent position $
    ; 
    ; but why, why why?? we even calculating:
    ; - so basically, we calculate the length dynamically so that we could operate with string without
    ;   worrying about the changing length of the string while doing register operations. eg, if we added/remove something to 
    ;   string we don't need to re-calculate the length of the string again
    ; - but, why even require length while when I just want to print a simple string: 
    ;   because registers(eg. edx) holds numerical values (address, length)  
    ;   and we can't directly move string to register(eg. edx) without specifying something meaningful to them
    ;   also syscall like write requires specific no. of bytes to be written, if you want to print a string, you
    ;   need to tell the system how many bytes of string you want to print(including the null terminator)
    len equ $ - message

    ; MEMORY - LAYOUT 
    ; | H  | i  | !  | \0 |
    ; | 72 | 105| 33 |  0 |  (ASCII values)

  section .text
    ; THERE EXIST ONLY ONE global
    ; global defines/declare a symbol that will be visible/accessible by the linker (globally available)
    ; AND,Yes you can have other name than "_start" : but, many systems (especially Linux-based ones) 
    ; expect the entry point to be named _start because that's what the linker typically looks for when building an executable.
    ;
    ; also, you could define global at top of the file too, it's not compulsory to be inside of .text sextion
    global _start
    _start: 
      ; setting eax reg. to 4: preaparing for the syscall to print data
      ; as, 4 is the syscall no. for the sys_write system call in linux
      mov eax, 4
      ; setting ebx reg. to 1: ebx holds the file descriptor for the output
      ; here, 1 means file descriptor for stdout (the standard output, which is the console or terminal)
      mov ebx, 1
      ; setting ecx reg. to addr. of message
      ; value of ecx is not string: but the address where the string is located in the memory
      mov ecx, message
      ; setting edx reg. to len
      ; where len defines as said earlier "length of string", thus representing no. of bytes to be written
      mov edx, len
      ; Interrupt instruction: triggers a sys_call
      ; this instruction performs syscall defined by eax ie. 4(sys_write) and passes the value ebx, ecx, edx 
      ; as the arguments to the syscall
      ;
      ; telling OS to write string(address in ecx) to the standard output(file descriptor 1, in ebx) with a length of len bytes(in edx) 
      int 0x80

      ; EXIT PART OF CODE
      ; setting eax value to 1: sys_call no. for sys_exit : used for termination of program
      mov eax, 1
      ; xoring to self and storing: and 1^1 = 0 or 0^0 = 0 so ebx is set to 0
      ; good, fast and effective practice of setting the ebx to 0
      ; also, can be used in higher level languages as it's compute is of O(1) time complexity
      ; 
      ; and 0 refers to "normal exit"
      ; other status are 1: general error, 2: misuse of shell builtins(for shell scripts), 3-125: custom error codes.....
      xor ebx, ebx
      ; again, triggering a sys_call
      ; now, as eax is set to 1, triggering sys_exit causing to exit the program
      ; value of ebx is passed as the exit code
      int 0x80

  ; And, Last but not the least the registers could not be swaped with other kind of info 
  ; like, eax : should must contain syscall - it can't contain file descriptor
  ; similary, 
  ; ebx: file descriptor
  ; ecx: address
  ; edx: length
  ; because that is what OS expects, "specific arguments in specific registers".
  ; Linux syscall convention strictly defines what each reg. must contain for syscall to execute properly
