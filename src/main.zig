const std = @import("std");
const display = @import("display.zig");

const Memory = @import("mem.zig").Memory;
const CPU = @import("cpu.zig").CPU;

const InputParseError = error{
    NoFilenameFound,
};

pub fn main() !void {

    // Process command line arguments
    var args = std.process.args();
    const first_arg = args.next().?; // Skip the first argument as it's the name of the binary
    std.debug.print("The first argument was: {s}\n", .{first_arg});
    const filename = args.next() orelse return InputParseError.NoFilenameFound;

    // Load program in Memory
    var buffer: [4 * 1024 - 512]u8 = undefined;
    const program = try std.fs.cwd().readFile(filename, &buffer);
    var memory = Memory.init(program);

    while (memory.fetch()) |instruction| {
        CPU.run(instruction) catch {
            std.debug.print("Instruction {x} is not supported!\n", .{instruction});
            continue;
        };
    }

    std.debug.print("Reached end of program!\n", .{});
}
