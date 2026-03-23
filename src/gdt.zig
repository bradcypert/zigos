// the GDT is a table of 8-byte "descriptors" that the CPU reads
// to understand how memory is segemented. In 64-bit mode, segementation
// is flag but we still need a valid GDT with the right flags
// for the the CPU to be happy.

// A single GDT entry (descriptor), 8 bytes
// The layout is archtiecturally defined and cannot be changed.
const GdtEntry = packed struct {
    limit_low: u16, // bits 15:0 of segment limit (ignored in 64bit)
    base_low: u16, // bits 15:0 of base address (ignored in 64bit)
    base_mid: u8, // bits 23:16 of base (ignored in 64bit)
    access: u8, // present, privledge, type, executable, etc.
    flags_limit: u8, // upper 4 bits = flags (granularity, L bit), lower 4 = limit[19:16]
    base_high: u8, // bits 31:24 of base (ignoring in 64-bit)
};

// The GDTR register points to the GDT. WE load it with the `lgdt` instruction.
// Must be packed to match the exact CPU-expected layout.
const GdtDescriptor = packed struct {
    size: u16, // byte length of the GDT minus 1
    offset: u64, // linear (virtual) address of the GDT
};

// Our GDT: three entries is the minimum for a working 64-bit kernel.
// This must be aligned to ensure the CPU can read it correctly.
var gdt: [3]GdtEntry align(8) = .{
    // Entry 0: Null descriptor - required by the CPU spec, must all be zeroes
    .{
        .limit_low = 0,
        .base_low = 0,
        .base_mid = 0,
        .access = 0,
        .flags_limit = 0,
        .base_high = 0,
    },
    // Entry 1: Kernel code segment (selector = 0x08)
    // access: 0b10011010 = present | ring-0 | S=1 | executable | readable
    // flags_limit: 0b00100000 = L=1 (64bit code segment), G=0, limit upper nibble = 0
    .{
        .limit_low = 0,
        .base_low = 0,
        .base_mid = 0,
        .access = 0b10011010,
        .flags_limit = 0b00100000,
        .base_high = 0,
    },
    // Entry 2 Kernel data segment (selector = 0x10)
    // access: 0b10010010 = present | ring-0 | S=1 | data | writable
    // flags_limit: 0b00000000 = L=0 (data segments dont use the L bit)
    .{
        .limit_low = 0,
        .base_low = 0,
        .base_mid = 0,
        .access = 0b10010010,
        .flags_limit = 0,
        .base_high = 0,
    },
};

extern fn gdt_flush(gdtr: *const GdtDescriptor) void;
pub fn init() void {
    const gdtr = GdtDescriptor{
        .size = @sizeOf(@TypeOf(gdt)) - 1,
        .offset = @intFromPtr(&gdt),
    };

    gdt_flush(&gdtr);
}
