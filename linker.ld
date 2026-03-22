/* Tell the linker where execution starts */ 
ENTRY(kernel_main) /* is kernel_main Kernel::main */

SECTIONS {
  /* Start placing sections at the 1MB mark */
  . = 0x100000;

  /* .text holds your executable code */ 
  .text : {
    *(.text .text.*)
  }

  /* rodata holds read-only data (string literals, constants) */
  .rodata : {
    *(.rodata .rodata.*)
  }

  /* .data holds initialized global/static variables */
  .data : {
    *(.data .data.*)
  }

  /* .bss holds zero-initialized globals. The bootlander zeroes this for us.
   * It takes up no space in the binary file -- just a size record */ 
  .bss : {
    *(COMMON)
    *(.bss .bss.*)
  }
}
