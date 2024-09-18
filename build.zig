const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "chip8emu",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = b.host,
    });

    b.installArtifact(exe);

    // Zig build run command
    const run_exe = b.addRunArtifact(exe);
    if (b.args) |args| {
        run_exe.addArgs(args);
    }
    const run_step = b.step("run", "Run the Application");
    run_step.dependOn(&run_exe.step);

    // Zig build test command
    const test_step = b.step("test", "Run unit tests");
    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = b.host,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);
    test_step.dependOn(&run_unit_tests.step);
}
