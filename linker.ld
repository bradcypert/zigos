/* Tell the linker where execution starts */ 
ENTRY(kernel_main) /* is kernel_main Kernel::main */

SECTIONS {
  /* Start placing sections at the 1MB mark */
  . = 0xFFFFFFFF80000000;

  /* .text holds your executable code */ 
  .text : ALIGN(0x1000) {
    *(.text .text.*)
  }

  /* rodata holds read-only data (string literals, constants) */
  .rodata : ALIGN(0x1000) {
    *(.rodata .rodata.*)
  }

  /* .data holds initialized global/static variables */
  .data : ALIGN(0x1000) {
    *(.data .data.*)
    /* Keep Limine request structures - linker must not discard them */
    KEEP(*(.limine_requests .limine_requests.*))
  }

  /* .bss holds zero-initialized globals. The bootlander zeroes this for us.
   * It takes up no space in the binary file -- just a size record */ 
  .bss : ALIGN(0x1000) {
    *(COMMON)
    *(.bss .bss.*)
  }
}
