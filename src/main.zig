const std = @import("std");
const XdgDirs = @import("XdgDirs.zig");
const Io = std.Io;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const gpa = init.gpa;

    const xdg_dirs = try XdgDirs.init(init.io, gpa, init.environ_map);
    defer xdg_dirs.deinit(gpa);

    // Stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file_writer: Io.File.Writer = .init(.stdout(), io, &stdout_buffer);
    const stdout = &stdout_file_writer.interface;

    inline for (@typeInfo(XdgDirs).@"struct".fields) |field| {
        if (field.type == []const u8) {
            try stdout.print("{s}: {s}\n", .{ field.name, @field(xdg_dirs, field.name) });
        }
    }

    try stdout.flush(); // Don't forget to flush!
}
