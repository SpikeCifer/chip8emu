const std = @import("std");
const Memory = @import("mem.zig").Memory;

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
        if (instruction != 0) {
            std.debug.print("0x{x}\n", .{instruction});
        }
        // decode();
        // execute();
    }
}
