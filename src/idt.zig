const std = @import("std");

extern fn lidt_load(idtr: *const IdtDescriptor) void;

const IdtEntry = packed struct {
    offset_low: u16, // bits 15:0 of handler address
    selector: u16, // code segement selector (0x08 = our kernel CS)
    ist: u8, // interrupt stack table offset (0 = use current stack)
    flags: u8, // type and attributes
    offset_mid: u16, // bits 31:16 of handler address
    offset_high: u32, // bits 63:32 of handler address
    _reserved: u32, // must be zero
};

const IdtDescriptor = packed struct {
    size: u16,
    offset: u64,
};

var idt: [32]IdtEntry = std.mem.zeroes([32]IdtEntry);

// Called from idt_stubs.s - the common handler for all exceptions
export fn exceptionHandler(frame: *InterruptFrame) void {
    // For now: print the vector number to serial and halt
    // We'll make this more sophisticated later
    _ = frame;

    while (true) asm volatile ("hlt");
}

fn setEntry(vector: u8, handler: u64) void {
    idt[vector] = IdtEntry{
        .offset_low = @truncate(handler),
        .selector = 0x08,
        .ist = 0,
        .flags = 0b10001110,
        .offset_mid = @truncate(handler >> 16),
        .offset_high = @truncate(handler >> 32),
        ._reserved = 0,
    };
}

// Declare all 32 stubs from idt_stubs.s
//
// TODO: this should be comptime if possible
extern fn stub0() void;
extern fn stub1() void;
extern fn stub2() void;
extern fn stub3() void;
extern fn stub4() void;
extern fn stub5() void;
extern fn stub6() void;
extern fn stub7() void;
extern fn stub8() void;
extern fn stub9() void;
extern fn stub10() void;
extern fn stub11() void;
extern fn stub12() void;
extern fn stub13() void;
extern fn stub14() void;
extern fn stub15() void;
extern fn stub16() void;
extern fn stub17() void;
extern fn stub18() void;
extern fn stub19() void;
extern fn stub20() void;
extern fn stub21() void;
extern fn stub22() void;
extern fn stub23() void;
extern fn stub24() void;
extern fn stub25() void;
extern fn stub26() void;
extern fn stub27() void;
extern fn stub28() void;
extern fn stub29() void;
extern fn stub30() void;
extern fn stub31() void;

pub fn init() void {
    // stub0, stub1, etc. are defined in idt_stubs.s
    // We'll declare them extern and set each entry
    // TODO: this should also be comptime if possible
    setEntry(0, @intFromPtr(&stub0));
    setEntry(1, @intFromPtr(&stub1));
    setEntry(2, @intFromPtr(&stub2));
    setEntry(3, @intFromPtr(&stub3));
    setEntry(4, @intFromPtr(&stub4));
    setEntry(5, @intFromPtr(&stub5));
    setEntry(6, @intFromPtr(&stub6));
    setEntry(7, @intFromPtr(&stub7));
    setEntry(8, @intFromPtr(&stub8));
    setEntry(9, @intFromPtr(&stub9));
    setEntry(10, @intFromPtr(&stub10));
    setEntry(11, @intFromPtr(&stub11));
    setEntry(12, @intFromPtr(&stub12));
    setEntry(13, @intFromPtr(&stub13));
    setEntry(14, @intFromPtr(&stub14));
    setEntry(15, @intFromPtr(&stub15));
    setEntry(16, @intFromPtr(&stub16));
    setEntry(17, @intFromPtr(&stub17));
    setEntry(18, @intFromPtr(&stub18));
    setEntry(19, @intFromPtr(&stub19));
    setEntry(20, @intFromPtr(&stub20));
    setEntry(21, @intFromPtr(&stub21));
    setEntry(22, @intFromPtr(&stub22));
    setEntry(23, @intFromPtr(&stub23));
    setEntry(24, @intFromPtr(&stub24));
    setEntry(25, @intFromPtr(&stub25));
    setEntry(26, @intFromPtr(&stub26));
    setEntry(27, @intFromPtr(&stub27));
    setEntry(28, @intFromPtr(&stub28));
    setEntry(29, @intFromPtr(&stub29));
    setEntry(30, @intFromPtr(&stub30));
    setEntry(31, @intFromPtr(&stub31));
    const idtr = IdtDescriptor{
        .size = @sizeOf(@TypeOf(idt)) - 1,
        .offset = @intFromPtr(&idt),
    };

    asm volatile ("lidt (%[idtr])"
        :
        : [idtr] "r" (@intFromPtr(&idtr)),
        : .{ .memory = true });
}

pub const InterruptFrame = extern struct {
    // Saved by our stub (in reverse push order)
    r15: u64,
    r14: u64,
    r13: u64,
    r12: u64,
    r11: u64,
    r10: u64,
    r9: u64,
    r8: u64,
    rbp: u64,
    rdi: u64,
    rsi: u64,
    rdx: u64,
    rcx: u64,
    rbx: u64,
    rax: u64,
    // Pushed by the stub or CPU
    vector: u64,
    error_code: u64,
    // Pushed by the CPU automatically
    rip: u64,
    cs: u64,
    rflags: u64,
    rsp: u64,
    ss: u64,
};
