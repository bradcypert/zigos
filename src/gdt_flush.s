.global gdt_flush

  # gdt_flush(gdtr: *const GdtDescriptor) void
  # Called with SysV AMD64 ABI — first argument arrives in %rdi.
  gdt_flush:
      lgdt (%rdi)

      movw $0x10, %ax
      movw %ax, %ds
      movw %ax, %es
      movw %ax, %fs
      movw %ax, %gs
      movw %ax, %ss

      pushq $0x08
      leaq  1f(%rip), %rax
      pushq %rax
      lretq
  1:
      ret
