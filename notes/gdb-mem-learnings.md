Can you explain further. I just ran the next command and here's the output for the first 3
lines:

0xffff800003bbf000:     0x0000000003bbe007      0x0000000000200083
0xffff800003bbf010:     0x0000000000400083      0x0000000000600083
0xffff800003bbf020:     0x0000000003bbd007      0x0000000000a00083

● You're now at the Page Directory level. Each entry here covers a 2MB region of virtual
  address space.

  Look at the flag differences — two patterns:

  0x...007 — bits 0b111 = present, writable, user. No huge-page bit. This means the entry
  points to another table (a Page Table), not a final page. You'd need to go one more level
  down to find the actual frames.

  0x...083 — bits 0b10000011 = present, writable, and bit 7 (huge-page) set. This entry is the
  final mapping — no Page Table below it. The masked address directly IS a 2MB physical page
  frame.

  So decode the second entry on line 1:
  0x0000000000200083 & ~0xFFF = 0x200000
  That's physical address 2MB, mapped as a 2MB huge page.

  The pattern continues — 0x400083 maps physical 4MB, 0x600083 maps 6MB, 0xa00083 maps 10MB.
  These are Limine's identity map of low physical memory.

  The 0x...007 entries (index 0 and index 4) point to Page Tables for finer-grained 4KB
  mappings — that's probably where your kernel's actual code/data pages live, since they need
  specific permissions per section.

  The key insight: x86-64 paging can terminate at the PD level (2MB huge pages) or go all the
  way to PT level (4KB pages). Limine used both — huge pages for the bulk identity map, regular
   4KB pages for the kernel.

  Want to trace one of the 0x...007 entries down to the final PT level to see individual 4KB
  pages?
