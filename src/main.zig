// No @import("std") OS-level features are available -- we ARE the OS.
// We can still import std for types and compile-time utilities.
const StackTrace = @import("std").builtin.StackTrace;

// `export` makes this function visible to the linker by the exact name
// "kernel_main" -- matching the ENTRY in our linker script

// `noreturn` tells Zig this function never returns. If it did, there's
// nothing to return to -- the CPU would execute whatever garbage is in
// memory after our kernel.
export fn kernel_main() noreturn {
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
