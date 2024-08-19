const std = @import("std");

const Memory = @import("mem.zig").Memory;
const CPU = @import("cpu.zig").CPU;

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

    while (memory.fetch()) |instruction| {
        CPU.run(instruction) catch {
            std.debug.print("Instruction {x} is not supported!\n", .{instruction});
            continue;
        };
    }

    std.debug.print("Reached end of program!", .{});
}
