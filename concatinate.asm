  section .data
    ; fitst string and it's length
    msg1 db "Hello,", 0
    len_msg1 equ $ - msg1 

    ; second string and it's length
    msg2 db "World!", 0
    len_msg2 equ $ - msg2

  ; block started by symbol
  ; we can define the buffer on the .data section but it's not recommended as it is meant for initialized data only
  section .bss
    ; reserving uninitialized data (variable) in memory without allocating space in binary file
    ; buffer is only reserved in memory (not stored in binary)
    ; 
    ; resb 128 : reserves 128 bytes
    ; resw 128 : reserves 128 words (256 bytes, 1 word = 2 bytes)
    ; resd 128 : reserves 128 doublewords (512 bytes, since 1 dword = 4 bytes)
    buffer resb 128

  section .text
    ; _start declaration
    global _start

    ; _start def'n
    _start:
      ; esi : source index register : often used as the source register in string operations or memory copying tasks
      ; also used when dealing with pointer arithmetic : working with data buffers, arrays, etc... 
      mov esi, msg1

      ; edi : destination index register : often used as the destination register in string operations or memory copying tasks
      ; and also used for pointer arithmetic, when manipulating arrays or memory buffers 
      ; 
      ; basically, here we are initializing the buffer in to the memory, so that we could further work with it
      ; edi will now point to the first byte of buffer, where we will copy msg1
      mov edi, buffer

      ; setting ecx reg. to length of msg1 ie. len_msg1
      mov ecx, len_msg1
      ; rep   : repeat
      ; movsb : move string byte
      ; -- together they allow you to move sequence of bytes from source to destination efficiently
      ;
      ; so what we are doing here is: copying bytes from [esi] to [edi] for ecx times 
      rep movsb

      ; after msg1 copied to the buffer, we will now copy msg2 to buffer
      ; the msg2 will be appended to the buffer not overwrite it
      mov esi, msg2
      mov ecx, len_msg2
      rep movsb
      
      ; [] brackets around edi indicated indirect addressing
      ; ie. refrencing the memory address that edi contains not the value in edi itself
      ; 
      ; so here, storing the value 0x0A(newline character) at the memory location pointed to by edi
      ; ie. "\n" to the memory location buffer
      mov byte [edi], 10
      ; incrementing edi by 1
      ; moving the pointer to the next byte in memory
      inc edi
      
      ; subtracts the value of the second operand from the first operand and stores the result in the first operand
      ;
      ; After copying msg1 and msg2 and adding the newline character, edi now points to the byte just after the newline. 
      ; Subtracting the address of buffer gives the number of bytes that have been copied into buffer.
      sub edi, buffer
      
      ; now preaparing for:  writing to stdout
      ; sys_write
      mov eax, 4
      ; POINTS TO BE REMEMBER : I FOUND WAS
      ; ebx values dependent of the eax values ie. 
      ; if the eax value is set to 1 (sys_exit) then, ebx defines the exit types : no_error(success), general_error, ....
      ; but if eax value is set to 4 (sys_write) then, ebx defines the file descriptors: 0 - stdin, 1 - stdout, 3 - stderr
      mov ebx, 1
      ; setting ecx reg. to addr. of second_string which is stored in buffer
      mov ecx, buffer
      ; moving the length of the data in buffer into edx
      mov edx, edi
      int 0x80

      ; Invoking sys_exit
      mov eax, 1
      xor ebx, ebx
      int 0x80


