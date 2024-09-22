const std = @import("std");
const expect = std.testing.expect;

// Memory Layout (4 x 1024 bytes): You store the whole program AND the
// interpreter in the memory.
// The first 512 bytes (addresses 000 - 1FF) are occupied by the interpreter.
// Inside this address space, there exist the special font addresses which are
// usually contained inside addresses 050 - 09F. These fonts relate to the display
// part of the system as they represent 4px wide by 5px tall characters. The rest
// of the remaining memory is used to load the program.

pub const Memory = struct {
    heap: [4 * 1024]u8 = undefined,

    const fonts = [80]u8{
        0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
        0x20, 0x60, 0x20, 0x20, 0x70, // 1
        0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
        0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
        0x90, 0x90, 0xF0, 0x10, 0x10, // 4
        0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
        0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
        0xF0, 0x10, 0x20, 0x40, 0x40, // 7
        0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
        0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
        0xF0, 0x90, 0xF0, 0x90, 0x90, // A
        0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
        0xF0, 0x80, 0x80, 0x80, 0xF0, // C
        0xE0, 0x90, 0x90, 0x90, 0xE0, // D
        0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
        0xF0, 0x80, 0xF0, 0x80, 0x80, // F
    };

    /// Initializing the emulator's memory is a three steps process:
    /// 1. You must initialize the whole memory,
    /// 2. You must copy the fonts somewhere in that memory,
    /// 3. You must load the read program in memory.
    pub fn init(program: []const u8) Memory {
        var buffer = [_]u8{0x0} ** (4 * 1024); // Create a 4KB Memory Area
        @memcpy(buffer[0x050 .. 0x09f + 1], &fonts); // + 1 for including the last address
        @memcpy(buffer[512 .. 512 + program.len], program); // load the program in memory

        return Memory{
            .heap = buffer,
        };
    }

    /// Returns the instruction that PC is currently pointing at from Memory
    /// as a 16bit instruction
    pub fn fetch(self: *Memory, pc: u16) ?u16 {
        if (pc >= self.heap.len) {
            return null;
        }

        return @as(u16, self.heap[pc]) << 8 | self.heap[pc + 1];
    }
};

test "Fetch Instruction" {
    var memory = Memory{ .heap = [_]u8{0x0} ** 4096 };
    memory.heap[0] = 0x15;
    memory.heap[1] = 0x32;
    const opcode = memory.fetch(0);
    try expect(opcode == 0x1532);
}
