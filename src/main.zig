// No @import("std") OS-level features are available -- we ARE the OS.
// We can still import std for types and compile-time utilities.
const StackTrace = @import("std").builtin.StackTrace;
const gdt = @import("gdt.zig");
const idt = @import("idt.zig");

export var limine_base_revision: [3]u64 linksection(".limine_requests") = .{
    0xf9562b2d5c95a6c8, // magic number 1
    0x6a7b384944536bdc, // magic number 2
    3, // revision we want, Limine writes 0 here if supported
};

// Write a single byte to COM1 serial port for debugging.
// QEMU will print this to the terminal when run with -serial stdio.
fn serialWrite(c: u8) void {
    asm volatile ("outb %%al, %%dx"
        :
        : [port] "{dx}" (@as(u16, 0x3F8)),
          [val] "{al}" (c),
    );
}

// `export` makes this function visible to the linker by the exact name
// "kernel_main" -- matching the ENTRY in our linker script
// `noreturn` tells Zig this function never returns. If it did, there's
// nothing to return to -- the CPU would execute whatever garbage is in
// memory after our kernel.
export fn kernel_main() noreturn {
    serialWrite('A');
    // verify limine honored our base revision request.
    // if index[2] is non-zero Limine didn't support revision 3
    if (limine_base_revision[2] != 0) {
        while (true) asm volatile ("hlt");
    }

    serialWrite('B');

    // Initialize the global descriptor table
    gdt.init();
    // Initialize the interrupt descriptor table
    idt.init();
    serialWrite('I');

    serialWrite('C');
    // Write "ZigOS" to VGA text mode memory at 0xB8000.
    // Each u16 = [attribute (high byte)] [ASCII char (low byte)]
    // 0x0F = white text on black background
    // const vga: [*]volatile u16 = @ptrFromInt(0xB8000);
    // const msg = "ZigOS: GDT loaded!";
    // for (msg, 0..) |char, i| {
    //    vga[i] = (@as(u16, 0x0F) << 8) | char;
    // }

    serialWrite('D');

    // `hlt` suspends the CPU until the next interrupt
    // Cheaper than a busy spin, and correct behavior for "do nothing".
    while (true) {
        asm volatile ("hlt");
    }
}

// Zig requires a panic handler. Normally the standard library provides one
// (it prints to stderr and exits), but we have no stderr and no exit.
// We provide our own that just halts.
pub fn panic(
    msg: []const u8,
    error_return_trace: ?*StackTrace,
    ret_addr: ?usize,
) noreturn {
    _ = msg;
    _ = error_return_trace;
    _ = ret_addr;
    while (true) {
        asm volatile ("hlt");
    }
}
