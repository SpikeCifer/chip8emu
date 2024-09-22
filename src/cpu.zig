const std = @import("std");
const assert = std.testing;

const CPUErrors = error{
    UnsupportedInstruction,
};

pub const CPU = struct {
    var_regs: [16]u8 = undefined,
    index_reg: u16 = undefined,
    pc: u16 = 0,

    pub fn run(self: *CPU, instruction: u16) !void {
        switch ((instruction & 0xF000) >> 12) {
            0x0 => return, // Nothing to do currently
            0x1 => std.debug.print("Jump to {x}!\n", .{(instruction & 0x0FFF) >> 4}),
            0x2 => std.debug.print("Call Subroutine at {x}!\n", .{(instruction & 0x0FFF) >> 4}),
            0x3 => std.debug.print("Skip Instruction if V{x} is {x}!\n", .{ (instruction & 0x0F00) >> 8, (instruction & 0x00FF) }),
            0x4 => std.debug.print("Skip Instruction if V{x} is not {x}!\n", .{ (instruction & 0x0F00) >> 8, (instruction & 0x00FF) }),
            0x5 => std.debug.print("Skip Instruction if V{x} is equal to V{x}!\n", .{ (instruction & 0x0F00) >> 8, (instruction & 0x00F) >> 4 }),
            0x6 => self.var_regs[(instruction & 0x0F00) >> 8] = @truncate(instruction & 0x00FF),
            0x7 => std.debug.print("Add Value {x} to Register V{x}!\n", .{ instruction & 0x00FF, (instruction & 0x0F00) >> 8 }),
            0x8 => {
                switch (instruction & 0x000F) {
                    0x1 => std.debug.print("Binary OR\n", .{}),
                    0x2 => std.debug.print("Binary AND", .{}),
                    0x3 => std.debug.print("Binary XOR", .{}),
                    0x4 => std.debug.print("ADD", .{}),
                    0x5, 0x7 => std.debug.print("SUBTRACT", .{}),
                    0x6, 0xE => std.debug.print("SHIFT", .{}),
                    else => return CPUErrors.UnsupportedInstruction,
                }
            },
            0x9 => std.debug.print("Skip one instruction if V{x} != V{x}!\n", .{ (instruction & 0x0F) >> 8, (instruction & 0x00F) >> 4 }),
            0xA => std.debug.print("Set Register I to {x}!\n", .{instruction & 0x0FFF}),
            0xB => std.debug.print("Jump with offset {x}!\n", .{instruction & 0x0FFF}),
            0xC => std.debug.print("Random!\n", .{}),
            0xD => std.debug.print("Draw Screen!\n", .{}),
            0xE => {
                switch (instruction & 0x00FF) {
                    0x9E => std.debug.print("Skip one instruction if key with value V{x} is pressed!\n", .{(instruction & 0x0F) >> 8}),
                    0xA1 => std.debug.print("Skip one instruction if key with value V{x} is not pressed!\n", .{(instruction & 0x0F) >> 8}),
                    else => return CPUErrors.UnsupportedInstruction,
                }
            },
            0xF => {
                switch (instruction & 0x00FF) {
                    0x07 => std.debug.print("Set V{x} to current value of the delay timer!\n", .{(instruction & 0x0F) >> 8}),
                    0x0A => std.debug.print("Get Key", .{}),
                    0x15 => std.debug.print("Set delay timer to value of V{x}!\n", .{(instruction & 0x0F) >> 8}),
                    0x18 => std.debug.print("Set sound timer to value of V{x}!\n", .{(instruction & 0x0F) >> 8}),
                    0x1E => std.debug.print("Add value of V{x} to index register I!\n", .{(instruction & 0x0F) >> 8}),
                    0x29 => std.debug.print("Set index register to address of V{x}", .{(instruction & 0x0F) >> 8}),
                    0x33 => std.debug.print("Binary Decimal Conversion", .{}),
                    0x55 => std.debug.print("Store Memory", .{}),
                    0x65 => std.debug.print("Load Memory", .{}),
                    else => return CPUErrors.UnsupportedInstruction,
                }
            },
            else => return CPUErrors.UnsupportedInstruction,
        }
    }
};

test "Run a set instruction" {
    var cpu = CPU{};
    const instruction = 0x6A11;
    try cpu.run(instruction);
    try assert.expectEqual(0x11, cpu.var_regs[0xA]);
}
