This code is specifically written in x86 linux System
```
To adapt this to other platforms, you would need to:

    - Modify the system call mechanism.
    - Replace int 0x80 with the appropriate system call for the respective OS. <br>
````
---

```
1. Install nasm (assembler)
2. Install build-essential

❯ sudo <package-manager> install nasm build-essential -y
```


```
~/projects/assembly 
❯ nasm -f elf32 -o hello.o hello.asm        

~/projects/assembly 
❯ ld -m elf_i386 -s -o hello hello.o
```

