const std = @import("std");

const CPU = @import("cpu.zig").CPU;
const Memory = @import("mem.zig").Memory;
const display = @import("display.zig");

const InputParseError = error{
    NoFilenameFound,
};

pub fn main() !void {
    // Process command line arguments
    var args = std.process.args();
    _ = args.next().?; // Skip the first argument as it's the name of the binary
    const filename = args.next() orelse return InputParseError.NoFilenameFound;

    // Load program in Memory
    var buffer: [4 * 1024 - 512]u8 = undefined;
    const program = try std.fs.cwd().readFile(filename, &buffer);
    var memory = Memory.init(program);
    var cpu = CPU{};

    while (memory.fetch(cpu.pc)) |instruction| : (cpu.pc += 2) {
        std.debug.print("0x{x}: 0x{x}\n", .{ cpu.pc, instruction });

        cpu.run(instruction) catch {
            std.debug.print("Instruction {x} is not supported!\n", .{instruction});
            return;
        };
    }

    std.debug.print("Reached end of program!\n", .{});
}
