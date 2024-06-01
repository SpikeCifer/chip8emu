const std = @import("std");

const CPUErrors = error{
    UnsupportedInstruction,
};

fn decode(instruction: u16) [4]u4 {
    var nibbles: [4]u4 = undefined;
    nibbles[0] = @truncate((instruction & 0xF000) >> 12);
    nibbles[1] = @truncate((instruction & 0x0F00) >> 8);
    nibbles[2] = @truncate((instruction & 0x00F0) >> 4);
    nibbles[3] = @truncate(instruction & 0x000F);
    return nibbles;
}

pub const CPU = struct {
    var_regs: [16]u8 = undefined,
    index_reg: u16 = undefined,

    pub fn run(instruction: u16) !void {
        const decoded_instruction = decode(instruction);
        switch (decoded_instruction[0]) {
            0x0 => std.debug.print("Clear Screen!", .{}),
            0x1 => std.debug.print("Jump!\n", .{}),
            0x6 => std.debug.print("Set Register V{x}!\n", .{decoded_instruction[1]}),
            0x7 => std.debug.print("Add Value to Register V{x}!\n", .{decoded_instruction[1]}),
            0xa => std.debug.print("Set Register I!\n", .{}),
            0xd => std.debug.print("Draw Screen!\n", .{}),
            else => return CPUErrors.UnsupportedInstruction,
        }
    }
};

test "Decode Instruction" {
    const instruction: u16 = 0x1358;
    const expected = [_]u4{ 0x1, 0x3, 0x5, 0x8 };
    const actual = decode(instruction);
    try std.testing.expectEqual(expected, actual);
}
