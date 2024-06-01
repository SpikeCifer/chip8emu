const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "chip8emu",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = b.standardTargetOptions(.{}),
    });

    b.installArtifact(exe);

    // Zig build run command
    const run_exe = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the Application");
    run_step.dependOn(&run_exe.step);

    // Zig build test command
}
