const limine = @import("limine.zig");

const PAGE_SIZE: u64 = 4096;

// One bit per 4KB frame. Supports up to 4GB of RAM.
// stored in .bss - no cost in the binary, zero-initialized
const MAX_FRAMES: u64 = 1024 * 1024; // covers 4GB of physical memory
const MEM_SIZE = 64;

// Each bit represents one 4KB page frame. 1 = used, 0 = free
var bitmap: [MAX_FRAMES / MEM_SIZE]u64 = [_]u64{0} ** (MAX_FRAMES / MEM_SIZE);

pub var total_frames: u64 = 0;
pub var free_frames: u64 = 0;

fn setBit(frame: u64) void {
    const shift: u6 = @truncate(frame % MEM_SIZE);
    bitmap[frame / MEM_SIZE] |= (@as(u64, 1) << shift);
}

fn clearBit(frame: u64) void {
    const shift: u6 = @truncate(frame % MEM_SIZE);
    bitmap[frame / MEM_SIZE] &= ~(@as(u64, 1) << shift);
}

pub fn init(memmap: *limine.MemMapResponse) void {
    // Start with everything marked used (all bits set)
    @memset(&bitmap, 0xFF);

    // Find the highest physical address to compute total_frames
    var highest: u64 = 0;
    for (0..memmap.entry_count) |i| {
        const entry = memmap.entries[i];
        const end = entry.base + entry.length;
        if (end > highest) highest = end;
    }
    total_frames = (highest + PAGE_SIZE - 1) / PAGE_SIZE;

    // Mark only usable regions as free
    for (0..memmap.entry_count) |i| {
        const entry = memmap.entries[i];
        if (entry.type == .usable) {
            const start_frame = entry.base / PAGE_SIZE;
            const num_frames = entry.length / PAGE_SIZE;
            for (0..num_frames) |f| {
                clearBit(start_frame + f);
                free_frames += 1;
            }
        }
    }
}

pub fn alloc() ?u64 {
    for (0..total_frames / 64) |word_idx| {
        const word = bitmap[word_idx];
        if (word == 0xFFFFFFFFFFFFFFFF) continue; // all used, skip

        // Find the first 0 bit in this word
        for (0..64) |bit| {
            const shift: u6 = @truncate(bit);
            if ((word >> shift) & 1 == 0) {
                const frame = word_idx * 64 + bit;
                setBit(frame);
                free_frames -= 1;
                return frame * PAGE_SIZE;
            }
        }
    }

    return null; // OOM
}

pub fn free(addr: u64) void {
    clearBit(addr / PAGE_SIZE);
    free_frames += 1;
}

