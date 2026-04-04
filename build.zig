const std = @import("std");

pub fn build(b: *std.Build) void {
    // We define our own target rather than using standardTargetoptions()
    // this hardcodes x86_64 freestanding-none: 64-bit CPU, no OS, no ABI.
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .x86_64,
        .os_tag = .freestanding,
        .abi = .none,
    });

    const optimize = b.standardOptimizeOption(.{});
    const kernel = b.addExecutable(.{
        .name = "kernel",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .red_zone = false,
            // The kernel code model tells the compiler that our code lives in the upper 2GB of address space
            // This matters for how the CPU encodes memory references in instructions
            .code_model = .kernel,
        }),
    });

    kernel.use_llvm = true;
    kernel.use_lld = true;
    kernel.entry = .{ .symbol_name = "kernel_main" };

    kernel.setLinkerScript(b.path("linker.ld"));
    kernel.addAssemblyFile(b.path("src/gdt_flush.s"));
    kernel.addAssemblyFile(b.path("src/idt_stubs.s"));
    b.installArtifact(kernel);
}
