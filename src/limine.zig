// Limine protocol structures.
// Isolated here so replacing Limine later only requires changing this file (hopefully)

pub const MemMapEntryType = enum(u64) {
    usable = 0,
    reserved = 1,
    acpi_reclaimable = 2,
    acpi_nvs = 3,
    bad_memory = 4,
    bootloader_reclaimable = 5,
    kernel_and_modules = 6,
    framebuffer = 7,
    _, // catch all -- unknown types
};

pub const MemMapEntry = extern struct {
    base: u64,
    length: u64,
    type: MemMapEntryType,
};

pub const MemMapResponse = extern struct {
    revision: u64,
    entry_count: u64,
    entries: [*]*MemMapEntry, // pointer to array of pointers
};

pub const MemMapRequest = extern struct {
    id: [4]u64,
    revision: u64,
    response: ?*MemMapResponse,
};
