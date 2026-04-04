.extern exceptionHandler

# Macro for exceptions WITHOUT an error code (CPU doesnt push one)
.macro isr_no_err vector
.global stub\vector
stub\vector:
    pushq $0       #fake error code for uniformity
    pushq $\vector #which vector fired
    jmp isr_common
.endm

# Macro for exceptions WITH an error code (CPU pushes one automatically)
.macro isr_err vector
.global stub\vector
stub\vector:
    pushq $\vector   # CPU already pushed the error code
    jmp isr_common
.endm

# x86-64 exception vectors 0-31
isr_no_err 0   # Divide Error
isr_no_err 1   # Debug
isr_no_err 2   # NMI
isr_no_err 3   # Breakpoint
isr_no_err 4   # Overflow
isr_no_err 5   # Bound Range
isr_no_err 6   # Invalid Opcode
isr_no_err 7   # Device Not Available
isr_err    8   # Double Fault
isr_no_err 9   # Coprocessor Segment Overrun
isr_err    10  # Invalid TSS
isr_err    11  # Segment Not Present
isr_err    12  # Stack Fault
isr_err    13  # General Protection Fault
isr_err    14  # Page Fault
isr_no_err 15
isr_no_err 16  # x87 FPU Error
isr_err    17  # Alignment Check
isr_no_err 18  # Machine Check
isr_no_err 19  # SIMD FP Exception
isr_no_err 20  # Virtualization Exception
isr_err    21  # Control Protection
isr_no_err 22
isr_no_err 23
isr_no_err 24
isr_no_err 25
isr_no_err 26
isr_no_err 27
isr_no_err 28  # Hypervisor Injection
isr_err    29  # VMM Communication
isr_err    30  # Security Exception
isr_no_err 31

isr_common:
# Save all general-purpose registers
  pushq %rax
  pushq %rbx
  pushq %rcx
  pushq %rdx
  pushq %rsi
  pushq %rdi
  pushq %rbp
  pushq %r8
  pushq %r9
  pushq %r10
  pushq %r11
  pushq %r12
  pushq %r13
  pushq %r14
  pushq %r15

 # RSP now points to the InterruptFrame — pass it as first argument
  movq %rsp, %rdi
  call exceptionHandler

 # Restore registers
  popq %r15
  popq %r14
  popq %r13
  popq %r12
  popq %r11
  popq %r10
  popq %r9
  popq %r8
  popq %rbp
  popq %rdi
  popq %rsi
  popq %rdx
  popq %rcx
  popq %rbx
  popq %rax

  # Remove vector and error_code from stack, then return from interrupt
  addq $16, %rsp
  iretq

# For lidt - same issue as lgdt, use a .s file
.global lidt_load
lidt_load:
  lidt (%rdi)
  ret
